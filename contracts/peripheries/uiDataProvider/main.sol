//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces.sol";

contract UIDataProvider {
    ILiquidityPool internal immutable LIQUIDITY_POOL;
    IOC internal immutable OC_MARKET;
    INftManager internal immutable NFT_MANAGER;
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
        address nftManagerAddr_,
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
        NFT_MANAGER = INftManager(nftManagerAddr_);
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

    function getUserNftIds(address user_)
        public
        view
        returns (uint256[] memory tokenIds_)
    {
        uint256 len_ = NFT_MANAGER.balanceOf(user_);
        tokenIds_ = new uint256[](len_);
        for (uint256 i; i < len_; i++)
            tokenIds_[i] = NFT_MANAGER.tokenOfOwnerByIndex(user_, i);
    }

    struct NftData {
        address wallet;
        UserAmountData supplyAmounts;
        UserAmountData borrowAmounts;
        UserAmountData holdAmounts;
        UserAmountData aaveSupplyAmounts;
        UserAmountData aaveBorrowAmounts;
        uint256 totalSupplyInUsd;
        uint256 totalBorrowInUsd;
        uint256 totalHoldInUsd;
        uint256 totalAaveSupplyInUsd;
        uint256 totalAaveBorrowInUsd;
        int256 netApy;
        uint256 healthFactor;
        uint256 aaveHealthFactor;
    }

    function getNftData(uint256 tokenId_)
        public
        view
        returns (NftData memory nftData_)
    {
        nftData_.wallet = NFT_MANAGER.getTokenIdToCapsule(tokenId_);

        // supply amounts
        (, nftData_.supplyAmounts.weth) = LIQUIDITY_POOL.getUserSupplyAmount(
            nftData_.wallet,
            WETH_ADDR
        );
        (, nftData_.supplyAmounts.usdc) = LIQUIDITY_POOL.getUserSupplyAmount(
            nftData_.wallet,
            USDC_ADDR
        );
        (, nftData_.supplyAmounts.dai) = LIQUIDITY_POOL.getUserSupplyAmount(
            nftData_.wallet,
            DAI_ADDR
        );
        (, nftData_.supplyAmounts.wbtc) = LIQUIDITY_POOL.getUserSupplyAmount(
            nftData_.wallet,
            WBTC_ADDR
        );

        // borrow amounts
        (, nftData_.borrowAmounts.weth) = LIQUIDITY_POOL.getUserBorrowAmount(
            nftData_.wallet,
            WETH_ADDR
        );
        (, nftData_.borrowAmounts.usdc) = LIQUIDITY_POOL.getUserBorrowAmount(
            nftData_.wallet,
            USDC_ADDR
        );
        (, nftData_.borrowAmounts.dai) = LIQUIDITY_POOL.getUserBorrowAmount(
            nftData_.wallet,
            DAI_ADDR
        );
        (, nftData_.borrowAmounts.wbtc) = LIQUIDITY_POOL.getUserBorrowAmount(
            nftData_.wallet,
            WBTC_ADDR
        );

        // hold amounts
        nftData_.holdAmounts.weth = IERC20(WETH_ADDR).balanceOf(
            nftData_.wallet
        );
        nftData_.holdAmounts.usdc = IERC20(USDC_ADDR).balanceOf(
            nftData_.wallet
        );
        nftData_.holdAmounts.dai = IERC20(DAI_ADDR).balanceOf(nftData_.wallet);
        nftData_.holdAmounts.wbtc = IERC20(WBTC_ADDR).balanceOf(
            nftData_.wallet
        );

        // aave supply amounts
        nftData_.aaveSupplyAmounts.weth = IERC20(
            AAVE_WETH_COLLATERAL_TOKEN_ADDR
        ).balanceOf(nftData_.wallet);
        nftData_.aaveSupplyAmounts.usdc = IERC20(
            AAVE_USDC_COLLATERAL_TOKEN_ADDR
        ).balanceOf(nftData_.wallet);
        nftData_.aaveSupplyAmounts.dai = IERC20(AAVE_DAI_COLLATERAL_TOKEN_ADDR)
            .balanceOf(nftData_.wallet);
        nftData_.aaveSupplyAmounts.wbtc = IERC20(
            AAVE_WBTC_COLLATERAL_TOKEN_ADDR
        ).balanceOf(nftData_.wallet);

        // aave borrow amounts
        nftData_.aaveBorrowAmounts.weth = IERC20(
            AAVE_WETH_VARIABLE_DEBT_TOKEN_ADDR
        ).balanceOf(nftData_.wallet);
        nftData_.aaveBorrowAmounts.usdc = IERC20(
            AAVE_USDC_VARIABLE_DEBT_TOKEN_ADDR
        ).balanceOf(nftData_.wallet);
        nftData_.aaveBorrowAmounts.dai = IERC20(
            AAVE_DAI_VARIABLE_DEBT_TOKEN_ADDR
        ).balanceOf(nftData_.wallet);
        nftData_.aaveBorrowAmounts.wbtc = IERC20(
            AAVE_WBTC_VARIABLE_DEBT_TOKEN_ADDR
        ).balanceOf(nftData_.wallet);

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

        // aave pool data for rates
        PoolData memory aavePoolData_ = getAavePoolData();

        // supply amounts in eth
        UserAmountData memory supplyAmountsInEth_;
        supplyAmountsInEth_.weth =
            (nftData_.supplyAmounts.weth * pricesInEth_.weth) /
            (10**decimals_.weth);
        supplyAmountsInEth_.usdc =
            (nftData_.supplyAmounts.usdc * pricesInEth_.usdc) /
            (10**decimals_.usdc);
        supplyAmountsInEth_.dai =
            (nftData_.supplyAmounts.dai * pricesInEth_.dai) /
            (10**decimals_.dai);
        supplyAmountsInEth_.wbtc =
            (nftData_.supplyAmounts.wbtc * pricesInEth_.wbtc) /
            (10**decimals_.wbtc);

        // total supply in eth
        // in 18 decimals
        uint256 totalSupplyInEth_ = supplyAmountsInEth_.weth +
            supplyAmountsInEth_.usdc +
            supplyAmountsInEth_.dai +
            supplyAmountsInEth_.wbtc;

        // total supply in usd
        // in 18 decimals
        nftData_.totalSupplyInUsd = pricesInEth_.usdc == 0
            ? 0
            : (totalSupplyInEth_ * 1e18) / pricesInEth_.usdc;

        // borrow amounts in eth
        UserAmountData memory borrowAmountsInEth_;
        borrowAmountsInEth_.weth =
            (nftData_.borrowAmounts.weth * pricesInEth_.weth) /
            (10**decimals_.weth);
        borrowAmountsInEth_.usdc =
            (nftData_.borrowAmounts.usdc * pricesInEth_.usdc) /
            (10**decimals_.usdc);
        borrowAmountsInEth_.dai =
            (nftData_.borrowAmounts.dai * pricesInEth_.dai) /
            (10**decimals_.dai);
        borrowAmountsInEth_.wbtc =
            (nftData_.borrowAmounts.wbtc * pricesInEth_.wbtc) /
            (10**decimals_.wbtc);

        // total borrow in eth
        // in 18 decimals
        uint256 totalBorrowInEth_ = borrowAmountsInEth_.weth +
            borrowAmountsInEth_.usdc +
            borrowAmountsInEth_.dai +
            borrowAmountsInEth_.wbtc;

        // total borrow in usd
        // in 18 decimals
        nftData_.totalBorrowInUsd = pricesInEth_.usdc == 0
            ? 0
            : (totalBorrowInEth_ * 1e18) / pricesInEth_.usdc;

        // hold amounts in eth
        UserAmountData memory holdAmountsInEth_;
        holdAmountsInEth_.weth =
            (nftData_.holdAmounts.weth * pricesInEth_.weth) /
            (10**decimals_.weth);
        holdAmountsInEth_.usdc =
            (nftData_.holdAmounts.usdc * pricesInEth_.usdc) /
            (10**decimals_.usdc);
        holdAmountsInEth_.dai =
            (nftData_.holdAmounts.dai * pricesInEth_.dai) /
            (10**decimals_.dai);
        holdAmountsInEth_.wbtc =
            (nftData_.holdAmounts.wbtc * pricesInEth_.wbtc) /
            (10**decimals_.wbtc);

        // total hold in eth
        // in 18 decimals
        uint256 totalHoldInEth_ = holdAmountsInEth_.weth +
            holdAmountsInEth_.usdc +
            holdAmountsInEth_.dai +
            holdAmountsInEth_.wbtc;

        // total hold in usd
        // in 18 decimals
        nftData_.totalHoldInUsd = pricesInEth_.usdc == 0
            ? 0
            : (totalHoldInEth_ * 1e18) / pricesInEth_.usdc;

        // aave supply amounts in eth
        UserAmountData memory aaveSupplyAmountsInEth_;
        aaveSupplyAmountsInEth_.weth =
            (nftData_.aaveSupplyAmounts.weth * pricesInEth_.weth) /
            (10**decimals_.weth);
        aaveSupplyAmountsInEth_.usdc =
            (nftData_.aaveSupplyAmounts.usdc * pricesInEth_.usdc) /
            (10**decimals_.usdc);
        aaveSupplyAmountsInEth_.dai =
            (nftData_.aaveSupplyAmounts.dai * pricesInEth_.dai) /
            (10**decimals_.dai);
        aaveSupplyAmountsInEth_.wbtc =
            (nftData_.aaveSupplyAmounts.wbtc * pricesInEth_.wbtc) /
            (10**decimals_.wbtc);

        // total aave supply in eth
        // in 18 decimals
        uint256 totalAaveSupplyInEth_ = aaveSupplyAmountsInEth_.weth +
            aaveSupplyAmountsInEth_.usdc +
            aaveSupplyAmountsInEth_.dai +
            aaveSupplyAmountsInEth_.wbtc;

        // total aave supply in usd
        // in 18 decimals
        nftData_.totalAaveSupplyInUsd = pricesInEth_.usdc == 0
            ? 0
            : (totalAaveSupplyInEth_ * 1e18) / pricesInEth_.usdc;

        // aave borrow amounts in eth
        UserAmountData memory aaveBorrowAmountsInEth_;
        aaveBorrowAmountsInEth_.weth =
            (nftData_.aaveBorrowAmounts.weth * pricesInEth_.weth) /
            (10**decimals_.weth);
        aaveBorrowAmountsInEth_.usdc =
            (nftData_.aaveBorrowAmounts.usdc * pricesInEth_.usdc) /
            (10**decimals_.usdc);
        aaveBorrowAmountsInEth_.dai =
            (nftData_.aaveBorrowAmounts.dai * pricesInEth_.dai) /
            (10**decimals_.dai);
        aaveBorrowAmountsInEth_.wbtc =
            (nftData_.aaveBorrowAmounts.wbtc * pricesInEth_.wbtc) /
            (10**decimals_.wbtc);

        // total aave borrow in eth
        // in 18 decimals
        uint256 totalAaveBorrowInEth_ = aaveBorrowAmountsInEth_.weth +
            aaveBorrowAmountsInEth_.usdc +
            aaveBorrowAmountsInEth_.dai +
            aaveBorrowAmountsInEth_.wbtc;

        // total aave borrow in usd
        // in 18 decimals
        nftData_.totalAaveBorrowInUsd = pricesInEth_.usdc == 0
            ? 0
            : (totalAaveBorrowInEth_ * 1e18) / pricesInEth_.usdc;

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

        numerator_ = int256(
            aaveSupplyAmountsInEth_.weth * aavePoolData_.supplyRate.weth
        );
        numerator_ =
            numerator_ +
            int256(
                aaveSupplyAmountsInEth_.usdc * aavePoolData_.supplyRate.usdc
            );
        numerator_ =
            numerator_ +
            int256(aaveSupplyAmountsInEth_.dai * aavePoolData_.supplyRate.dai);
        numerator_ =
            numerator_ +
            int256(
                aaveSupplyAmountsInEth_.wbtc * aavePoolData_.supplyRate.wbtc
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

        numerator_ =
            numerator_ -
            int256(
                aaveBorrowAmountsInEth_.weth * aavePoolData_.borrowRate.weth
            );
        numerator_ =
            numerator_ -
            int256(
                aaveBorrowAmountsInEth_.usdc * aavePoolData_.borrowRate.usdc
            );
        numerator_ =
            numerator_ -
            int256(aaveBorrowAmountsInEth_.dai * aavePoolData_.borrowRate.dai);
        numerator_ =
            numerator_ -
            int256(
                aaveBorrowAmountsInEth_.wbtc * aavePoolData_.borrowRate.wbtc
            );

        // denominator
        uint256 denominator_ = totalSupplyInEth_ +
            totalHoldInEth_ +
            totalAaveSupplyInEth_ -
            totalBorrowInEth_ -
            totalAaveBorrowInEth_;

        nftData_.netApy = denominator_ == 0
            ? int256(0)
            : numerator_ / int256(denominator_);

        nftData_.healthFactor = IWallet(nftData_.wallet).getHf();
        (, , , , , nftData_.aaveHealthFactor) = AAVE_LENDING_POOL
            .getUserAccountData(nftData_.wallet);
    }

    // function getUsersNftData(address user_)
    //     external
    //     view
    //     returns (
    //         uint256 totalSupplyInUsd_,
    //         uint256 totalBorrowInUsd_,
    //         int256 totalApy_,
    //         UserUcWalletData[] memory positions_
    //     )
    // {
    //     positions_ = new UserUcWalletData[](10);
    //     int256 numerator_;
    //     uint256 denominator_;
    //     for (uint256 i; i < wallets_.length; ) {
    //         positions_[i] = getUCWalletData(wallets_[i]);
    //         uint256 positionTotalSupplyInUsd_ = positions_[i].totalSupplyInUsd +
    //             positions_[i].totalHoldInUsd +
    //             positions_[i].totalAaveSupplyInUsd;

    //         uint256 positionTotalBorrowInUsd_ = positions_[i].totalBorrowInUsd +
    //             positions_[i].totalAaveBorrowInUsd;

    //         totalSupplyInUsd_ += positionTotalSupplyInUsd_;
    //         totalBorrowInUsd_ += positionTotalBorrowInUsd_;

    //         numerator_ +=
    //             (int256(positionTotalSupplyInUsd_) -
    //                 int256(positionTotalBorrowInUsd_)) *
    //             positions_[i].netApy;

    //         denominator_ = denominator_ + totalSupplyInUsd_ - totalBorrowInUsd_;

    //         wallet_ = UC_WALLET_FACTORY.authToWallet(user_, i);
    //         unchecked {
    //             ++i;
    //         }
    //     }
    //     totalApy_ = numerator_ / int256(denominator_);
    // }
}
