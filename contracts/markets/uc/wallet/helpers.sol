// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./variables.sol";

contract Helpers is Variables {
    constructor(
        address liquidityPoolAddr_,
        address oracleAddr_,
        address aaveDataProviderAddr_,
        address aaveInteractorAddr_,
        address wethAddr_,
        address usdcAddr_,
        address daiAddr_,
        address wbtcAddr_
    )
        Variables(
            liquidityPoolAddr_,
            oracleAddr_,
            aaveDataProviderAddr_,
            aaveInteractorAddr_,
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

    function getAssetIndex(address token_)
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
            revert("unsupported-token");
        }
    }

    function getIndexToAsset(uint256 assetIndex_)
        internal
        view
        returns (
            address asset_,
            uint256 decimals_,
            uint256 cf_,
            uint256 df_,
            address atokenAddr_,
            address avdtokenAddr
        )
    {
        if (assetIndex_ == WETH_INDEX) {
            asset_ = WETH_ADDR;
            decimals_ = WETH_DECIMALS;
            cf_ = WETH_CF;
            df_ = WETH_DF;
            atokenAddr_ = AAVE_WETH_COLLATERAL_TOKEN_ADDR;
            avdtokenAddr = AAVE_WETH_VARIABLE_DEBT_TOKEN_ADDR;
        } else if (assetIndex_ == USDC_INDEX) {
            asset_ = USDC_ADDR;
            decimals_ = USDC_DECIMALS;
            cf_ = USDC_CF;
            df_ = USDC_DF;
            atokenAddr_ = AAVE_USDC_COLLATERAL_TOKEN_ADDR;
            avdtokenAddr = AAVE_USDC_VARIABLE_DEBT_TOKEN_ADDR;
        } else if (assetIndex_ == DAI_INDEX) {
            asset_ = DAI_ADDR;
            decimals_ = DAI_DECIMALS;
            cf_ = DAI_CF;
            df_ = DAI_DF;
            atokenAddr_ = AAVE_DAI_COLLATERAL_TOKEN_ADDR;
            avdtokenAddr = AAVE_DAI_VARIABLE_DEBT_TOKEN_ADDR;
        } else if (assetIndex_ == WBTC_INDEX) {
            asset_ = WBTC_ADDR;
            decimals_ = WBTC_DECIMALS;
            cf_ = WBTC_CF;
            df_ = WBTC_DF;
            atokenAddr_ = AAVE_WBTC_COLLATERAL_TOKEN_ADDR;
            avdtokenAddr = AAVE_WBTC_VARIABLE_DEBT_TOKEN_ADDR;
        } else {
            revert("unsupported-index");
        }
    }

    function addToSupplyTokens(uint256 walletData_, uint256 assetIndex_)
        internal
        pure
        returns (uint256 newWalletData_)
    {
        newWalletData_ = walletData_ | (1 << assetIndex_);
    }

    function removeFromSupplyTokens(uint256 walletData_, uint256 assetIndex_)
        internal
        pure
        returns (uint256 newWalletData_)
    {
        newWalletData_ = walletData_ & ~(1 << assetIndex_);
    }

    function addToBorrowTokens(uint256 walletData_, uint256 assetIndex_)
        internal
        pure
        returns (uint256 newWalletData_)
    {
        newWalletData_ = walletData_ | (1 << (assetIndex_ + 50));
    }

    function removeFromBorrowTokens(uint256 walletData_, uint256 assetIndex_)
        internal
        pure
        returns (uint256 newWalletData_)
    {
        newWalletData_ = walletData_ & ~(1 << (assetIndex_ + 50));
    }

    function addToHoldTokens(uint256 walletData_, uint256 assetIndex_)
        internal
        pure
        returns (uint256 newWalletData_)
    {
        newWalletData_ = walletData_ | (1 << (assetIndex_ + 100));
    }

    function removeFromHoldTokens(uint256 walletData_, uint256 assetIndex_)
        internal
        pure
        returns (uint256 newWalletData_)
    {
        newWalletData_ = walletData_ & ~(1 << (assetIndex_ + 100));
    }

    function getHfData()
        public
        view
        returns (
            uint256 normalizedCollateralInEth_,
            uint256 normalizedDebtInEth_
        )
    {
        uint256 walletData_ = walletData;
        uint256 priceInEth_;
        for (uint256 i; i < 4; ) {
            // supply
            if (walletData_ & (1 << i) > 0) {
                (
                    address asset_,
                    uint256 decimals_,
                    uint256 cf_,
                    ,
                    ,

                ) = getIndexToAsset(i);
                (, uint256 supplyAmount_) = LIQUIDITY_POOL.getUserSupplyAmount(
                    address(this),
                    asset_
                );
                if (priceInEth_ == 0)
                    priceInEth_ = ORACLE.getPriceInEth(asset_);
                normalizedCollateralInEth_ +=
                    (supplyAmount_ * priceInEth_ * cf_) /
                    (10**(decimals_ + 4));
            }

            // borrow
            if (walletData_ & (1 << (i + 50)) > 0) {
                (
                    address asset_,
                    uint256 decimals_,
                    ,
                    uint256 df_,
                    ,

                ) = getIndexToAsset(i);
                (, uint256 borrowAmount_) = LIQUIDITY_POOL.getUserBorrowAmount(
                    address(this),
                    asset_
                );
                if (priceInEth_ == 0)
                    priceInEth_ = ORACLE.getPriceInEth(asset_);
                normalizedDebtInEth_ +=
                    (borrowAmount_ * priceInEth_ * 1e4) /
                    (df_ * (10**decimals_));
            }

            // hold
            if (walletData_ & (1 << (i + 100)) > 0) {
                (
                    address asset_,
                    uint256 decimals_,
                    uint256 cf_,
                    ,
                    ,

                ) = getIndexToAsset(i);
                uint256 holdAmount_ = IERC20(asset_).balanceOf(address(this));
                if (priceInEth_ == 0)
                    priceInEth_ = ORACLE.getPriceInEth(asset_);
                normalizedCollateralInEth_ +=
                    (holdAmount_ * priceInEth_ * cf_) /
                    (10**(decimals_ + 4));
            }

            // aave supply
            if (walletData_ & (1 << (i + 150)) > 0) {
                (
                    address asset_,
                    uint256 decimals_,
                    uint256 cf_,
                    ,
                    address atokenAddr_,

                ) = getIndexToAsset(i);
                uint256 aaveSupplyAmount_ = IERC20(atokenAddr_).balanceOf(
                    address(this)
                );
                if (priceInEth_ == 0)
                    priceInEth_ = ORACLE.getPriceInEth(asset_);
                normalizedCollateralInEth_ +=
                    (aaveSupplyAmount_ * priceInEth_ * cf_) /
                    (10**(decimals_ + 4));
            }

            // aave borrow
            if (walletData_ & (1 << (i + 200)) > 0) {
                (
                    address asset_,
                    uint256 decimals_,
                    ,
                    uint256 df_,
                    ,
                    address avdtokenAddr_
                ) = getIndexToAsset(i);
                uint256 aaveBorrowAmount_ = IERC20(avdtokenAddr_).balanceOf(
                    address(this)
                );
                if (priceInEth_ == 0)
                    priceInEth_ = ORACLE.getPriceInEth(asset_);
                normalizedDebtInEth_ +=
                    (aaveBorrowAmount_ * priceInEth_ * 1e4) /
                    (df_ * (10**decimals_));
            }

            priceInEth_ = 0;
            unchecked {
                ++i;
            }
        }
    }

    function getHf() public view returns (uint256 hf_) {
        (
            uint256 normalizedCollateralInEth_,
            uint256 normalizedDebtInEth_
        ) = getHfData();
        hf_ = normalizedDebtInEth_ == 0
            ? type(uint256).max
            : (normalizedCollateralInEth_ * 1e18) / normalizedDebtInEth_;
    }

    function checkHf() internal view {
        uint256 hf_ = getHf();
        if (hf_ < MIN_HF_THRESHOLD) revert("position-not-safe");
    }
}
