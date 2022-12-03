// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./helpers.sol";
import {SafeERC20} from "../../../dependencies/SafeERC20.sol";

contract UCMarket is Helpers {
    using SafeERC20 for IERC20;

    constructor(
        address liquidityPoolAddr_,
        address oracleAddr_,
        address aaveDataProviderAddr_,
        address wethAddr_,
        address usdcAddr_,
        address daiAddr_,
        address wbtcAddr_
    )
        Helpers(
            liquidityPoolAddr_,
            oracleAddr_,
            aaveDataProviderAddr_,
            wethAddr_,
            usdcAddr_,
            daiAddr_,
            wbtcAddr_
        )
    {}

    // called by factory
    function initializeAuth(address auth_) external {
        if (_status != 0) revert("only-once");
        auth = auth_;
        _status = 1;
    }

    modifier onlyAuth() {
        if (auth == msg.sender) revert("only-auth");
        _;
    }

    // function to supply to liquidity pool
    // supply can be either from funds in wallet or from user directly
    function supplyToLiquidityPool(
        address token_,
        uint256 amount_,
        bool fromWallet_
    ) external onlyAuth {
        if (amount_ == 0) revert("zero-amount");
        uint256 assetIndex_ = getAssetIndex(token_);

        bool addToSupplyTokens_;
        bool removeFromHoldTokens_;

        address fromAddr_;
        if (fromWallet_) {
            uint256 oswBal_ = IERC20(token_).balanceOf(address(this));
            if (amount_ == type(uint256).max) amount_ = oswBal_;
            if (amount_ == oswBal_) removeFromHoldTokens_ = true;

            IERC20(token_).safeApprove(address(LIQUIDITY_POOL), amount_);
            fromAddr_ = address(this);
        } else {
            fromAddr_ = msg.sender;
        }

        (uint256 oldRawSupply_, , , ) = LIQUIDITY_POOL.supply(
            token_,
            amount_,
            fromAddr_
        );
        if (oldRawSupply_ == 0) addToSupplyTokens_ = true;

        if (addToSupplyTokens_ || removeFromHoldTokens_) {
            uint256 walletData_ = walletData;

            // update mapping to add to supply tokens
            if (addToSupplyTokens_) {
                walletData_ = addToSupplyTokens(walletData_, assetIndex_);
            }

            // update mapping to remove from hold tokens
            if (removeFromHoldTokens_) {
                walletData_ = removeFromHoldTokens(walletData_, assetIndex_);
            }
            if (walletData_ != walletData) walletData = walletData_;
        }
        // no hf check for supply liquidity
    }

    function supplyToWallet(address token_, uint256 amount_) external onlyAuth {
        if (amount_ == 0) revert("zero-amount");
        uint256 assetIndex_ = getAssetIndex(token_);

        bool addToHoldTokens_;
        if (IERC20(token_).balanceOf(address(this)) == 0)
            addToHoldTokens_ = true;

        IERC20(token_).safeTransferFrom(msg.sender, address(this), amount_);

        if (addToHoldTokens_) {
            uint256 walletData_ = walletData;
            walletData_ = addToHoldTokens(walletData_, assetIndex_);
            if (walletData_ != walletData) walletData = walletData_;
        }
        // no hf check for supply
    }

    // withdraw can be either to wallet or outside
    // hf checked if it is outside
    function withdrawFromLiquidityPool(
        address token_,
        uint256 amount_,
        address to_
    ) internal {
        if (amount_ == 0) revert("zero-amount");
        uint256 assetIndex_ = getAssetIndex(token_);

        bool removeFromSupplyTokens_;
        bool addToHoldTokens_;

        (, uint256 supplyAmount_) = LIQUIDITY_POOL.getUserSupplyAmount(
            address(this),
            token_
        );
        if (amount_ == type(uint256).max) amount_ = supplyAmount_;
        if (amount_ > supplyAmount_) revert("excess-withdraw");
        if (amount_ == supplyAmount_) removeFromSupplyTokens_ = true;

        if (
            to_ == address(this) && IERC20(token_).balanceOf(address(this)) == 0
        ) {
            addToHoldTokens_ = true;
        }

        LIQUIDITY_POOL.withdraw(token_, amount_, to_);

        if (removeFromSupplyTokens_ || addToHoldTokens_) {
            uint256 walletData_ = walletData;
            if (removeFromSupplyTokens_) {
                walletData_ = removeFromSupplyTokens(walletData_, assetIndex_);
            }
            if (addToHoldTokens_) {
                walletData_ = addToHoldTokens(walletData_, assetIndex_);
            }
            if (walletData_ != walletData) walletData = walletData_;
        }

        if (to_ != address(this)) {
            // TODO: check hf
        }
    }

    function withdrawFromWallet(
        address token_,
        uint256 amount_,
        address to_
    ) external onlyAuth {
        if (amount_ == 0) revert("zero-amount");
        uint256 assetIndex_ = getAssetIndex(token_);

        bool removeFromHoldTokens_;

        uint256 maxAmount_ = IERC20(token_).balanceOf(address(this));
        if (amount_ == type(uint256).max) amount_ = maxAmount_;
        if (amount_ > maxAmount_) revert("excess-withdraw");
        if (amount_ == maxAmount_) {
            removeFromHoldTokens_ = true;
        }

        IERC20(token_).transfer(to_, amount_);

        if (removeFromHoldTokens_) {
            uint256 walletData_ = walletData;
            walletData_ = removeFromHoldTokens(walletData_, assetIndex_);
            if (walletData_ != walletData) walletData = walletData_;
        }
        // TODO: check hf
    }
}
