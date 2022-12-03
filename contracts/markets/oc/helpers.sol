// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./variables.sol";

contract Helpers is Variables {
    constructor(
        address liquidityAddr_,
        address wethAddr_,
        address usdcAddr_,
        address daiAddr_,
        address wbtcAddr_
    ) Variables(liquidityAddr_, wethAddr_, usdcAddr_, daiAddr_, wbtcAddr_) {}
}
