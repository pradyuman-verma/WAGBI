// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./helpers.sol";

contract OCMarket is Helpers {
    
    modifier nonReentrant() {
        require(_status == 1, "ReentrancyGuard: reentrant call");
        _status = 2;
        _;
        _status = 1;
    }

    constructor(
        address liquidityAddr_,
        address wethAddr_,
        address usdcAddr_,
        address daiAddr_,
        address wbtcAddr_
    ) Helpers(liquidityAddr_, wethAddr_, usdcAddr_, daiAddr_, wbtcAddr_) {
        _status = 1;
    }
}
