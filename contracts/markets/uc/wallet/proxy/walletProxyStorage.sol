// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UCWalletStorage {
    address internal immutable WALLET;
    address internal _implementation;

    constructor(address implementation_) payable {
        WALLET = msg.sender;
        _implementation = implementation_;
    }

    modifier onlyWallet() {
        if (WALLET != msg.sender) revert("only-wallet");
        _;
    }

    function upgradeTo(address implementation_) external onlyWallet {
        _implementation = implementation_;
    }

    function implementation() external view returns (address) {
        return _implementation;
    }
}
