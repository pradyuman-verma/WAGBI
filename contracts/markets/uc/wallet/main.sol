// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./helpers.sol";

contract UCMarket is Helpers {
    constructor(address liquidityPoolAddr_, address oracleAddr_)
        Helpers(liquidityPoolAddr_, oracleAddr_)
    {}
}
