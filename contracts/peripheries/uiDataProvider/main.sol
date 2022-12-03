//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces.sol";

contract UIDataProvider {
    ILiquidityPool internal immutable LIQUIDITY_POOL;
    IOC internal immutable OC_MARKET;
    IOracle internal immutable ORACLE;

    address internal immutable WETH_ADDR;
    address internal immutable USDC_ADDR;
    address internal immutable DAI_ADDR;
    address internal immutable WBTC_ADDR;

    constructor(
        address liquidityPoolAddr_,
        address ocMarketAddr_,
        address oracle_,
        address wethAddr_,
        address usdcAddr_,
        address daiAddr_,
        address wbtcAddr_
    ) payable {
        LIQUIDITY_POOL = ILiquidityPool(liquidityPoolAddr_);
        OC_MARKET = IOC(ocMarketAddr_);
        ORACLE = IOracle(oracle_);
        WETH_ADDR = wethAddr_;
        USDC_ADDR = usdcAddr_;
        DAI_ADDR = daiAddr_;
        WBTC_ADDR = wbtcAddr_;
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

    struct LiquidityPoolData {
        Rates supplyRate;
        Rates borrowRate;
    }

    function getLiquidityPoolData()
        public
        view
        returns (LiquidityPoolData memory liquidityPoolData_)
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

    struct UserOCAmountData {
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
        UserOCAmountData supplyAmounts;
        UserOCAmountData supplyAmountsInEth;
        UserOCAmountData borrowAmounts;
        UserOCAmountData borrowAmountsInEth;
        PriceInEth pricesInEth;
        Decimals decimals;
        LiquidityPoolData liquidityPoolData;
        uint256 totalSupplyInEth;
        uint256 totalSupplyInUsd;
        uint256 totalBorrowInEth;
        uint256 totalBorrowInUsd;
        int256 netApy;
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
    }
}
