// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces.sol";

contract Variables {
    constructor(
        address aaveLendingPoolAddr_,
        address aaveDataProviderAddr_,
        address wethAddr_,
        address usdcAddr_,
        address daiAddr_,
        address wbtcAddr_
    ) {
        AAVE_LENDING_POOL = IAaveLendingPool(aaveLendingPoolAddr_);
        AAVE_DATA_PROVIDER = IAaveDataProvider(aaveDataProviderAddr_);

        WETH_ADDR = wethAddr_;
        WETH_DECIMALS = IERC20(WETH_ADDR).decimals();
        (
            AAVE_WETH_COLLATERAL_TOKEN_ADDR,
            ,
            AAVE_WETH_VARIABLE_DEBT_TOKEN_ADDR
        ) = AAVE_DATA_PROVIDER.getReserveTokensAddresses(WETH_ADDR);

        USDC_ADDR = usdcAddr_;
        USDC_DECIMALS = IERC20(USDC_ADDR).decimals();
        (
            AAVE_USDC_COLLATERAL_TOKEN_ADDR,
            ,
            AAVE_USDC_VARIABLE_DEBT_TOKEN_ADDR
        ) = AAVE_DATA_PROVIDER.getReserveTokensAddresses(USDC_ADDR);

        DAI_ADDR = daiAddr_;
        DAI_DECIMALS = IERC20(DAI_ADDR).decimals();
        (
            AAVE_DAI_COLLATERAL_TOKEN_ADDR,
            ,
            AAVE_DAI_VARIABLE_DEBT_TOKEN_ADDR
        ) = AAVE_DATA_PROVIDER.getReserveTokensAddresses(DAI_ADDR);

        WBTC_ADDR = wbtcAddr_;
        WBTC_DECIMALS = IERC20(WBTC_ADDR).decimals();
        (
            AAVE_WBTC_COLLATERAL_TOKEN_ADDR,
            ,
            AAVE_WBTC_VARIABLE_DEBT_TOKEN_ADDR
        ) = AAVE_DATA_PROVIDER.getReserveTokensAddresses(WBTC_ADDR);
    }

    IAaveLendingPool internal immutable AAVE_LENDING_POOL;
    IAaveDataProvider internal immutable AAVE_DATA_PROVIDER;

    // eth
    address internal immutable WETH_ADDR;
    uint256 internal constant WETH_INDEX = 0;
    uint256 internal immutable WETH_DECIMALS;
    address internal immutable AAVE_WETH_COLLATERAL_TOKEN_ADDR;
    address internal immutable AAVE_WETH_VARIABLE_DEBT_TOKEN_ADDR;

    // usdc
    address internal immutable USDC_ADDR;
    uint256 internal constant USDC_INDEX = 1;
    uint256 internal immutable USDC_DECIMALS;
    address internal immutable AAVE_USDC_COLLATERAL_TOKEN_ADDR;
    address internal immutable AAVE_USDC_VARIABLE_DEBT_TOKEN_ADDR;

    // dai
    address internal immutable DAI_ADDR;
    uint256 internal constant DAI_INDEX = 2;
    uint256 internal immutable DAI_DECIMALS;
    address internal immutable AAVE_DAI_COLLATERAL_TOKEN_ADDR;
    address internal immutable AAVE_DAI_VARIABLE_DEBT_TOKEN_ADDR;

    // wbtc
    address internal immutable WBTC_ADDR;
    uint256 internal constant WBTC_INDEX = 3;
    uint256 internal immutable WBTC_DECIMALS;
    address internal immutable AAVE_WBTC_COLLATERAL_TOKEN_ADDR;
    address internal immutable AAVE_WBTC_VARIABLE_DEBT_TOKEN_ADDR;

    uint16 internal constant REFERRAL_CODE = 0;
    uint256 internal constant MODE = 2;

    // STORAGE VARIABLES
    // User position mapping stored in bits
    // First 50 bits => 0-49 => supply tokens
    // Next 50 bits => 50-99 => borrow tokens
    // Next 50 bits => 100-149 => hold tokens
    // Next 50 bits => 150-199 => aave supply tokens
    // Next 50 bits => 200-249 => aave borrow tokens
    // Last 6 bits left blank
    uint256 public walletData;
}
