// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./variables.sol";

contract Helpers is Variables {
    constructor(
        address liquidityPoolAddr_,
        address oracleAddr_,
        address wethAddr_,
        address usdcAddr_,
        address daiAddr_,
        address wbtcAddr_
    )
        Variables(
            liquidityPoolAddr_,
            oracleAddr_,
            wethAddr_,
            usdcAddr_,
            daiAddr_,
            wbtcAddr_
        )
    {}

    function pack(
        uint256 input_,
        uint256 insertValue_,
        uint256 startPosition_,
        uint256 endPosition_
    ) internal pure returns (uint256 output_) {
        uint256 mask = ((2**(endPosition_ - startPosition_ + 1)) - 1) <<
            startPosition_;
        output_ = (input_ & (~mask)) | (insertValue_ << startPosition_);
    }

    function unpack(
        uint256 input_,
        uint256 startPosition_,
        uint256 endPosition_
    ) internal pure returns (uint256 output_) {
        output_ =
            (input_ << (255 - endPosition_)) >>
            (255 + startPosition_ - endPosition_);
    }

    function getAssetToIndex(address token_)
        internal
        view
        returns (uint256 assetIndex_)
    {
        if (token_ == WETH_ADDR) {
            assetIndex_ = WETH_INDEX;
        } else if (token_ == USDC_ADDR) {
            assetIndex_ = USDC_INDEX;
        } else if (token_ == DAI_ADDR) {
            assetIndex_ = DAI_INDEX;
        } else if (token_ == WBTC_ADDR) {
            assetIndex_ = WBTC_INDEX;
        } else {
            revert("unsupported-asset");
        }
    }

    function getIndexToAsset(uint256 assetIndex_)
        internal
        view
        returns (
            address asset_,
            uint256 decimals_,
            uint256 cf_,
            uint256 df_
        )
    {
        if (assetIndex_ == WETH_INDEX) {
            asset_ = WETH_ADDR;
            decimals_ = WETH_DECIMALS;
            cf_ = WETH_CF;
            df_ = WETH_DF;
        } else if (assetIndex_ == USDC_INDEX) {
            asset_ = USDC_ADDR;
            decimals_ = USDC_DECIMALS;
            cf_ = USDC_CF;
            df_ = USDC_DF;
        } else if (assetIndex_ == DAI_INDEX) {
            asset_ = DAI_ADDR;
            decimals_ = DAI_DECIMALS;
            cf_ = DAI_CF;
            df_ = DAI_DF;
        } else if (assetIndex_ == WBTC_INDEX) {
            asset_ = WBTC_ADDR;
            decimals_ = WBTC_DECIMALS;
            cf_ = WBTC_CF;
            df_ = WBTC_DF;
        } else {
            revert("unsupported-index");
        }
    }

    function addToSupplyTokens(uint256 userTokensData_, uint256 assetIndex_)
        internal
        pure
        returns (uint256 newUserTokensData_)
    {
        newUserTokensData_ = userTokensData_ | (1 << assetIndex_);
    }

    function removeFromSupplyTokens(
        uint256 userTokensData_,
        uint256 assetIndex_
    ) internal pure returns (uint256 newUserTokensData_) {
        newUserTokensData_ = userTokensData_ & ~(1 << assetIndex_);
    }

    function addToBorrowTokens(uint256 userTokensData_, uint256 assetIndex_)
        internal
        pure
        returns (uint256 newUserTokensData_)
    {
        newUserTokensData_ = userTokensData_ | (1 << (assetIndex_ + 128));
    }

    function removeFromBorrowTokens(
        uint256 userTokensData_,
        uint256 assetIndex_
    ) internal pure returns (uint256 newUserTokensData_) {
        newUserTokensData_ = userTokensData_ & ~(1 << (assetIndex_ + 128));
    }

    function getHfData(address user_, uint256 userTokensData_)
        internal
        view
        returns (
            uint256 normalizedCollateralInEth_,
            uint256 normalizedDebtInEth_
        )
    {
        uint256 priceInEth_;
        uint256 supplyExchangePrice_;
        uint256 borrowExchangePrice_;
        for (uint256 i; i < 4; ) {
            // supply
            if (userTokensData_ & (1 << i) > 0) {
                (
                    address asset_,
                    uint256 decimals_,
                    uint256 cf_,

                ) = getIndexToAsset(i);
                uint256 rawSupply_ = unpack(
                    userAmountsData[user_][asset_],
                    0,
                    58
                );
                if (supplyExchangePrice_ == 0)
                    (
                        supplyExchangePrice_,
                        borrowExchangePrice_
                    ) = LIQUIDITY_POOL.getExchangePrices(asset_);
                uint256 supplyAmount_ = (rawSupply_ *
                    supplyExchangePrice_ *
                    (10**decimals_)) / 1e16;
                if (priceInEth_ == 0)
                    priceInEth_ = ORACLE.getPriceInEth(asset_);
                normalizedCollateralInEth_ +=
                    (supplyAmount_ * priceInEth_ * cf_) /
                    (10**(decimals_ + 4));
            }

            // borrow
            if (userTokensData_ & (1 << (i + 128)) > 0) {
                (
                    address asset_,
                    uint256 decimals_,
                    ,
                    uint256 df_
                ) = getIndexToAsset(i);
                uint256 rawBorrow_ = unpack(
                    userAmountsData[user_][asset_],
                    59,
                    116
                );

                if (borrowExchangePrice_ == 0)
                    (
                        supplyExchangePrice_,
                        borrowExchangePrice_
                    ) = LIQUIDITY_POOL.getExchangePrices(asset_);
                uint256 borrowAmount_ = (rawBorrow_ *
                    borrowExchangePrice_ *
                    (10**decimals_)) / 1e16;
                if (priceInEth_ == 0)
                    priceInEth_ = ORACLE.getPriceInEth(asset_);
                normalizedDebtInEth_ +=
                    (borrowAmount_ * priceInEth_ * 1e4) /
                    (df_ * (10**decimals_));
            }
            priceInEth_ = 0;
            supplyExchangePrice_ = 0;
            borrowExchangePrice_ = 0;
            unchecked {
                ++i;
            }
        }
    }

    function getHf(address user_, uint256 userTokensData_)
        public
        view
        returns (uint256 hf_)
    {
        (
            uint256 normalizedCollateralInEth_,
            uint256 normalizedDebtInEth_
        ) = getHfData(user_, userTokensData_);

        hf_ = normalizedDebtInEth_ == 0
            ? type(uint256).max
            : (normalizedCollateralInEth_ * 1e18) / normalizedDebtInEth_;
    }

    function getHf(address user_) public view returns (uint256 hf_) {
        return getHf(user_, userTokensData[user_]);
    }

    function checkHf(address user_, uint256 userTokensData_) internal view {
        uint256 hf_ = getHf(user_, userTokensData_);
        if (hf_ < MIN_HF_THRESHOLD) revert("position-not-safe");
    }

    function getSupplyAmount(address user_, address token_)
        public
        view
        returns (uint256 supplyAmount_)
    {
        uint256 decimals_ = IERC20(token_).decimals();
        uint256 rawSupply_ = unpack(userAmountsData[user_][token_], 0, 58);
        (uint256 supplyExchangePrice_, ) = LIQUIDITY_POOL.getExchangePrices(
            token_
        );
        supplyAmount_ =
            (rawSupply_ * supplyExchangePrice_ * (10**decimals_)) /
            1e16;
    }

    function getBorrowAmount(address user_, address token_)
        public
        view
        returns (uint256 borrowAmount_)
    {
        uint256 decimals_ = IERC20(token_).decimals();
        uint256 rawBorrow_ = unpack(userAmountsData[user_][token_], 59, 116);

        (, uint256 borrowExchangePrice_) = LIQUIDITY_POOL.getExchangePrices(
            token_
        );
        borrowAmount_ =
            (rawBorrow_ * borrowExchangePrice_ * (10**decimals_)) /
            1e16;
    }
}
