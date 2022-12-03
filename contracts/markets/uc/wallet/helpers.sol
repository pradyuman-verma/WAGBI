// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./variables.sol";

contract Helpers is Variables {
    constructor(address liquidityPoolAddr_, address oracleAddr_)
        Variables(liquidityPoolAddr_, oracleAddr_)
    {}
}
