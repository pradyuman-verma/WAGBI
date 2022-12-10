// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAaveFallbackOracle {
    function setAssetPrice(address token_, uint256 price_) external;

    function getAssetPrice(address token_) external view returns (uint256);
}

contract OracleImplementation {
    IAaveFallbackOracle internal immutable AAVE_V2_FALLBACK_ORACLE;

    // using aave v2 oracle to remove price discrepancy
    function setPrice(address token_, uint256 price_) public {
        AAVE_V2_FALLBACK_ORACLE.setAssetPrice(token_, price_);
    }

    function getPriceInEth(address token_) external view returns (uint256) {
        return AAVE_V2_FALLBACK_ORACLE.getAssetPrice(token_);
    }

    constructor(address aaveFallbackOracle_) payable {
        AAVE_V2_FALLBACK_ORACLE = IAaveFallbackOracle(aaveFallbackOracle_);
    }
}
