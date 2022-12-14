//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./events.sol";

contract Helpers is Events {
    constructor(
        address wethAddr_,
        address usdcAddr_,
        address daiAddr_,
        address wbtcAddr_,
        address oc_,
        address uc_
    ) Events(wethAddr_, usdcAddr_, daiAddr_, wbtcAddr_, oc_, uc_) {}

    struct TokenData {
        uint256 decimals;
        uint256 borrowAllowance;
    }

    struct PoolData {
        uint256 utilization;
        uint256 lastUpdateTimestamp;
        uint256 lastSupplyExchangePrice;
        uint256 lastBorrowExchangePrice;
        uint256 rawSupply;
        uint256 rawBorrow;
    }

    modifier nonReentrant() {
        require(_status == 1, "ReentrancyGuard: reentrant call");
        _status = 2;
        _;
        _status = 1;
    }

    function pack(
        uint256 input_,
        uint256 insertValue_,
        uint256 startPosition_,
        uint256 endPosition_
    ) public pure returns (uint256 output_) {
        uint256 mask = ((2**(endPosition_ - startPosition_ + 1)) - 1) <<
            startPosition_;
        output_ = (input_ & (~mask)) | (insertValue_ << startPosition_);
    }

    function unpack(
        uint256 input_,
        uint256 startPosition_,
        uint256 endPosition_
    ) public pure returns (uint256 output_) {
        output_ =
            (input_ << (255 - endPosition_)) >>
            (255 + startPosition_ - endPosition_);
    }

    function getTokenData(address token_)
        internal
        view
        returns (TokenData memory tokenData_)
    {
        if (token_ == WETH_ADDR) {
            tokenData_.decimals = WETH_DECIMALS;
            tokenData_.borrowAllowance = WETH_BORROW_ALLOWANCE;
        } else if (token_ == USDC_ADDR) {
            tokenData_.decimals = USDC_DECIMALS;
            tokenData_.borrowAllowance = USDC_BORROW_ALLOWANCE;
        } else if (token_ == DAI_ADDR) {
            tokenData_.decimals = DAI_DECIMALS;
            tokenData_.borrowAllowance = DAI_BORROW_ALLOWANCE;
        } else if (token_ == WBTC_ADDR) {
            tokenData_.decimals = WBTC_DECIMALS;
            tokenData_.borrowAllowance = WBTC_BORROW_ALLOWANCE;
        } else {
            revert("unsupported-token");
        }
    }

    function compilePoolData(
        uint256 utilization_,
        uint256 timestamp_,
        uint256 supplyExchangePrice_,
        uint256 borrowExchangePrice_,
        uint256 rawSupply_,
        uint256 rawBorrow_
    ) internal pure returns (uint256 poolData_) {
        poolData_ = pack(utilization_, timestamp_, 27, 58);
        poolData_ = pack(poolData_, supplyExchangePrice_, 59, 98);
        poolData_ = pack(poolData_, borrowExchangePrice_, 99, 138);
        poolData_ = pack(poolData_, rawSupply_, 139, 197);
        poolData_ = pack(poolData_, rawBorrow_, 198, 255);
    }

    function decompilePoolData(uint256 poolData_)
        internal
        pure
        returns (PoolData memory poolDatas_)
    {
        poolDatas_.utilization = unpack(poolData_, 0, 26);
        poolDatas_.lastUpdateTimestamp = unpack(poolData_, 27, 58);
        poolDatas_.lastSupplyExchangePrice = unpack(poolData_, 59, 98);
        poolDatas_.lastBorrowExchangePrice = unpack(poolData_, 99, 138);
        poolDatas_.rawSupply = unpack(poolData_, 139, 197);
        poolDatas_.rawBorrow = unpack(poolData_, 198, 255);
    }

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

    function validateUser(address user_)
        internal
        view
        returns (address marketAddr_)
    {
        if (user_ == OC_MARKET_ADDR) {
            marketAddr_ = OC_MARKET_ADDR;
        } else if (_userToProtocol[user_] == UC_MARKET_ADDR) {
            marketAddr_ = UC_MARKET_ADDR;
        } else {
            revert("user-not-whitelisted");
        }
    }

    function getExchangePrices(address token_)
        public
        view
        returns (uint256 supplyExchangePrice_, uint256 borrowExchangePrice_)
    {
        uint256 poolData_ = _poolData[token_];
        PoolData memory poolDatas_ = decompilePoolData(poolData_);

        (supplyExchangePrice_, borrowExchangePrice_) = updateInterest(
            poolDatas_.utilization,
            poolDatas_.lastUpdateTimestamp,
            poolDatas_.lastSupplyExchangePrice,
            poolDatas_.lastBorrowExchangePrice
        );
    }

    function getUserBorrowAmount(address user_, address token_)
        public
        view
        returns (uint256 rawBorrowAmount_, uint256 borrowAmount_)
    {
        TokenData memory tokenData_ = getTokenData(token_);
        rawBorrowAmount_ = unpack(_userData[user_][token_], 59, 116);
        borrowAmount_ =
            (rawBorrowAmount_ *
                unpack(_poolData[token_], 99, 138) *
                (10**tokenData_.decimals)) /
            1e16;
    }

    function getUserSupplyAmount(address user_, address token_)
        public
        view
        returns (uint256 rawSupplyAmount, uint256 supplyAmount)
    {
        TokenData memory tokenData_ = getTokenData(token_);
        rawSupplyAmount = unpack(_userData[user_][token_], 0, 58);
        supplyAmount =
            (rawSupplyAmount *
                unpack(_poolData[token_], 59, 98) *
                (10**tokenData_.decimals)) /
            1e16;
    }

    function getRates(address token_)
        public
        view
        returns (uint256 supplyRate_, uint256 borrowRate_)
    {
        uint256 secondsInYear = 31536000;
        uint256 utilization_ = unpack(_poolData[token_], 0, 26);
        uint256 borrowRatePerSecond_ = calRateFromUtilization(utilization_);
        uint256 supplyRatePerSecond_ = (borrowRatePerSecond_ *
            utilization_ *
            (10000 - FEE)) / 1e12;
        supplyRate_ = supplyRatePerSecond_ * secondsInYear;
        borrowRate_ = borrowRatePerSecond_ * secondsInYear;
    }
}
