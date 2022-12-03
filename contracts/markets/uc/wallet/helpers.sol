// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./variables.sol";

contract Helpers is Variables {
    constructor(
        address liquidityPoolAddr_,
        address oracleAddr_,
        address aaveDataProviderAddr_,
        address wethAddr_,
        address usdcAddr_,
        address daiAddr_,
        address wbtcAddr_
    )
        Variables(
            liquidityPoolAddr_,
            oracleAddr_,
            aaveDataProviderAddr_,
            wethAddr_,
            usdcAddr_,
            daiAddr_,
            wbtcAddr_
        )
    {}

    function pack(
        uint256 input_,
        uint256 insertValue_,
        uint256 startPosition_,
        uint256 endPosition_
    ) internal pure returns (uint256 output_) {
        uint256 mask = ((2**(endPosition_ - startPosition_ + 1)) - 1) <<
            startPosition_;
        output_ = (input_ & (~mask)) | (insertValue_ << startPosition_);
    }

    function unpack(
        uint256 input_,
        uint256 startPosition_,
        uint256 endPosition_
    ) internal pure returns (uint256 output_) {
        output_ =
            (input_ << (255 - endPosition_)) >>
            (255 + startPosition_ - endPosition_);
    }

    function getAssetIndex(address token_)
        internal
        view
        returns (uint256 assetIndex_)
    {
        if (token_ == WETH_ADDR) {
            assetIndex_ = WETH_INDEX;
        } else if (token_ == USDC_ADDR) {
            assetIndex_ = USDC_INDEX;
        } else if (token_ == DAI_ADDR) {
            assetIndex_ = DAI_INDEX;
        } else if (token_ == WBTC_ADDR) {
            assetIndex_ = WBTC_INDEX;
        } else {
            revert("unsupported-token");
        }
    }
}
