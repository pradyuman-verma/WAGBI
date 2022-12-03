//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./variables.sol";

contract Helpers is Variables {
    constructor(
        address aaveLendingPoolAddr_,
        address aaveDataProviderAddr_,
        address wethAddr_,
        address usdcAddr_,
        address daiAddr_,
        address wbtcAddr_
    )
        Variables(
            aaveLendingPoolAddr_,
            aaveDataProviderAddr_,
            wethAddr_,
            usdcAddr_,
            daiAddr_,
            wbtcAddr_
        )
    {}

    function _getAssetInfo(address token_)
        internal
        view
        returns (
            uint256 assetIndex_,
            uint256 decimals_,
            address atokenAddr_,
            address aVariableDebtTokenAddr_
        )
    {
        if (token_ == WETH_ADDR) {
            assetIndex_ = WETH_INDEX;
            decimals_ = WETH_DECIMALS;
            atokenAddr_ = AAVE_WETH_COLLATERAL_TOKEN_ADDR;
            aVariableDebtTokenAddr_ = AAVE_WETH_VARIABLE_DEBT_TOKEN_ADDR;
        } else if (token_ == USDC_ADDR) {
            assetIndex_ = USDC_INDEX;
            decimals_ = USDC_DECIMALS;
            atokenAddr_ = AAVE_USDC_COLLATERAL_TOKEN_ADDR;
            aVariableDebtTokenAddr_ = AAVE_USDC_VARIABLE_DEBT_TOKEN_ADDR;
        } else if (token_ == DAI_ADDR) {
            assetIndex_ = DAI_INDEX;
            decimals_ = DAI_DECIMALS;
            atokenAddr_ = AAVE_DAI_COLLATERAL_TOKEN_ADDR;
            aVariableDebtTokenAddr_ = AAVE_DAI_VARIABLE_DEBT_TOKEN_ADDR;
        } else if (token_ == WBTC_ADDR) {
            assetIndex_ = WBTC_INDEX;
            decimals_ = WBTC_DECIMALS;
            atokenAddr_ = AAVE_WBTC_COLLATERAL_TOKEN_ADDR;
            aVariableDebtTokenAddr_ = AAVE_WBTC_VARIABLE_DEBT_TOKEN_ADDR;
        } else {
            revert("unsupported-token");
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

    function addToAaveSupplyTokens(uint256 oswData_, uint256 assetIndex_)
        internal
        pure
        returns (uint256 newOswData_)
    {
        newOswData_ = oswData_ | (1 << (assetIndex_ + 150));
    }

    function removeFromAaveSupplyTokens(uint256 oswData_, uint256 assetIndex_)
        internal
        pure
        returns (uint256 newOswData_)
    {
        newOswData_ = oswData_ & ~(1 << (assetIndex_ + 150));
    }

    function addToAaveBorrowTokens(uint256 oswData_, uint256 assetIndex_)
        internal
        pure
        returns (uint256 newOswData_)
    {
        newOswData_ = oswData_ | (1 << (assetIndex_ + 200));
    }

    function removeFromAaveBorrowTokens(uint256 oswData_, uint256 assetIndex_)
        internal
        pure
        returns (uint256 newOswData_)
    {
        newOswData_ = oswData_ & ~(1 << (assetIndex_ + 200));
    }

    /**
     * @dev Checks if collateral is enabled for an asset
     * @param token_ token address of the asset
     */
    function _getIsColl(address token_) internal view returns (bool isCol_) {
        (, , , , , , , , isCol_) = AAVE_DATA_PROVIDER.getUserReserveData(
            token_,
            address(this)
        );
    }
}
