//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./helpers.sol";
import {SafeERC20} from "../dependencies/SafeERC20.sol";

contract Internals is Helpers {
    using SafeERC20 for IERC20;

    function calRateFromUtilization(uint256 utilization_)
        internal
        pure
        returns (uint256 rate_)
    {
        // scaled from 4 decimals to 8 decimals as utilization is in 8 decimals
        uint256 kink_ = KINK * 1e4;

        uint256 slope_;
        uint256 constant_;
        uint256 sign_;
        if (utilization_ < kink_) {
            slope_ = SLOPE_1;
            constant_ = CONSTANT_1;
            sign_ = SIGN_1;
        } else {
            slope_ = SLOPE_2;
            constant_ = CONSTANT_2;
            sign_ = SIGN_2;
        }
        // rate is in 18 decimals // 1e18 = 100%
        // rate means rate per second
        rate_ = ((slope_ * utilization_) / 1e8);
        if (sign_ == 1) {
            rate_ += constant_;
        } else {
            rate_ -= constant_;
        }
    }

    function updateInterest(
        uint256 utilization_,
        uint256 lastUpdateTimestamp_,
        uint256 lastSupplyExchangePrice_,
        uint256 lastBorrowExchangePrice_
    )
        internal
        view
        returns (
            uint256 newSupplyExchangePrice_,
            uint256 newBorrowExchangePrice_
        )
    {
        if (lastUpdateTimestamp_ == 0) {
            newSupplyExchangePrice_ = 1e8;
            newBorrowExchangePrice_ = 1e8;
        } else {
            uint256 borrowRate_ = calRateFromUtilization(utilization_);
            uint256 supplyRate_ = (borrowRate_ * utilization_ * (10000 - FEE)) /
                1e12;
            uint256 timePassed_ = block.timestamp - lastUpdateTimestamp_;

            newSupplyExchangePrice_ =
                lastSupplyExchangePrice_ +
                ((lastSupplyExchangePrice_ * supplyRate_ * timePassed_) / 1e18);

            newBorrowExchangePrice_ =
                lastBorrowExchangePrice_ +
                ((lastBorrowExchangePrice_ * borrowRate_ * timePassed_) / 1e18);

            // exchange price wont increase after 1e12
            // added so the code doesn't break for the edge case
            if (newSupplyExchangePrice_ > 1e12) newSupplyExchangePrice_ = 1e12;
            if (newBorrowExchangePrice_ > 1e12) newBorrowExchangePrice_ = 1e12;
        }
    }

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

        // event
    }

    function supplyInternal(
        address token_,
        uint256 amount_,
        address from_
    )
        internal
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
        // event
    }

    function withdrawInternal(
        address token_,
        uint256 amount_,
        address to_
    )
        internal
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
        // event
    }

    function borrowInternal(
        address token_,
        uint256 amount_,
        address to_
    )
        internal
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
        // event
    }

    function paybackInternal(
        address token_,
        uint256 amount_,
        address from_
    )
        internal
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
        // event
    }
}

contract LiquidityPool is Internals {
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
        (
            oldRawAmount_,
            newRawAmount_,
            supplyExchangePrice_,
            borrowExchangePrice_
        ) = supplyInternal(token_, amount_, from_);
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
        ) = withdrawInternal(token_, amount_, to_);
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
        ) = borrowInternal(token_, amount_, to_);
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
        (
            oldRawAmount_,
            newRawAmount_,
            supplyExchangePrice_,
            borrowExchangePrice_
        ) = paybackInternal(token_, amount_, from_);
    }
}
