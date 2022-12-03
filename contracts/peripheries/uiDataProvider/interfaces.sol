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
}
