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
}

contract LendersMarket {
    ILiquidity internal constant LIQUIDITY = ILiquidity(address(0)); // TODO: Update address

    uint256 internal _status;

    mapping(address => uint256) public userRawSupply;

    modifier nonReentrant() {
        require(_status == 1, "ReentrancyGuard: reentrant call");
        _status = 2;
        _;
        _status = 1;
    }

    function supply(
        address token_,
        uint256 amount_,
        address for_
    ) external nonReentrant {
        if (amount_ == 0) revert("amount = 0");
        (oldRawAmount_, newRawAmount_, , ) = LIQUIDITY.supply(
            token_,
            amount_,
            msg.sender
        );

        userRawSupply[for_] += newRawAmount_ - oldRawAmount_;
    }

    function withdraw(
        address token_,
        uint256 amount_,
        address to_
    ) external nonReentrant {
        if (amount_ == 0) revert("amount = 0");
        (oldRawAmount_, newRawAmount_, , ) = LIQUIDITY.withdraw(
            token_,
            amount_,
            to_
        );

        userRawSupply[msg.sender] -= newRawAmount_ - oldRawAmount_;
    }
}
