//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./helpers.sol";
import {SafeERC20} from "../dependencies/SafeERC20.sol";

contract AdminModule is Helpers {
    constructor(
        address wethAddr_,
        address usdcAddr_,
        address daiAddr_,
        address wbtcAddr_,
        address oc_,
        address uc_
    ) Helpers(wethAddr_, usdcAddr_, daiAddr_, wbtcAddr_, oc_, uc_) {}

    modifier onlyAuth() {
        if (msg.sender != auth) revert("only-auth");
        _;
    }

    modifier onlyUCMarket() {
        require(UC_MARKET_ADDR == msg.sender, "not-a-protocol");
        _;
    }

    function enableUser(address userAddr_) public onlyUCMarket {
        _userToProtocol[userAddr_] = UC_MARKET_ADDR;
    }

    /**
     * @dev Function to set protocol parameters
     * @param protocolAddr_ address of protocol
     * @param supplyTokens_ array of supply tokens
     * @param supplyAllowances_ array of bools. true => enabled, false => disable
     * @param borrowTokens_ array of borrow tokens
     * @param borrowAllowances_ array of respective borrow limits
     */
    function updateProtocolParams(
        address protocolAddr_,
        address[] calldata supplyTokens_,
        bool[] calldata supplyAllowances_,
        address[] calldata borrowTokens_,
        uint256[] calldata borrowAllowances_
    ) public onlyAuth {
        uint256 supplyLength_ = supplyTokens_.length;
        uint256 borrowLength_ = borrowTokens_.length;
        require(
            supplyAllowances_.length == supplyLength_,
            "supply-lengths-not-same"
        );
        require(
            borrowAllowances_.length == borrowLength_,
            "borrow-lengths-not-same"
        );
        for (uint256 i; i < supplyLength_; ) {
            uint256 allowance_;
            if (supplyAllowances_[i]) allowance_ = 1;

            _protocolData[protocolAddr_][supplyTokens_[i]] =
                _protocolData[protocolAddr_][supplyTokens_[i]] |
                1;
            unchecked {
                ++i;
            }
        }
        for (uint256 i; i < borrowLength_; ) {
            _protocolData[protocolAddr_][borrowTokens_[i]] = pack(
                _protocolData[protocolAddr_][borrowTokens_[i]],
                borrowAllowances_[i],
                1,
                58
            );
            unchecked {
                ++i;
            }
        }

        emit updateProtocolParamsLog(
            protocolAddr_,
            supplyTokens_,
            supplyAllowances_,
            borrowTokens_,
            borrowAllowances_
        );
    }
}

contract Internals is AdminModule {
    constructor(
        address wethAddr_,
        address usdcAddr_,
        address daiAddr_,
        address wbtcAddr_,
        address oc_,
        address uc_
    ) AdminModule(wethAddr_, usdcAddr_, daiAddr_, wbtcAddr_, oc_, uc_) {}

    function updateStorage(
        address token_,
        int256 supplyAmount_,
        int256 borrowAmount_
    )
        internal
        returns (
            uint256 oldRawAmount_,
            uint256 newRawAmount_,
            uint256 newSupplyExchangePrice_,
            uint256 newBorrowExchangePrice_
        )
    {
        TokenData memory tokenData_ = getTokenData(token_);
        uint256 poolData_ = _poolData[token_];
        PoolData memory poolDatas_ = decompilePoolData(poolData_);

        (newSupplyExchangePrice_, newBorrowExchangePrice_) = updateInterest(
            poolDatas_.utilization,
            poolDatas_.lastUpdateTimestamp,
            poolDatas_.lastSupplyExchangePrice,
            poolDatas_.lastBorrowExchangePrice
        );

        uint256 userData_ = _userData[msg.sender][token_];

        if (supplyAmount_ > 0) {
            // supply allowance check
            if (_protocolData[validateUser(msg.sender)][token_] & 1 == 0)
                revert("not-enabled-to-supply");

            uint256 newRawSupply_ = (uint256(supplyAmount_) * 1e16) /
                (newSupplyExchangePrice_ * (10**tokenData_.decimals));

            poolDatas_.rawSupply += newRawSupply_;
            if (poolDatas_.rawSupply > RAW_SUPPLY_CAP)
                revert("raw-supply-cap-reached");
            oldRawAmount_ = unpack(userData_, 0, 58);
            newRawAmount_ = oldRawAmount_ + newRawSupply_;

            // storage updates
            _poolData[token_] = pack(poolData_, poolDatas_.rawSupply, 139, 197);
            _userData[msg.sender][token_] = pack(
                userData_,
                newRawAmount_,
                0,
                58
            );
        } else if (supplyAmount_ < 0) {
            // withdraw
            // no allowance checks while withdrawing
            uint256 newRawWithdraw_ = (uint256(-supplyAmount_) * 1e16) /
                (newSupplyExchangePrice_ * (10**tokenData_.decimals));

            // will throw if goes negative
            poolDatas_.rawSupply -= newRawWithdraw_;
            oldRawAmount_ = unpack(userData_, 0, 58);
            newRawAmount_ = oldRawAmount_ - newRawWithdraw_;

            // storage updates
            _poolData[token_] = pack(poolData_, poolDatas_.rawSupply, 139, 197);
            _userData[msg.sender][token_] = pack(
                userData_,
                newRawAmount_,
                0,
                58
            );
        }
        if (borrowAmount_ > 0) {
            uint256 newRawBorrow_ = (uint256(borrowAmount_) * 1e16) /
                (newBorrowExchangePrice_ * (10**tokenData_.decimals));
            poolDatas_.rawBorrow += newRawBorrow_;
            if (poolDatas_.rawSupply > RAW_BORROW_CAP)
                revert("raw-borrow-cap-reached");
            oldRawAmount_ = unpack(userData_, 59, 116);
            newRawAmount_ = oldRawAmount_ + newRawBorrow_;

            // borrow allowance check
            if (
                unpack(_protocolData[validateUser(msg.sender)][token_], 1, 58) <
                newRawAmount_
            ) revert("not-enough-borrow-allowance");

            // storage updates
            _poolData[token_] = pack(poolData_, poolDatas_.rawBorrow, 198, 255);
            _userData[msg.sender][token_] = pack(
                userData_,
                newRawAmount_,
                59,
                116
            );
        } else if (borrowAmount_ < 0) {
            // payback
            // no allowance checks while paying back
            uint256 newRawPayback_ = (uint256(-borrowAmount_) * 1e16) /
                (newBorrowExchangePrice_ * (10**tokenData_.decimals));

            // will throw if goes negative
            poolDatas_.rawBorrow -= newRawPayback_;

            oldRawAmount_ = unpack(userData_, 59, 116);
            newRawAmount_ = oldRawAmount_ - newRawPayback_;

            // storage updates
            _poolData[token_] = pack(poolData_, poolDatas_.rawBorrow, 198, 255);
            _userData[msg.sender][token_] = pack(
                userData_,
                newRawAmount_,
                59,
                116
            );
        }

        uint256 totalSupply_ = (poolDatas_.rawSupply *
            newSupplyExchangePrice_) / 1e8;
        uint256 totalBorrow_ = (poolDatas_.rawBorrow *
            newBorrowExchangePrice_) / 1e8;
        poolDatas_.utilization = totalSupply_ == 0
            ? 0
            : (totalBorrow_ * 1e8) / totalSupply_; // utilization is in 8 decimals

        if (borrowAmount_ > 0) {
            // borrowAmount_ > 0 means its a borrow transaction
            if (poolDatas_.utilization > BORROW_UTILIZATION_CAP) {
                // utilization cap check
                revert("utilization-cap-reached");
            }

            if (totalBorrow_ > tokenData_.borrowAllowance) {
                // borrow limit check
                revert("borrow-allowance-reached");
            }

            if (poolDatas_.lastBorrowExchangePrice == 1e12) {
                // no borrowings will be allowed as borrow rates will be zero if exchange price reached 1e12
                revert("exchange-price-breached");
            }
        }

        _poolData[token_] = compilePoolData(
            poolDatas_.utilization,
            block.timestamp,
            newSupplyExchangePrice_,
            newBorrowExchangePrice_,
            poolDatas_.rawSupply,
            poolDatas_.rawBorrow
        );

        emit updateStorageLog(
            token_,
            msg.sender,
            newSupplyExchangePrice_,
            newBorrowExchangePrice_,
            totalSupply_,
            totalBorrow_
        );
    }
}

contract LiquidityPoolImplementation is Internals {
    using SafeERC20 for IERC20;

    constructor(
        address wethAddr_,
        address usdcAddr_,
        address daiAddr_,
        address wbtcAddr_,
        address oc_,
        address uc_
    ) payable Internals(wethAddr_, usdcAddr_, daiAddr_, wbtcAddr_, oc_, uc_) {}

    function supply(
        address token_,
        uint256 amount_,
        address from_
    )
        public
        nonReentrant
        returns (
            uint256 oldRawAmount_,
            uint256 newRawAmount_,
            uint256 supplyExchangePrice_,
            uint256 borrowExchangePrice_
        )
    {
        IERC20(token_).safeTransferFrom(from_, address(this), amount_);
        (
            oldRawAmount_,
            newRawAmount_,
            supplyExchangePrice_,
            borrowExchangePrice_
        ) = updateStorage(token_, int256(amount_), 0);

        emit supplyLog(msg.sender, token_, amount_, from_);
    }

    function withdraw(
        address token_,
        uint256 amount_,
        address to_
    )
        public
        nonReentrant
        returns (
            uint256 oldRawAmount_,
            uint256 newRawAmount_,
            uint256 supplyExchangePrice_,
            uint256 borrowExchangePrice_
        )
    {
        (
            oldRawAmount_,
            newRawAmount_,
            supplyExchangePrice_,
            borrowExchangePrice_
        ) = updateStorage(token_, -int256(amount_), 0);
        IERC20(token_).safeTransfer(to_, amount_);

        emit withdrawLog(msg.sender, token_, amount_, to_);
    }

    function borrow(
        address token_,
        uint256 amount_,
        address to_
    )
        public
        nonReentrant
        returns (
            uint256 oldRawAmount_,
            uint256 newRawAmount_,
            uint256 supplyExchangePrice_,
            uint256 borrowExchangePrice_
        )
    {
        (
            oldRawAmount_,
            newRawAmount_,
            supplyExchangePrice_,
            borrowExchangePrice_
        ) = updateStorage(token_, 0, int256(amount_));
        IERC20(token_).safeTransfer(to_, amount_);

        emit borrowLog(msg.sender, token_, amount_, to_);
    }

    function payback(
        address token_,
        uint256 amount_,
        address from_
    )
        public
        nonReentrant
        returns (
            uint256 oldRawAmount_,
            uint256 newRawAmount_,
            uint256 supplyExchangePrice_,
            uint256 borrowExchangePrice_
        )
    {
        IERC20(token_).safeTransferFrom(from_, address(this), amount_);
        (
            oldRawAmount_,
            newRawAmount_,
            supplyExchangePrice_,
            borrowExchangePrice_
        ) = updateStorage(token_, 0, -int256(amount_));

        emit paybackLog(msg.sender, token_, amount_, from_);
    }

    function initialize(address auth_) external {
        if (_status != 0) revert("only-once");
        auth = auth_;
        _status = 1;
    }
}
