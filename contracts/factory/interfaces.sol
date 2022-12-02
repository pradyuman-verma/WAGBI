// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";

interface ILiquidity {
    function enableUser(address userAddr_) external;
}

interface Wallet {
    function initializeAuth(address auth_) external;
}
