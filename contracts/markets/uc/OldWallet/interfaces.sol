// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "../../../dependencies/IERC20.sol";

interface ILiquidityPool {
    function supply(
        address token_,
        uint256 amount_,
        address from_
    )
        external
        returns (
            uint256 oldRawAmount_,
            uint256 newRawAmount_,
            uint256 supplyExchangePrice_,
            uint256 borrowExchangePrice_
        );

    function withdraw(
        address token_,
        uint256 amount_,
        address to_
    )
        external
        returns (
            uint256 oldRawAmount_,
            uint256 newRawAmount_,
            uint256 supplyExchangePrice,
            uint256 borrowExchangePrice
        );

    function borrow(
        address token_,
        uint256 amount_,
        address to_
    )
        external
        returns (
            uint256 oldRawAmount_,
            uint256 newRawAmount_,
            uint256 supplyExchangePrice_,
            uint256 borrowExchangePrice_
        );

    function payback(
        address token_,
        uint256 amount_,
        address from_
    )
        external
        returns (
            uint256 oldRawAmount_,
            uint256 newRawAmount_,
            uint256 supplyExchangePrice_,
            uint256 borrowExchangePrice_
        );

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
}

interface IOracle {
    function getPriceInEth(address token_) external view returns (uint256);
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
}
