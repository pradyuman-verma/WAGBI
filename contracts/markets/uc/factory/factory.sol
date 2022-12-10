// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";

interface ILiquidity {
    function enableUser(address userAddr_) external;
}

interface Wallet {
    function initializeAuth(address auth_) external;
}

contract UCFactoryImplementation {
    ILiquidity immutable LIQUIDITY;

    address internal immutable WALLET;

    event createLog(address auth_, address origin_);

    constructor(address liquidity_, address wallet_) {
        LIQUIDITY = ILiquidity(liquidity_);
        WALLET = wallet_;
    }

    function create(address auth_) external returns (address walletAddr_) {
        walletAddr_ = Clones.clone(WALLET);

        // will set user EOA address as auth to smart contract wallet.
        Wallet(walletAddr_).initializeAuth(auth_);

        // whitelist user wallet in liquidity pool
        LIQUIDITY.enableUser(walletAddr_);

        emit createLog(auth_, msg.sender);
    }
}
