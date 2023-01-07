// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OracleImplementation {
    mapping(address => uint256) internal _price;

    function setPrice(address token_, uint256 price_) public {
        _price[token_] = price_;
    }

    function getPriceInEth(address token_) external view returns (uint256) {
        return _price[token_];
    }
}
