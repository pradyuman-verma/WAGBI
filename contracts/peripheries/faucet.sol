// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFaucet {
    function mint(address to_, uint256 amount_) external;
}

contract Faucet {
    function mint(
        address token_,
        uint256 amount_,
        address to_
    ) external {
        IFaucet(token_).mint(to_, amount_);
    }
}
