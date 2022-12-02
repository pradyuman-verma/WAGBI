// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAaveFallbackOracle {
    function setAssetPrice(address token_, uint256 price_) external;

    function getAssetPrice(address token_) external view returns (uint256);
}

contract OrbitOracle {
    // Goerli Address
    IAaveFallbackOracle internal constant AAVE_V2_FALLBACK_ORACLE =
        IAaveFallbackOracle(0x0F9d5ED72f6691E47abe2f79B890C3C33e924092);

    // using aave v2 oracle to remove price discrepancy
    function setPrice(address token_, uint256 price_) public {
        AAVE_V2_FALLBACK_ORACLE.setAssetPrice(token_, price_);
    }

    function getPriceInEth(address token_) external view returns (uint256) {
        return AAVE_V2_FALLBACK_ORACLE.getAssetPrice(token_);
    }
}
