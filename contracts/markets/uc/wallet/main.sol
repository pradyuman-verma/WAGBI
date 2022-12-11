// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./helpers.sol";
import {SafeERC20} from "../../../dependencies/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract UCWalletImplementation is Helpers {
    using SafeERC20 for IERC20;

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
        Helpers(
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

    // called by factory
    function initializeAuth(address auth_) external {
        if (_status != 0) revert("only-once");
        auth = auth_;
        _status = 1;
    }

    modifier onlyAuth() {
        if (auth != msg.sender) revert("only-auth");
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
    ) external onlyAuth {
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
            checkHf();
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
        checkHf();
    }

    function borrowToWallet(address token_, uint256 amount_) external onlyAuth {
        if (amount_ == 0) revert("zero-amount");
        uint256 assetIndex_ = getAssetIndex(token_);

        bool addToBorrowTokens_;
        bool addToHoldTokens_;

        if (IERC20(token_).balanceOf(address(this)) == 0)
            addToHoldTokens_ = true;

        (uint256 oldRawAmount_, , , ) = LIQUIDITY_POOL.borrow(
            token_,
            amount_,
            address(this)
        );
        if (oldRawAmount_ == 0) {
            addToBorrowTokens_ = true;
        }

        if (addToBorrowTokens_ || addToHoldTokens_) {
            uint256 walletData_ = walletData;
            if (addToBorrowTokens_) {
                walletData_ = addToBorrowTokens(walletData_, assetIndex_);
            }
            if (addToHoldTokens_) {
                walletData_ = addToHoldTokens(walletData_, assetIndex_);
            }
            if (walletData_ != walletData) walletData = walletData_;
        }
        checkHf();
    }

    function payback(
        address token_,
        uint256 amount_,
        bool fromOsw_
    ) external onlyAuth {
        if (amount_ == 0) revert("zero-amount");
        uint256 assetIndex_ = getAssetIndex(token_);

        address fromAddr_;
        bool removeFromBorrowTokens_;
        bool removeFromHoldTokens_;

        (, uint256 borrowAmount_) = LIQUIDITY_POOL.getUserBorrowAmount(
            address(this),
            token_
        );
        if (amount_ == type(uint256).max) amount_ = borrowAmount_;
        if (amount_ > borrowAmount_) revert("excess-payback");
        if (amount_ == borrowAmount_) removeFromBorrowTokens_ = true;
        if (fromOsw_) {
            if (amount_ == IERC20(token_).balanceOf(address(this))) {
                removeFromHoldTokens_ = true;
            }

            IERC20(token_).safeApprove(address(LIQUIDITY_POOL), amount_);
            fromAddr_ = address(this);
        } else {
            fromAddr_ = msg.sender;
        }

        LIQUIDITY_POOL.payback(token_, amount_, fromAddr_);

        if (removeFromBorrowTokens_ || removeFromHoldTokens_) {
            uint256 walletData_ = walletData;
            if (removeFromBorrowTokens_) {
                walletData_ = removeFromBorrowTokens(walletData_, assetIndex_);
            }
            if (removeFromHoldTokens_) {
                walletData_ = removeFromHoldTokens(walletData_, assetIndex_);
            }
            if (walletData_ != walletData) walletData = walletData_;
        }
    }

    function useAave(bytes calldata params_) external onlyAuth {
        Address.functionDelegateCall(
            AAVE_INTERACTOR_ADDR,
            params_,
            "interaction-failed"
        );
        checkHf();
    }
}
