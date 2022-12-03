// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./helpers.sol";

contract UCMarket is Helpers {
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
}
