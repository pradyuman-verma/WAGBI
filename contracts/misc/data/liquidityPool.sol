// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILiquidity {
    function _poolData(address token_) external view returns (uint256);
}

contract LiquidityPoolDataProvider {
    ILiquidity internal constant LIQUIDITY =
        ILiquidity(0xa7352a773a946f498d9d6b848859E7e9215Fac83);

    function unpack(
        uint256 input_,
        uint256 startPosition_,
        uint256 endPosition_
    ) public pure returns (uint256 output_) {
        output_ =
            (input_ << (255 - endPosition_)) >>
            (255 + startPosition_ - endPosition_);
    }

    function getTokenUtilization(address token_)
        external
        view
        returns (uint256 utilization_)
    {
        uint256 tokenPoolData_ = LIQUIDITY._poolData(token_);
        utilization_ = unpack(tokenPoolData_, 0, 26);
    }
}
