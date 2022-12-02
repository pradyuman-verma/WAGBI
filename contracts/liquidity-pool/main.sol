//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./helpers.sol";

contract Internals is Helpers {
    function supplyInternal(
        address token_,
        uint256 amount_,
        address from_
    ) internal {
        IERC20(token_).safeTransferFrom(from_, address(this), amount_);
        // update user related storage
        // event
    }

    function withdrawInternal(
        address token_,
        uint256 amount_,
        address to_
    ) internal {
        // update user related storage
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
        // update user related storage
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
        // update user related storage
        // event
    }
}

contract LiquidityPool is Internals {
    function supply(
        address token_,
        uint256 amount_,
        address from_
    ) public {
        supplyInternal(token_, amount_, from_);
    }

    function withdraw(
        address token_,
        uint256 amount_,
        address to_
    ) public {
        withdrawInternal(token_, amount_, to_);
    }

    function borrow(
        address token_,
        uint256 amount_,
        address to_
    ) public {
        borrowInternal(token_, amount_, to_);
    }

    function payback(
        address token_,
        uint256 amount_,
        address from_
    ) public {
        paybackInternal(token_, amount_, from_);
    }
}
