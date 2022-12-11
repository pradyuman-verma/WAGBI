import {IERC20} from "../../dependencies/IERC20.sol";

interface ILiquidityPool {
    function getUserSupplyAmount(address user_, address token_)
        external
        view
        returns (uint256 rawSupplyAmount_, uint256 supplyAmount_);

    function getUserBorrowAmount(address user_, address token_)
        external
        view
        returns (uint256 rawBorrowAmount_, uint256 borrowAmount_);

    function getExchangePrices(address token_)
        external
        view
        returns (uint256 supplyExchangePrice_, uint256 borrowExchangePrice_);

    function getRates(address token_)
        external
        view
        returns (uint256 supplyRate_, uint256 borrowRate_);
}

interface IOracle {
    function getPriceInEth(address token_) external view returns (uint256);
}

interface IOC {
    function getSupplyAmount(address user_, address token_)
        external
        view
        returns (uint256 supplyAmount_);

    function getBorrowAmount(address user_, address token_)
        external
        view
        returns (uint256 borrowAmount_);

    function getHf(address user_) external view returns (uint256);
}

interface IAaveLendingPool {
    function getUserAccountData(address user)
        external
        view
        returns (
            uint256 totalCollateralETH,
            uint256 totalDebtETH,
            uint256 availableBorrowsETH,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        );
}

interface IAaveDataProvider {
    function getReserveTokensAddresses(address asset)
        external
        view
        returns (
            address atokenAddr_,
            address stableDebtTokenAddr_,
            address variableDebtTokenAddr_
        );

    function getReserveData(address asset)
        external
        view
        returns (
            uint256 availableLiquidity,
            uint256 totalStableDebt,
            uint256 totalVariableDebt,
            uint256 liquidityRate,
            uint256 variableBorrowRate,
            uint256 stableBorrowRate,
            uint256 averageStableBorrowRate,
            uint256 liquidityIndex,
            uint256 variableBorrowIndex,
            uint40 lastUpdateTimestamp
        );
}

interface IWallet {
    function getHf() external view returns (uint256 hf_);
}

interface IWalletFactory {
    function authToWallet(address user_, uint256 i)
        external
        view
        returns (address);
}

interface INftManager {
    function balanceOf(address user_) external view returns (uint256 balance_);

    function tokenOfOwnerByIndex(address user_, uint256 index_)
        external
        view
        returns (uint256 tokenId_);

    function getTokenIdToCapsule(uint256 tokenId_)
        external
        view
        returns (address capsule_);
}
