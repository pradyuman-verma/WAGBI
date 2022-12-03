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
                // TODO:
            }

            // update mapping to remove from hold tokens
            if (removeFromHoldTokens_) {
                // TODO:
            }
            if (walletData_ != walletData) walletData = walletData_;
        }
        // no hf check for supply liquidity
    }
}
