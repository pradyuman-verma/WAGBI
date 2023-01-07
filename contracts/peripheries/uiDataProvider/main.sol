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
        UserAmountData borrowAmounts;
        uint256 totalSupplyInUsd;
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
        PriceInEth memory pricesInEth_ = getPrices();

        // decimals
        Decimals memory decimals_;
        decimals_.weth = IERC20(WETH_ADDR).decimals();
        decimals_.usdc = IERC20(USDC_ADDR).decimals();
        decimals_.dai = IERC20(DAI_ADDR).decimals();
        decimals_.wbtc = IERC20(WBTC_ADDR).decimals();

        // liquidity pool data for rates
        PoolData memory liquidityPoolData_ = getLiquidityPoolData();

        // supply amounts in eth
        UserAmountData memory supplyAmountsInEth_;
        supplyAmountsInEth_.weth =
            (userOcData_.supplyAmounts.weth * pricesInEth_.weth) /
            (10**decimals_.weth);
        supplyAmountsInEth_.usdc =
            (userOcData_.supplyAmounts.usdc * pricesInEth_.usdc) /
            (10**decimals_.usdc);
        supplyAmountsInEth_.dai =
            (userOcData_.supplyAmounts.dai * pricesInEth_.dai) /
            (10**decimals_.dai);
        supplyAmountsInEth_.wbtc =
            (userOcData_.supplyAmounts.wbtc * pricesInEth_.wbtc) /
            (10**decimals_.wbtc);

        // total supply in eth
        // in 18 decimals
        uint256 totalSupplyInEth_ = supplyAmountsInEth_.weth +
            supplyAmountsInEth_.usdc +
            supplyAmountsInEth_.dai +
            supplyAmountsInEth_.wbtc;

        // total supply in usd
        // in 18 decimals
        userOcData_.totalSupplyInUsd = pricesInEth_.usdc == 0
            ? 0
            : (totalSupplyInEth_ * 1e18) / pricesInEth_.usdc;

        // borrow amounts in eth
        UserAmountData memory borrowAmountsInEth_;
        borrowAmountsInEth_.weth =
            (userOcData_.borrowAmounts.weth * pricesInEth_.weth) /
            (10**decimals_.weth);
        borrowAmountsInEth_.usdc =
            (userOcData_.borrowAmounts.usdc * pricesInEth_.usdc) /
            (10**decimals_.usdc);
        borrowAmountsInEth_.dai =
            (userOcData_.borrowAmounts.dai * pricesInEth_.dai) /
            (10**decimals_.dai);
        borrowAmountsInEth_.wbtc =
            (userOcData_.borrowAmounts.wbtc * pricesInEth_.wbtc) /
            (10**decimals_.wbtc);

        // total borrow in eth
        // in 18 decimals
        uint256 totalBorrowInEth_ = borrowAmountsInEth_.weth +
            borrowAmountsInEth_.usdc +
            borrowAmountsInEth_.dai +
            borrowAmountsInEth_.wbtc;

        // total borrow in usd
        // in 18 decimals
        userOcData_.totalBorrowInUsd = pricesInEth_.usdc == 0
            ? 0
            : (totalBorrowInEth_ * 1e18) / pricesInEth_.usdc;

        // net apy calc
        // numerator
        int256 numerator_ = int256(
            supplyAmountsInEth_.weth * liquidityPoolData_.supplyRate.weth
        );
        numerator_ =
            numerator_ +
            int256(
                supplyAmountsInEth_.usdc * liquidityPoolData_.supplyRate.usdc
            );
        numerator_ =
            numerator_ +
            int256(supplyAmountsInEth_.dai * liquidityPoolData_.supplyRate.dai);
        numerator_ =
            numerator_ +
            int256(
                supplyAmountsInEth_.wbtc * liquidityPoolData_.supplyRate.wbtc
            );

        numerator_ =
            numerator_ -
            int256(
                borrowAmountsInEth_.weth * liquidityPoolData_.borrowRate.weth
            );
        numerator_ =
            numerator_ -
            int256(
                borrowAmountsInEth_.usdc * liquidityPoolData_.borrowRate.usdc
            );
        numerator_ =
            numerator_ -
            int256(borrowAmountsInEth_.dai * liquidityPoolData_.borrowRate.dai);
        numerator_ =
            numerator_ -
            int256(
                borrowAmountsInEth_.wbtc * liquidityPoolData_.borrowRate.wbtc
            );

        // denominator
        uint256 denominator_ = totalSupplyInEth_ - totalBorrowInEth_;

        userOcData_.netApy = denominator_ == 0
            ? int256(0)
            : numerator_ / int256(denominator_);

        userOcData_.healthFactor = OC_MARKET.getHf(user_);
    }
}
