// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces.sol";

contract OCMarket {
    ILiquidity internal immutable LIQUIDITY;

    uint256 internal _status;

    // User Supply and Borrow amounts data
    // user => token => uint
    // 2 things stored in a single uint:-
    // First 59 bits => 0-58 => user raw supply (raw supply = totalSupply / supplyExchangePrice)
    // Next 58 bits => 59-116 => user raw borrow (raw borrow = totalBorrow / borrowExchangePrice)
    // Last 139 bits blank
    mapping(address => mapping(address => uint256)) public userAmountsData;

    mapping(address => uint256) public userTokensData; // TODO: This will store in which tokens a user supplied in bits

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
