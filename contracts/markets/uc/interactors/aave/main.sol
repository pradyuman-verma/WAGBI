//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./helpers.sol";
import {SafeERC20} from "../../../../dependencies/SafeERC20.sol";

contract AaveInteractor is Helpers {
    using SafeERC20 for IERC20;

    constructor(
        address aaveLendingPoolAddr_,
        address aaveDataProviderAddr_,
        address wethAddr_,
        address usdcAddr_,
        address daiAddr_,
        address wbtcAddr_
    )
        Helpers(
            aaveLendingPoolAddr_,
            aaveDataProviderAddr_,
            wethAddr_,
            usdcAddr_,
            daiAddr_,
            wbtcAddr_
        )
    {}

    function deposit(address token_, uint256 amount_) external {
        uint256 walletData_ = walletData;
        (uint256 assetIndex_, , , ) = _getAssetInfo(token_);

        IERC20 tokenContract_ = IERC20(token_);

        // get amount
        uint256 tokenBalance_ = tokenContract_.balanceOf(address(this));
        amount_ = amount_ == type(uint256).max ? tokenBalance_ : amount_;
        if (amount_ == 0) revert("zero-amount");

        // wallet data update
        if (amount_ == tokenBalance_) {
            walletData_ = removeFromHoldTokens(walletData_, assetIndex_);
        }
        walletData_ = addToAaveSupplyTokens(walletData_, assetIndex_);
        if (walletData_ != walletData) walletData = walletData_;

        // aave supply
        tokenContract_.safeApprove(address(AAVE_LENDING_POOL), amount_);
        AAVE_LENDING_POOL.deposit(
            token_,
            amount_,
            address(this),
            REFERRAL_CODE
        );
        if (!_getIsColl(token_))
            AAVE_LENDING_POOL.setUserUseReserveAsCollateral(token_, true);
    }

    function withdraw(address token_, uint256 amount_) external {
        uint256 walletData_ = walletData;
        (uint256 assetIndex_, , address atokenAddr_, ) = _getAssetInfo(token_);

        uint256 tokenSuppliedAmount_ = IERC20(atokenAddr_).balanceOf(
            address(this)
        );
        amount_ = amount_ == type(uint256).max ? tokenSuppliedAmount_ : amount_;
        if (amount_ == 0) revert("zero-amount");

        // wallet data update
        if (amount_ == tokenSuppliedAmount_) {
            walletData_ = removeFromAaveSupplyTokens(walletData_, assetIndex_);
        }
        walletData_ = addToHoldTokens(walletData_, assetIndex_);
        if (walletData_ != walletData) walletData = walletData_;

        // aave withdraw
        AAVE_LENDING_POOL.withdraw(token_, amount_, address(this));
    }

    function borrow(address token_, uint256 amount_) external {
        uint256 walletData_ = walletData;
        (uint256 assetIndex_, , , ) = _getAssetInfo(token_);

        if (amount_ == 0) revert("zero-amount");

        // wallet data update
        walletData_ = addToAaveBorrowTokens(walletData_, assetIndex_);
        walletData_ = addToHoldTokens(walletData_, assetIndex_);
        if (walletData_ != walletData) walletData = walletData_;

        // aave borrow
        AAVE_LENDING_POOL.borrow(
            token_,
            amount_,
            MODE,
            REFERRAL_CODE,
            address(this)
        );
    }

    function payback(address token_, uint256 amount_) external {
        uint256 walletData_ = walletData;
        (
            uint256 assetIndex_,
            ,
            ,
            address aVariableDebtTokenAddr_
        ) = _getAssetInfo(token_);

        uint256 tokenBorrowAmount_ = IERC20(aVariableDebtTokenAddr_).balanceOf(
            address(this)
        );
        amount_ = amount_ == type(uint256).max ? tokenBorrowAmount_ : amount_;
        if (amount_ == tokenBorrowAmount_) {
            walletData_ = removeFromAaveBorrowTokens(walletData_, assetIndex_);
        }

        // aave payback
        IERC20(token_).safeApprove(address(AAVE_LENDING_POOL), amount_);
        AAVE_LENDING_POOL.repay(token_, amount_, MODE, address(this));
    }

    function enableCollateral(address[] calldata tokens_) external {
        uint256 length_ = tokens_.length;
        require(length_ > 0, "zero-length");

        for (uint256 i; i < length_; ) {
            (, , address atokenAddr_, ) = _getAssetInfo(tokens_[i]);
            if (
                IERC20(atokenAddr_).balanceOf(address(this)) > 0 &&
                !_getIsColl(tokens_[i])
            ) AAVE_LENDING_POOL.setUserUseReserveAsCollateral(tokens_[i], true);

            unchecked {
                ++i;
            }
        }
    }
}
