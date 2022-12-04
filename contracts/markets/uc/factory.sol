// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";

interface ILiquidity {
    function enableUser(address userAddr_) external;
}

interface Wallet {
    function initializeAuth(address auth_) external;
}

contract UCWalletFactory {
    ILiquidity immutable LIQUIDITY;

    address internal immutable WALLET;

    mapping(address => address[]) public authToWallet;

    event createLog(address auth_, address origin_);

    function getUserAddr(address user_)
        external
        view
        returns (address[] memory wallet)
    {
        wallet = new address[](10);
        for (uint256 i; i < 10; i++) wallet[i] = authToWallet[user_][i];
    }

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

        authToWallet[auth_].push(walletAddr_);

        emit createLog(auth_, msg.sender);
    }
}
