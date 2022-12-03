// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./helpers.sol";

contract OCMarket is Helpers {
    constructor(
        address liquidityAddr_,
        address wethAddr_,
        address usdcAddr_,
        address daiAddr_,
        address wbtcAddr_
    ) Helpers(liquidityAddr_, wethAddr_, usdcAddr_, daiAddr_, wbtcAddr_) {
        _status = 1;
    }

    modifier nonReentrant() {
        require(_status == 1, "ReentrancyGuard: reentrant call");
        _status = 2;
        _;
        _status = 1;
    }

    function supply(
        address token_,
        uint256 amount_,
        address for_
    ) external nonReentrant {
        uint256 assetIndex_ = getAssetIndex(token_);

        (uint256 oldRawAmount_, uint256 newRawAmount_, , ) = LIQUIDITY.supply(
            token_,
            amount_,
            msg.sender
        );

        // update user amounts data
        uint256 userAmountsData_ = userAmountsData[for_][token_];
        userAmountsData[for_][token_] = pack(
            userAmountsData_,
            unpack(userAmountsData_, 0, 58) + newRawAmount_ - oldRawAmount_,
            0,
            58
        );

        // update user tokens data
        uint256 userTokensData_ = userTokensData[for_];
        uint256 newUserTokensData_ = addToSupplyTokens(
            userTokensData_,
            assetIndex_
        );
        if (newUserTokensData_ != userTokensData_)
            userTokensData[for_] = newUserTokensData_;
    }

    function withdraw(
        address token_,
        uint256 amount_,
        address to_
    ) external nonReentrant {
        uint256 assetIndex_ = getAssetIndex(token_);

        (uint256 oldRawAmount_, uint256 newRawAmount_, , ) = LIQUIDITY.withdraw(
            token_,
            amount_,
            to_
        );

        // update user amounts data
        uint256 userAmountsData_ = userAmountsData[msg.sender][token_];
        uint256 userFinalSuppliedAmount_ = unpack(userAmountsData_, 0, 58) +
            oldRawAmount_ -
            newRawAmount_;
        userAmountsData[msg.sender][token_] = pack(
            userAmountsData_,
            userFinalSuppliedAmount_,
            0,
            58
        );

        // update user tokens data
        if (userFinalSuppliedAmount_ == 0) {
            uint256 userTokensData_ = userTokensData[msg.sender];
            uint256 newUserTokensData_ = removeFromSupplyTokens(
                userTokensData_,
                assetIndex_
            );
            if (newUserTokensData_ != userTokensData_)
                userTokensData[to_] = newUserTokensData_;
        }

        // TODO: check hf
    }
}
