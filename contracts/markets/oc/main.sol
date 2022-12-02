// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces.sol";

contract OCMarket {
    ILiquidity internal immutable LIQUIDITY;

    uint256 internal _status;

    mapping(address => mapping(address => uint256)) public userData;

    modifier nonReentrant() {
        require(_status == 1, "ReentrancyGuard: reentrant call");
        _status = 2;
        _;
        _status = 1;
    }

    constructor(address liquidityPoolAddr_) payable {
        LIQUIDITY = ILiquidity(liquidityPoolAddr_);
    }
}
