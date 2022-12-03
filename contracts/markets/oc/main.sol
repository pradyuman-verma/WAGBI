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
        address to_
    ) external {
        (uint256 oldRawAmount_, uint256 newRawAmount_, , ) = LIQUIDITY.supply(
            token_,
            amount_,
            msg.sender
        );
        uint256 userAmountsData_ = userAmountsData[to_][token_];
        uint256 userRawSupply_ = unpack(userAmountsData_, 0, 58);
        if (userRawSupply_ == 0) {
            // TODO: add token user supply tokens data
        }
        userAmountsData[to_][token_] = pack(
            userAmountsData_,
            userRawSupply_ + newRawAmount_ - oldRawAmount_,
            0,
            58
        );
    }
}
