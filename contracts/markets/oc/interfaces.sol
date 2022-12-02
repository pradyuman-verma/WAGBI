// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILiquidity {
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
}
