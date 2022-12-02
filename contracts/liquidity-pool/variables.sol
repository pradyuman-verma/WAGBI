//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces.sol";

contract Variables {
    // TOKENS
    // weth
    address internal immutable WETH_ADDR;
    uint256 internal immutable WETH_DECIMALS;
    uint256 internal immutable WETH_BORROW_ALLOWANCE;

    // usdc
    address internal immutable USDC_ADDR;
    uint256 internal immutable USDC_DECIMALS;
    uint256 internal immutable USDC_BORROW_ALLOWANCE;

    // dai
    address internal immutable DAI_ADDR;
    uint256 internal immutable DAI_DECIMALS;
    uint256 internal immutable DAI_BORROW_ALLOWANCE;

    // wbtc
    address internal immutable WBTC_ADDR;
    uint256 internal immutable WBTC_DECIMALS;
    uint256 internal immutable WBTC_BORROW_ALLOWANCE;

    // RATE CURVE DATA
    uint256 internal constant SLOPE_1 = 0; // TODO:
    uint256 internal constant CONSTANT_1 = 0; // TODO:
    uint256 internal constant SIGN_1 = 0; // TODO:
    uint256 internal constant KINK = 8000; // 10000 => 100%
    uint256 internal constant SLOPE_2 = 0; // TODO:
    uint256 internal constant CONSTANT_2 = 0; // TODO:
    uint256 internal constant SIGN_2 = 0; // TODO:
    uint256 internal constant FEE = 1000; // 10000 => 100%

    // STORAGE VARIABLES

    uint256 internal _status;

    mapping(address => address) public _userToProtocol;
}
