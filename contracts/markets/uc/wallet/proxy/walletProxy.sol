// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "./walletProxyStorage.sol";

contract UCWallet {
    UCWalletStorage public immutable WALLET_STORAGE;

    address public admin;

    constructor(address implementation_, address admin_) payable {
        WALLET_STORAGE = new UCWalletStorage(implementation_);
        admin = admin_;
    }

    modifier onlyAdmin() {
        if (admin != msg.sender) revert("only-admin");
        _;
    }

    function updateAdmin(address admin_) external onlyAdmin {
        admin = admin_;
    }

    function upgradeTo(address newImplementation_) external onlyAdmin {
        WALLET_STORAGE.upgradeTo(newImplementation_);
    }

    function implementation() internal view returns (address) {
        return WALLET_STORAGE.implementation();
    }

    function _delegate(address implementation_) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(
                gas(),
                implementation_,
                0,
                calldatasize(),
                0,
                0
            )

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    fallback() external payable {
        _delegate(implementation());
    }

    receive() external payable {}
}
