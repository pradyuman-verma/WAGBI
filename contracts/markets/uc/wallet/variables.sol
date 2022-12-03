// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces.sol";

contract Variables {
    ILiquidityPool internal immutable LIQUIDITY_POOL;
    IOracle internal immutable ORACLE;

    constructor(address liquidityPoolAddr_, address oracleAddr_) {
        LIQUIDITY_POOL = ILiquidityPool(liquidityPoolAddr_);
        ORACLE = IOracle(oracleAddr_);
    }
}