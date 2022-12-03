// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces.sol";

contract Variables {
    ILiquidityPool internal immutable LIQUIDITY_POOL;
    IOracle internal immutable ORACLE;

    // TOKENS
    // weth
    address internal immutable WETH_ADDR;
    uint256 internal immutable WETH_DECIMALS;
    uint256 internal constant WETH_INDEX = 0;
    uint256 internal constant WETH_CF = 9000; // 10000 = 100%
    uint256 internal constant WETH_DF = 9000; // 10000 = 100%

    // usdc
    address internal immutable USDC_ADDR;
    uint256 internal immutable USDC_DECIMALS;
    uint256 internal constant USDC_INDEX = 1;
    uint256 internal constant USDC_CF = 9000; // 10000 = 100%
    uint256 internal constant USDC_DF = 9000; // 10000 = 100%

    // dai
    address internal immutable DAI_ADDR;
    uint256 internal immutable DAI_DECIMALS;
    uint256 internal constant DAI_INDEX = 2;
    uint256 internal constant DAI_CF = 9000; // 10000 = 100%
    uint256 internal constant DAI_DF = 9000; // 10000 = 100%

    // wbtc
    address internal immutable WBTC_ADDR;
    uint256 internal immutable WBTC_DECIMALS;
    uint256 internal constant WBTC_INDEX = 3;
    uint256 internal constant WBTC_CF = 9000; // 10000 = 100%
    uint256 internal constant WBTC_DF = 9000; // 10000 = 100%

    uint256 internal constant MIN_HF_THRESHOLD = 1e18;

    // STORAGE VARIABLES

    // status = 2 throws
    uint256 internal _status;

    // User Supply and Borrow Amounts data
    // user => token => uint
    // 2 things stored in a single uint:-
    // First 59 bits => 0-58 => user raw supply (raw supply = totalSupply / supplyExchangePrice)
    // Next 58 bits => 59-116 => user raw borrow (raw borrow = totalBorrow / borrowExchangePrice)
    // Last 139 bits blank
    mapping(address => mapping(address => uint256)) public userAmountsData;

    // User Supply and Borrow Tokens data (Bit mapping)
    // First 128 bits => 0-127 => supply tokens bit mapping
    // Next 128 bits => 128-255 => borrow tokens bit mapping
    mapping(address => uint256) public userTokensData;

    constructor(
        address liquidityPoolAddr_,
        address oracleAddr_,
        address wethAddr_,
        address usdcAddr_,
        address daiAddr_,
        address wbtcAddr_
    ) {
        LIQUIDITY_POOL = ILiquidityPool(liquidityPoolAddr_);
        ORACLE = IOracle(oracleAddr_);
        WETH_ADDR = wethAddr_;
        WETH_DECIMALS = IERC20(WETH_ADDR).decimals();
        USDC_ADDR = usdcAddr_;
        USDC_DECIMALS = IERC20(USDC_ADDR).decimals();
        DAI_ADDR = daiAddr_;
        DAI_DECIMALS = IERC20(DAI_ADDR).decimals();
        WBTC_ADDR = wbtcAddr_;
        WBTC_DECIMALS = IERC20(WBTC_ADDR).decimals();
    }
}
