//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./helpers.sol";
import {SafeERC20} from "../dependencies/SafeERC20.sol";

contract Internals is Helpers {
    using SafeERC20 for IERC20;

    function updateStorage(
        address token_,
        int256 supplyAmount_,
        int256 borrowAmount_
    )
        internal
        returns (
            uint256 oldRawAmount_,
            uint256 newRawAmount_,
            uint256 newSupplyExchangePrice_,
            uint256 newBorrowExchangePrice_
        )
    {
        // update storage
    }

    function supplyInternal(
        address token_,
        uint256 amount_,
        address from_
    ) internal {
        IERC20(token_).safeTransferFrom(from_, address(this), amount_);
        (
            oldRawAmount_,
            newRawAmount_,
            supplyExchangePrice_,
            borrowExchangePrice_
        ) = updateStorage(token_, int256(amount_), 0);
        // event
    }

    function withdrawInternal(
        address token_,
        uint256 amount_,
        address to_
    ) internal {
        (
            oldRawAmount_,
            newRawAmount_,
            supplyExchangePrice,
            borrowExchangePrice
        ) = updateStorage(token_, -int256(amount_), 0);
        IERC20(token_).safeTransfer(to_, amount_);
        // event
    }

    function borrowInternal(
        address token_,
        uint256 amount_,
        address to_
    )
        internal
        returns (
            uint256 oldRawAmount_,
            uint256 newRawAmount_,
            uint256 supplyExchangePrice_,
            uint256 borrowExchangePrice_
        )
    {
        (
            oldRawAmount_,
            newRawAmount_,
            supplyExchangePrice_,
            borrowExchangePrice_
        ) = updateStorage(token_, 0, int256(amount_));
        IERC20(token_).safeTransfer(to_, amount_);
        // event
    }

    function paybackInternal(
        address token_,
        uint256 amount_,
        address from_
    )
        internal
        returns (
            uint256 oldRawAmount_,
            uint256 newRawAmount_,
            uint256 supplyExchangePrice_,
            uint256 borrowExchangePrice_
        )
    {
        IERC20(token_).safeTransferFrom(from_, address(this), amount_);
        (
            oldRawAmount_,
            newRawAmount_,
            supplyExchangePrice_,
            borrowExchangePrice_
        ) = updateStorage(token_, 0, -int256(amount_));
        // event
    }
}

contract LiquidityPool is Internals {
    function supply(
        address token_,
        uint256 amount_,
        address from_
    )
        public
        nonReentrant
        returns (
            uint256 oldRawAmount_,
            uint256 newRawAmount_,
            uint256 supplyExchangePrice_,
            uint256 borrowExchangePrice_
        )
    {
        (
            oldRawAmount_,
            newRawAmount_,
            supplyExchangePrice_,
            borrowExchangePrice_
        ) = supplyInternal(token_, amount_, from_);
    }

    function withdraw(
        address token_,
        uint256 amount_,
        address to_
    )
        public
        nonReentrant
        returns (
            uint256 oldRawAmount_,
            uint256 newRawAmount_,
            uint256 supplyExchangePrice_,
            uint256 borrowExchangePrice_
        )
    {
        (
            oldRawAmount_,
            newRawAmount_,
            supplyExchangePrice_,
            borrowExchangePrice_
        ) = withdrawInternal(token_, amount_, to_);
    }

    function borrow(
        address token_,
        uint256 amount_,
        address to_
    )
        public
        nonReentrant
        returns (
            uint256 oldRawAmount_,
            uint256 newRawAmount_,
            uint256 supplyExchangePrice_,
            uint256 borrowExchangePrice_
        )
    {
        (
            oldRawAmount_,
            newRawAmount_,
            supplyExchangePrice_,
            borrowExchangePrice_
        ) = borrowInternal(token_, amount_, to_);
    }

    function payback(
        address token_,
        uint256 amount_,
        address from_
    )
        public
        nonReentrant
        returns (
            uint256 oldRawAmount_,
            uint256 newRawAmount_,
            uint256 supplyExchangePrice_,
            uint256 borrowExchangePrice_
        )
    {
        (
            oldRawAmount_,
            newRawAmount_,
            supplyExchangePrice_,
            borrowExchangePrice_
        ) = paybackInternal(token_, amount_, from_);
    }
}
