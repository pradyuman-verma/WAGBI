//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces.sol";

contract UIDataProvider {
    ILiquidityPool internal immutable LIQUIDITY_POOL;
    IOC internal immutable OC_MARKET;
    IOracle internal immutable ORACLE;
    IAaveDataProvider internal immutable AAVE_DATA_PROVIDER;
    IWalletFactory internal immutable UC_WALLET_FACTORY;
    IAaveLendingPool internal immutable AAVE_LENDING_POOL;

    address internal immutable WETH_ADDR;
    address internal immutable AAVE_WETH_COLLATERAL_TOKEN_ADDR;
    address internal immutable AAVE_WETH_VARIABLE_DEBT_TOKEN_ADDR;
    address internal immutable USDC_ADDR;
    address internal immutable AAVE_USDC_COLLATERAL_TOKEN_ADDR;
    address internal immutable AAVE_USDC_VARIABLE_DEBT_TOKEN_ADDR;
    address internal immutable DAI_ADDR;
    address internal immutable AAVE_DAI_COLLATERAL_TOKEN_ADDR;
    address internal immutable AAVE_DAI_VARIABLE_DEBT_TOKEN_ADDR;
    address internal immutable WBTC_ADDR;
    address internal immutable AAVE_WBTC_COLLATERAL_TOKEN_ADDR;
    address internal immutable AAVE_WBTC_VARIABLE_DEBT_TOKEN_ADDR;

    constructor(
        address liquidityPoolAddr_,
        address ocMarketAddr_,
        address oracle_,
        address aaveDataProvider_,
        address ucWalletFactory_,
        address aaveLendingPool,
        address wethAddr_,
        address usdcAddr_,
        address daiAddr_,
        address wbtcAddr_
    ) payable {
        LIQUIDITY_POOL = ILiquidityPool(liquidityPoolAddr_);
        OC_MARKET = IOC(ocMarketAddr_);
        ORACLE = IOracle(oracle_);
        AAVE_DATA_PROVIDER = IAaveDataProvider(aaveDataProvider_);
        UC_WALLET_FACTORY = IWalletFactory(ucWalletFactory_);
        AAVE_LENDING_POOL = IAaveLendingPool(aaveLendingPool);

        WETH_ADDR = wethAddr_;
        (
            AAVE_WETH_COLLATERAL_TOKEN_ADDR,
            ,
            AAVE_WETH_VARIABLE_DEBT_TOKEN_ADDR
        ) = AAVE_DATA_PROVIDER.getReserveTokensAddresses(WETH_ADDR);
        USDC_ADDR = usdcAddr_;
        (
            AAVE_USDC_COLLATERAL_TOKEN_ADDR,
            ,
            AAVE_USDC_VARIABLE_DEBT_TOKEN_ADDR
        ) = AAVE_DATA_PROVIDER.getReserveTokensAddresses(USDC_ADDR);
        DAI_ADDR = daiAddr_;
        (
            AAVE_DAI_COLLATERAL_TOKEN_ADDR,
            ,
            AAVE_DAI_VARIABLE_DEBT_TOKEN_ADDR
        ) = AAVE_DATA_PROVIDER.getReserveTokensAddresses(DAI_ADDR);
        WBTC_ADDR = wbtcAddr_;
        (
            AAVE_WBTC_COLLATERAL_TOKEN_ADDR,
            ,
            AAVE_WBTC_VARIABLE_DEBT_TOKEN_ADDR
        ) = AAVE_DATA_PROVIDER.getReserveTokensAddresses(WBTC_ADDR);
    }

    struct PriceInEth {
        uint256 weth;
        uint256 usdc;
        uint256 dai;
        uint256 wbtc;
    }

    function getPrices() public view returns (PriceInEth memory pricesInEth_) {
        pricesInEth_.weth = ORACLE.getPriceInEth(WETH_ADDR);
        pricesInEth_.usdc = ORACLE.getPriceInEth(USDC_ADDR);
        pricesInEth_.dai = ORACLE.getPriceInEth(DAI_ADDR);
        pricesInEth_.wbtc = ORACLE.getPriceInEth(WBTC_ADDR);
    }

    struct Rates {
        uint256 weth;
        uint256 usdc;
        uint256 dai;
        uint256 wbtc;
    }

    struct PoolData {
        Rates supplyRate;
        Rates borrowRate;
    }

    function getLiquidityPoolData()
        public
        view
        returns (PoolData memory liquidityPoolData_)
    {
        (
            liquidityPoolData_.supplyRate.weth,
            liquidityPoolData_.borrowRate.weth
        ) = LIQUIDITY_POOL.getRates(WETH_ADDR);
        (
            liquidityPoolData_.supplyRate.usdc,
            liquidityPoolData_.borrowRate.usdc
        ) = LIQUIDITY_POOL.getRates(USDC_ADDR);
        (
            liquidityPoolData_.supplyRate.dai,
            liquidityPoolData_.borrowRate.dai
        ) = LIQUIDITY_POOL.getRates(DAI_ADDR);
        (
            liquidityPoolData_.supplyRate.wbtc,
            liquidityPoolData_.borrowRate.wbtc
        ) = LIQUIDITY_POOL.getRates(WBTC_ADDR);
    }

    function getAavePoolData()
        public
        view
        returns (PoolData memory aavePoolData_)
    {
        uint256 supplyRate_;
        uint256 borrowRate_;

        (, , , supplyRate_, borrowRate_, , , , , ) = AAVE_DATA_PROVIDER
            .getReserveData(WETH_ADDR);
        aavePoolData_.supplyRate.weth = supplyRate_ / 1e9;
        aavePoolData_.borrowRate.weth = borrowRate_ / 1e9;

        (, , , supplyRate_, borrowRate_, , , , , ) = AAVE_DATA_PROVIDER
            .getReserveData(USDC_ADDR);
        aavePoolData_.supplyRate.usdc = supplyRate_ / 1e9;
        aavePoolData_.borrowRate.usdc = borrowRate_ / 1e9;

        (, , , supplyRate_, borrowRate_, , , , , ) = AAVE_DATA_PROVIDER
            .getReserveData(DAI_ADDR);
        aavePoolData_.supplyRate.dai = supplyRate_ / 1e9;
        aavePoolData_.borrowRate.dai = borrowRate_ / 1e9;

        (, , , supplyRate_, borrowRate_, , , , , ) = AAVE_DATA_PROVIDER
            .getReserveData(WBTC_ADDR);
        aavePoolData_.supplyRate.wbtc = supplyRate_ / 1e9;
        aavePoolData_.borrowRate.wbtc = borrowRate_ / 1e9;
    }

    struct Balances {
        uint256 weth;
        uint256 usdc;
        uint256 dai;
        uint256 wbtc;
    }

    function getUserBalances(address user_)
        public
        view
        returns (Balances memory balances_)
    {
        balances_.weth = IERC20(WETH_ADDR).balanceOf(user_);
        balances_.usdc = IERC20(USDC_ADDR).balanceOf(user_);
        balances_.dai = IERC20(DAI_ADDR).balanceOf(user_);
        balances_.wbtc = IERC20(WBTC_ADDR).balanceOf(user_);
    }

    struct UserAmountData {
        uint256 weth;
        uint256 usdc;
        uint256 dai;
        uint256 wbtc;
    }

    struct Decimals {
        uint256 weth;
        uint256 usdc;
        uint256 dai;
        uint256 wbtc;
    }

    struct UserOCData {
        UserAmountData supplyAmounts;
        UserAmountData supplyAmountsInEth;
        UserAmountData borrowAmounts;
        UserAmountData borrowAmountsInEth;
        PriceInEth pricesInEth;
        Decimals decimals;
        PoolData liquidityPoolData;
        uint256 totalSupplyInEth;
        uint256 totalSupplyInUsd;
        uint256 totalBorrowInEth;
        uint256 totalBorrowInUsd;
        int256 netApy;
        uint256 healthFactor;
    }

    function getUserOCData(address user_)
        public
        view
        returns (UserOCData memory userOcData_)
    {
        // supply amounts
        userOcData_.supplyAmounts.weth = OC_MARKET.getSupplyAmount(
            user_,
            WETH_ADDR
        );
        userOcData_.supplyAmounts.usdc = OC_MARKET.getSupplyAmount(
            user_,
            USDC_ADDR
        );
        userOcData_.supplyAmounts.dai = OC_MARKET.getSupplyAmount(
            user_,
            DAI_ADDR
        );
        userOcData_.supplyAmounts.wbtc = OC_MARKET.getSupplyAmount(
            user_,
            WBTC_ADDR
        );

        // borrow amounts
        userOcData_.borrowAmounts.weth = OC_MARKET.getBorrowAmount(
            user_,
            WETH_ADDR
        );
        userOcData_.borrowAmounts.usdc = OC_MARKET.getBorrowAmount(
            user_,
            USDC_ADDR
        );
        userOcData_.borrowAmounts.dai = OC_MARKET.getBorrowAmount(
            user_,
            DAI_ADDR
        );
        userOcData_.borrowAmounts.wbtc = OC_MARKET.getBorrowAmount(
            user_,
            WBTC_ADDR
        );

        // prices
        userOcData_.pricesInEth = getPrices();

        // decimals
        userOcData_.decimals.weth = IERC20(WETH_ADDR).decimals();
        userOcData_.decimals.usdc = IERC20(USDC_ADDR).decimals();
        userOcData_.decimals.dai = IERC20(DAI_ADDR).decimals();
        userOcData_.decimals.wbtc = IERC20(WBTC_ADDR).decimals();

        // liquidity pool data for rates
        userOcData_.liquidityPoolData = getLiquidityPoolData();

        // supply amounts in eth
        userOcData_.supplyAmountsInEth.weth =
            (userOcData_.supplyAmounts.weth * userOcData_.pricesInEth.weth) /
            (10**userOcData_.decimals.weth);
        userOcData_.supplyAmountsInEth.usdc =
            (userOcData_.supplyAmounts.usdc * userOcData_.pricesInEth.usdc) /
            (10**userOcData_.decimals.usdc);
        userOcData_.supplyAmountsInEth.dai =
            (userOcData_.supplyAmounts.dai * userOcData_.pricesInEth.dai) /
            (10**userOcData_.decimals.dai);
        userOcData_.supplyAmountsInEth.wbtc =
            (userOcData_.supplyAmounts.wbtc * userOcData_.pricesInEth.wbtc) /
            (10**userOcData_.decimals.wbtc);

        // total supply in eth
        // in 18 decimals
        userOcData_.totalSupplyInEth =
            userOcData_.supplyAmountsInEth.weth +
            userOcData_.supplyAmountsInEth.usdc +
            userOcData_.supplyAmountsInEth.dai +
            userOcData_.supplyAmountsInEth.wbtc;

        // total supply in usd
        // in 18 decimals
        userOcData_.totalSupplyInUsd =
            (userOcData_.totalSupplyInEth * 1e18) /
            userOcData_.pricesInEth.usdc;

        // borrow amounts in eth
        userOcData_.borrowAmountsInEth.weth =
            (userOcData_.borrowAmounts.weth * userOcData_.pricesInEth.weth) /
            (10**userOcData_.decimals.weth);
        userOcData_.borrowAmountsInEth.usdc =
            (userOcData_.borrowAmounts.usdc * userOcData_.pricesInEth.usdc) /
            (10**userOcData_.decimals.usdc);
        userOcData_.borrowAmountsInEth.dai =
            (userOcData_.borrowAmounts.dai * userOcData_.pricesInEth.dai) /
            (10**userOcData_.decimals.dai);
        userOcData_.borrowAmountsInEth.wbtc =
            (userOcData_.borrowAmounts.wbtc * userOcData_.pricesInEth.wbtc) /
            (10**userOcData_.decimals.wbtc);

        // total borrow in eth
        // in 18 decimals
        userOcData_.totalBorrowInEth =
            userOcData_.borrowAmountsInEth.weth +
            userOcData_.borrowAmountsInEth.usdc +
            userOcData_.borrowAmountsInEth.dai +
            userOcData_.borrowAmountsInEth.wbtc;

        // total borrow in usd
        // in 18 decimals
        userOcData_.totalBorrowInUsd =
            (userOcData_.totalBorrowInEth * 1e18) /
            userOcData_.pricesInEth.usdc;

        // net apy calc
        // numerator
        int256 numerator_ = int256(
            userOcData_.supplyAmountsInEth.weth *
                userOcData_.liquidityPoolData.supplyRate.weth
        );
        numerator_ =
            numerator_ +
            int256(
                userOcData_.supplyAmountsInEth.usdc *
                    userOcData_.liquidityPoolData.supplyRate.usdc
            );
        numerator_ =
            numerator_ +
            int256(
                userOcData_.supplyAmountsInEth.dai *
                    userOcData_.liquidityPoolData.supplyRate.dai
            );
        numerator_ =
            numerator_ +
            int256(
                userOcData_.supplyAmountsInEth.wbtc *
                    userOcData_.liquidityPoolData.supplyRate.wbtc
            );

        numerator_ =
            numerator_ -
            int256(
                userOcData_.borrowAmountsInEth.weth *
                    userOcData_.liquidityPoolData.borrowRate.weth
            );
        numerator_ =
            numerator_ -
            int256(
                userOcData_.borrowAmountsInEth.usdc *
                    userOcData_.liquidityPoolData.borrowRate.usdc
            );
        numerator_ =
            numerator_ -
            int256(
                userOcData_.borrowAmountsInEth.dai *
                    userOcData_.liquidityPoolData.borrowRate.dai
            );
        numerator_ =
            numerator_ -
            int256(
                userOcData_.borrowAmountsInEth.wbtc *
                    userOcData_.liquidityPoolData.borrowRate.wbtc
            );

        // denominator
        uint256 denominator_ = userOcData_.totalSupplyInEth -
            userOcData_.totalBorrowInEth;

        userOcData_.netApy = numerator_ / int256(denominator_);

        userOcData_.healthFactor = OC_MARKET.getHf(user_);
    }

    struct UserUcWalletData {
        UserAmountData supplyAmounts;
        UserAmountData supplyAmountsInEth;
        UserAmountData borrowAmounts;
        UserAmountData borrowAmountsInEth;
        UserAmountData holdAmounts;
        UserAmountData holdAmountsInEth;
        UserAmountData aaveSupplyAmounts;
        UserAmountData aaveSupplyAmountsInEth;
        UserAmountData aaveBorrowAmounts;
        UserAmountData aaveBorrowAmountsInEth;
        PriceInEth pricesInEth;
        Decimals decimals;
        PoolData liquidityPoolData;
        PoolData aavePoolData;
        uint256 totalSupplyInEth;
        uint256 totalSupplyInUsd;
        uint256 totalBorrowInEth;
        uint256 totalBorrowInUsd;
        uint256 totalHoldInEth;
        uint256 totalHoldInUsd;
        uint256 totalAaveSupplyInEth;
        uint256 totalAaveSupplyInUsd;
        uint256 totalAaveBorrowInEth;
        uint256 totalAaveBorrowInUsd;
        int256 netApy;
        uint256 healthFactor;
        uint256 aaveHealthFactor;
    }

    function getUCWalletData(address wallet_)
        public
        view
        returns (UserUcWalletData memory userUcWalletData_)
    {
        // supply amounts
        (, userUcWalletData_.supplyAmounts.weth) = LIQUIDITY_POOL
            .getUserSupplyAmount(wallet_, WETH_ADDR);
        (, userUcWalletData_.supplyAmounts.usdc) = LIQUIDITY_POOL
            .getUserSupplyAmount(wallet_, USDC_ADDR);
        (, userUcWalletData_.supplyAmounts.dai) = LIQUIDITY_POOL
            .getUserSupplyAmount(wallet_, DAI_ADDR);
        (, userUcWalletData_.supplyAmounts.wbtc) = LIQUIDITY_POOL
            .getUserSupplyAmount(wallet_, WBTC_ADDR);

        // borrow amounts
        (, userUcWalletData_.borrowAmounts.weth) = LIQUIDITY_POOL
            .getUserBorrowAmount(wallet_, WETH_ADDR);
        (, userUcWalletData_.borrowAmounts.usdc) = LIQUIDITY_POOL
            .getUserBorrowAmount(wallet_, USDC_ADDR);
        (, userUcWalletData_.borrowAmounts.dai) = LIQUIDITY_POOL
            .getUserBorrowAmount(wallet_, DAI_ADDR);
        (, userUcWalletData_.borrowAmounts.wbtc) = LIQUIDITY_POOL
            .getUserBorrowAmount(wallet_, WBTC_ADDR);

        // hold amounts
        userUcWalletData_.holdAmounts.weth = IERC20(WETH_ADDR).balanceOf(
            wallet_
        );
        userUcWalletData_.holdAmounts.usdc = IERC20(USDC_ADDR).balanceOf(
            wallet_
        );
        userUcWalletData_.holdAmounts.dai = IERC20(DAI_ADDR).balanceOf(wallet_);
        userUcWalletData_.holdAmounts.wbtc = IERC20(WBTC_ADDR).balanceOf(
            wallet_
        );

        // aave supply amounts
        userUcWalletData_.holdAmounts.weth = IERC20(
            AAVE_WETH_COLLATERAL_TOKEN_ADDR
        ).balanceOf(wallet_);
        userUcWalletData_.holdAmounts.usdc = IERC20(
            AAVE_USDC_COLLATERAL_TOKEN_ADDR
        ).balanceOf(wallet_);
        userUcWalletData_.holdAmounts.dai = IERC20(
            AAVE_DAI_COLLATERAL_TOKEN_ADDR
        ).balanceOf(wallet_);
        userUcWalletData_.holdAmounts.wbtc = IERC20(
            AAVE_WBTC_COLLATERAL_TOKEN_ADDR
        ).balanceOf(wallet_);

        // aave borrow amounts
        userUcWalletData_.holdAmounts.weth = IERC20(
            AAVE_WETH_VARIABLE_DEBT_TOKEN_ADDR
        ).balanceOf(wallet_);
        userUcWalletData_.holdAmounts.usdc = IERC20(
            AAVE_USDC_VARIABLE_DEBT_TOKEN_ADDR
        ).balanceOf(wallet_);
        userUcWalletData_.holdAmounts.dai = IERC20(
            AAVE_DAI_VARIABLE_DEBT_TOKEN_ADDR
        ).balanceOf(wallet_);
        userUcWalletData_.holdAmounts.wbtc = IERC20(
            AAVE_WBTC_VARIABLE_DEBT_TOKEN_ADDR
        ).balanceOf(wallet_);

        // prices
        userUcWalletData_.pricesInEth = getPrices();

        // decimals
        userUcWalletData_.decimals.weth = IERC20(WETH_ADDR).decimals();
        userUcWalletData_.decimals.usdc = IERC20(USDC_ADDR).decimals();
        userUcWalletData_.decimals.dai = IERC20(DAI_ADDR).decimals();
        userUcWalletData_.decimals.wbtc = IERC20(WBTC_ADDR).decimals();

        // liquidity pool data for rates
        userUcWalletData_.liquidityPoolData = getLiquidityPoolData();

        // aave pool data for rates
        userUcWalletData_.aavePoolData = getAavePoolData();

        // supply amounts in eth
        userUcWalletData_.supplyAmountsInEth.weth =
            (userUcWalletData_.supplyAmounts.weth *
                userUcWalletData_.pricesInEth.weth) /
            (10**userUcWalletData_.decimals.weth);
        userUcWalletData_.supplyAmountsInEth.usdc =
            (userUcWalletData_.supplyAmounts.usdc *
                userUcWalletData_.pricesInEth.usdc) /
            (10**userUcWalletData_.decimals.usdc);
        userUcWalletData_.supplyAmountsInEth.dai =
            (userUcWalletData_.supplyAmounts.dai *
                userUcWalletData_.pricesInEth.dai) /
            (10**userUcWalletData_.decimals.dai);
        userUcWalletData_.supplyAmountsInEth.wbtc =
            (userUcWalletData_.supplyAmounts.wbtc *
                userUcWalletData_.pricesInEth.wbtc) /
            (10**userUcWalletData_.decimals.wbtc);

        // total supply in eth
        // in 18 decimals
        userUcWalletData_.totalSupplyInEth =
            userUcWalletData_.supplyAmountsInEth.weth +
            userUcWalletData_.supplyAmountsInEth.usdc +
            userUcWalletData_.supplyAmountsInEth.dai +
            userUcWalletData_.supplyAmountsInEth.wbtc;

        // total supply in usd
        // in 18 decimals
        userUcWalletData_.totalSupplyInUsd =
            (userUcWalletData_.totalSupplyInEth * 1e18) /
            userUcWalletData_.pricesInEth.usdc;

        // borrow amounts in eth
        userUcWalletData_.borrowAmountsInEth.weth =
            (userUcWalletData_.borrowAmounts.weth *
                userUcWalletData_.pricesInEth.weth) /
            (10**userUcWalletData_.decimals.weth);
        userUcWalletData_.borrowAmountsInEth.usdc =
            (userUcWalletData_.borrowAmounts.usdc *
                userUcWalletData_.pricesInEth.usdc) /
            (10**userUcWalletData_.decimals.usdc);
        userUcWalletData_.borrowAmountsInEth.dai =
            (userUcWalletData_.borrowAmounts.dai *
                userUcWalletData_.pricesInEth.dai) /
            (10**userUcWalletData_.decimals.dai);
        userUcWalletData_.borrowAmountsInEth.wbtc =
            (userUcWalletData_.borrowAmounts.wbtc *
                userUcWalletData_.pricesInEth.wbtc) /
            (10**userUcWalletData_.decimals.wbtc);

        // total borrow in eth
        // in 18 decimals
        userUcWalletData_.totalBorrowInEth =
            userUcWalletData_.borrowAmountsInEth.weth +
            userUcWalletData_.borrowAmountsInEth.usdc +
            userUcWalletData_.borrowAmountsInEth.dai +
            userUcWalletData_.borrowAmountsInEth.wbtc;

        // total borrow in usd
        // in 18 decimals
        userUcWalletData_.totalBorrowInUsd =
            (userUcWalletData_.totalBorrowInEth * 1e18) /
            userUcWalletData_.pricesInEth.usdc;

        // hold amounts in eth
        userUcWalletData_.holdAmountsInEth.weth =
            (userUcWalletData_.holdAmounts.weth *
                userUcWalletData_.pricesInEth.weth) /
            (10**userUcWalletData_.decimals.weth);
        userUcWalletData_.holdAmountsInEth.usdc =
            (userUcWalletData_.holdAmounts.usdc *
                userUcWalletData_.pricesInEth.usdc) /
            (10**userUcWalletData_.decimals.usdc);
        userUcWalletData_.holdAmountsInEth.dai =
            (userUcWalletData_.holdAmounts.dai *
                userUcWalletData_.pricesInEth.dai) /
            (10**userUcWalletData_.decimals.dai);
        userUcWalletData_.holdAmountsInEth.wbtc =
            (userUcWalletData_.holdAmounts.wbtc *
                userUcWalletData_.pricesInEth.wbtc) /
            (10**userUcWalletData_.decimals.wbtc);

        // total hold in eth
        // in 18 decimals
        userUcWalletData_.totalHoldInEth =
            userUcWalletData_.holdAmountsInEth.weth +
            userUcWalletData_.holdAmountsInEth.usdc +
            userUcWalletData_.holdAmountsInEth.dai +
            userUcWalletData_.holdAmountsInEth.wbtc;

        // total hold in usd
        // in 18 decimals
        userUcWalletData_.totalHoldInUsd =
            (userUcWalletData_.totalHoldInEth * 1e18) /
            userUcWalletData_.pricesInEth.usdc;

        // aave supply amounts in eth
        userUcWalletData_.aaveSupplyAmountsInEth.weth =
            (userUcWalletData_.aaveSupplyAmounts.weth *
                userUcWalletData_.pricesInEth.weth) /
            (10**userUcWalletData_.decimals.weth);
        userUcWalletData_.aaveSupplyAmountsInEth.usdc =
            (userUcWalletData_.aaveSupplyAmounts.usdc *
                userUcWalletData_.pricesInEth.usdc) /
            (10**userUcWalletData_.decimals.usdc);
        userUcWalletData_.aaveSupplyAmountsInEth.dai =
            (userUcWalletData_.aaveSupplyAmounts.dai *
                userUcWalletData_.pricesInEth.dai) /
            (10**userUcWalletData_.decimals.dai);
        userUcWalletData_.aaveSupplyAmountsInEth.wbtc =
            (userUcWalletData_.aaveSupplyAmounts.wbtc *
                userUcWalletData_.pricesInEth.wbtc) /
            (10**userUcWalletData_.decimals.wbtc);

        // total aave supply in eth
        // in 18 decimals
        userUcWalletData_.totalAaveSupplyInEth =
            userUcWalletData_.aaveSupplyAmountsInEth.weth +
            userUcWalletData_.aaveSupplyAmountsInEth.usdc +
            userUcWalletData_.aaveSupplyAmountsInEth.dai +
            userUcWalletData_.aaveSupplyAmountsInEth.wbtc;

        // total aave supply in usd
        // in 18 decimals
        userUcWalletData_.totalAaveSupplyInUsd =
            (userUcWalletData_.totalAaveSupplyInEth * 1e18) /
            userUcWalletData_.pricesInEth.usdc;

        // aave borrow amounts in eth
        userUcWalletData_.aaveBorrowAmountsInEth.weth =
            (userUcWalletData_.aaveBorrowAmounts.weth *
                userUcWalletData_.pricesInEth.weth) /
            (10**userUcWalletData_.decimals.weth);
        userUcWalletData_.aaveBorrowAmountsInEth.usdc =
            (userUcWalletData_.aaveBorrowAmounts.usdc *
                userUcWalletData_.pricesInEth.usdc) /
            (10**userUcWalletData_.decimals.usdc);
        userUcWalletData_.aaveBorrowAmountsInEth.dai =
            (userUcWalletData_.aaveBorrowAmounts.dai *
                userUcWalletData_.pricesInEth.dai) /
            (10**userUcWalletData_.decimals.dai);
        userUcWalletData_.aaveBorrowAmountsInEth.wbtc =
            (userUcWalletData_.aaveBorrowAmounts.wbtc *
                userUcWalletData_.pricesInEth.wbtc) /
            (10**userUcWalletData_.decimals.wbtc);

        // total aave borrow in eth
        // in 18 decimals
        userUcWalletData_.totalAaveBorrowInEth =
            userUcWalletData_.aaveBorrowAmountsInEth.weth +
            userUcWalletData_.aaveBorrowAmountsInEth.usdc +
            userUcWalletData_.aaveBorrowAmountsInEth.dai +
            userUcWalletData_.aaveBorrowAmountsInEth.wbtc;

        // total aave borrow in usd
        // in 18 decimals
        userUcWalletData_.totalAaveBorrowInUsd =
            (userUcWalletData_.totalAaveBorrowInEth * 1e18) /
            userUcWalletData_.pricesInEth.usdc;

        // net apy calc
        // numerator
        int256 numerator_ = int256(
            userUcWalletData_.supplyAmountsInEth.weth *
                userUcWalletData_.liquidityPoolData.supplyRate.weth
        );
        numerator_ =
            numerator_ +
            int256(
                userUcWalletData_.supplyAmountsInEth.usdc *
                    userUcWalletData_.liquidityPoolData.supplyRate.usdc
            );
        numerator_ =
            numerator_ +
            int256(
                userUcWalletData_.supplyAmountsInEth.dai *
                    userUcWalletData_.liquidityPoolData.supplyRate.dai
            );
        numerator_ =
            numerator_ +
            int256(
                userUcWalletData_.supplyAmountsInEth.wbtc *
                    userUcWalletData_.liquidityPoolData.supplyRate.wbtc
            );

        numerator_ = int256(
            userUcWalletData_.aaveSupplyAmountsInEth.weth *
                userUcWalletData_.aavePoolData.supplyRate.weth
        );
        numerator_ =
            numerator_ +
            int256(
                userUcWalletData_.aaveSupplyAmountsInEth.usdc *
                    userUcWalletData_.aavePoolData.supplyRate.usdc
            );
        numerator_ =
            numerator_ +
            int256(
                userUcWalletData_.aaveSupplyAmountsInEth.dai *
                    userUcWalletData_.aavePoolData.supplyRate.dai
            );
        numerator_ =
            numerator_ +
            int256(
                userUcWalletData_.aaveSupplyAmountsInEth.wbtc *
                    userUcWalletData_.aavePoolData.supplyRate.wbtc
            );

        numerator_ =
            numerator_ -
            int256(
                userUcWalletData_.borrowAmountsInEth.weth *
                    userUcWalletData_.liquidityPoolData.borrowRate.weth
            );
        numerator_ =
            numerator_ -
            int256(
                userUcWalletData_.borrowAmountsInEth.usdc *
                    userUcWalletData_.liquidityPoolData.borrowRate.usdc
            );
        numerator_ =
            numerator_ -
            int256(
                userUcWalletData_.borrowAmountsInEth.dai *
                    userUcWalletData_.liquidityPoolData.borrowRate.dai
            );
        numerator_ =
            numerator_ -
            int256(
                userUcWalletData_.borrowAmountsInEth.wbtc *
                    userUcWalletData_.liquidityPoolData.borrowRate.wbtc
            );

        numerator_ =
            numerator_ -
            int256(
                userUcWalletData_.aaveBorrowAmountsInEth.weth *
                    userUcWalletData_.aavePoolData.borrowRate.weth
            );
        numerator_ =
            numerator_ -
            int256(
                userUcWalletData_.aaveBorrowAmountsInEth.usdc *
                    userUcWalletData_.aavePoolData.borrowRate.usdc
            );
        numerator_ =
            numerator_ -
            int256(
                userUcWalletData_.aaveBorrowAmountsInEth.dai *
                    userUcWalletData_.aavePoolData.borrowRate.dai
            );
        numerator_ =
            numerator_ -
            int256(
                userUcWalletData_.aaveBorrowAmountsInEth.wbtc *
                    userUcWalletData_.aavePoolData.borrowRate.wbtc
            );

        // denominator
        uint256 denominator_ = userUcWalletData_.totalSupplyInEth +
            userUcWalletData_.totalHoldInEth +
            userUcWalletData_.totalAaveSupplyInEth -
            userUcWalletData_.totalBorrowInEth -
            userUcWalletData_.totalAaveBorrowInEth;

        userUcWalletData_.netApy = numerator_ / int256(denominator_);

        userUcWalletData_.healthFactor = IWallet(wallet_).getHf();
        (, , , , , userUcWalletData_.aaveHealthFactor) = AAVE_LENDING_POOL
            .getUserAccountData(wallet_);
    }

    function getUCUserData(address user_)
        external
        view
        returns (
            uint256 totalSupplyInUsd_,
            uint256 totalBorrowInUsd_,
            int256 totalApy_,
            UserUcWalletData[] memory positions_
        )
    {
        address[] memory wallets_ = UC_WALLET_FACTORY.authToWallet(user_);
        int256 numerator_;
        uint256 denominator_;
        for (uint256 i; i < wallets_.length; ) {
            positions_[i] = getUCWalletData(wallets_[i]);
            uint256 positionTotalSupplyInUsd_ = positions_[i].totalSupplyInUsd +
                positions_[i].totalHoldInUsd +
                positions_[i].totalAaveSupplyInUsd;

            uint256 positionTotalBorrowInUsd_ = positions_[i].totalBorrowInUsd +
                positions_[i].totalAaveBorrowInUsd;

            totalSupplyInUsd_ += positionTotalSupplyInUsd_;
            totalBorrowInUsd_ += positionTotalBorrowInUsd_;

            numerator_ +=
                (int256(positionTotalSupplyInUsd_) -
                    int256(positionTotalBorrowInUsd_)) *
                positions_[i].netApy;

            denominator_ = denominator_ + totalSupplyInUsd_ - totalBorrowInUsd_;

            unchecked {
                ++i;
            }
        }
        totalApy_ = numerator_ / int256(denominator_);
    }
}
