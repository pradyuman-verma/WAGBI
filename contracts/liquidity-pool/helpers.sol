//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./events.sol";

contract Helpers is Events {
    constructor(
        address wethAddr_,
        address usdcAddr_,
        address daiAddr_,
        address wbtcAddr_,
        address lenders_,
        address uc_
    ) Events(wethAddr_, usdcAddr_, daiAddr_, wbtcAddr_, lenders_, uc_) {}

    struct TokenData {
        uint256 decimals;
        uint256 borrowAllowance;
    }

    struct PoolData {
        uint256 utilization;
        uint256 lastUpdateTimestamp;
        uint256 lastSupplyExchangePrice;
        uint256 lastBorrowExchangePrice;
        uint256 rawSupply;
        uint256 rawBorrow;
    }

    modifier nonReentrant() {
        require(_status == 1, "ReentrancyGuard: reentrant call");
        _status = 2;
        _;
        _status = 1;
    }

    function pack(
        uint256 input_,
        uint256 insertValue_,
        uint256 startPosition_,
        uint256 endPosition_
    ) public pure returns (uint256 output_) {
        uint256 mask = ((2**(endPosition_ - startPosition_ + 1)) - 1) <<
            startPosition_;
        output_ = (input_ & (~mask)) | (insertValue_ << startPosition_);
    }

    function unpack(
        uint256 input_,
        uint256 startPosition_,
        uint256 endPosition_
    ) public pure returns (uint256 output_) {
        output_ =
            (input_ << (255 - endPosition_)) >>
            (255 + startPosition_ - endPosition_);
    }

    function getTokenData(address token_)
        internal
        view
        returns (TokenData memory tokenData_)
    {
        if (token_ == WETH_ADDR) {
            tokenData_.decimals = WETH_DECIMALS;
            tokenData_.borrowAllowance = WETH_BORROW_ALLOWANCE;
        } else if (token_ == USDC_ADDR) {
            tokenData_.decimals = USDC_DECIMALS;
            tokenData_.borrowAllowance = USDC_BORROW_ALLOWANCE;
        } else if (token_ == DAI_ADDR) {
            tokenData_.decimals = DAI_DECIMALS;
            tokenData_.borrowAllowance = DAI_BORROW_ALLOWANCE;
        } else if (token_ == WBTC_ADDR) {
            tokenData_.decimals = WBTC_DECIMALS;
            tokenData_.borrowAllowance = WBTC_BORROW_ALLOWANCE;
        } else {
            revert("unsupported-token");
        }
    }

    function compilePoolData(
        uint256 utilization_,
        uint256 timestamp_,
        uint256 supplyExchangePrice_,
        uint256 borrowExchangePrice_,
        uint256 rawSupply_,
        uint256 rawBorrow_
    ) internal pure returns (uint256 poolData_) {
        poolData_ = pack(utilization_, timestamp_, 27, 58);
        poolData_ = pack(poolData_, supplyExchangePrice_, 59, 98);
        poolData_ = pack(poolData_, borrowExchangePrice_, 99, 138);
        poolData_ = pack(poolData_, rawSupply_, 139, 197);
        poolData_ = pack(poolData_, rawBorrow_, 198, 255);
    }

    function decompilePoolData(uint256 poolData_)
        internal
        pure
        returns (PoolData memory poolDatas_)
    {
        poolDatas_.utilization = unpack(poolData_, 0, 26);
        poolDatas_.lastUpdateTimestamp = unpack(poolData_, 27, 58);
        poolDatas_.lastSupplyExchangePrice = unpack(poolData_, 59, 98);
        poolDatas_.lastBorrowExchangePrice = unpack(poolData_, 99, 138);
        poolDatas_.rawSupply = unpack(poolData_, 139, 197);
        poolDatas_.rawBorrow = unpack(poolData_, 198, 255);
    }

    function validateUser(address user_)
        internal
        view
        returns (address protocolAddr_)
    {
        if (user_ == LENDERS_PROTOCOL_ADDR) {
            protocolAddr_ = LENDERS_PROTOCOL_ADDR;
        } else if (_userToProtocol[user_] == UC_PROTOCOL_ADDR) {
            protocolAddr_ = UC_PROTOCOL_ADDR;
        } else {
            revert("user-not-whitelisted");
        }
    }

    function getUserBorrowAmount(address user_, address token_)
        public
        view
        returns (uint256 rawBorrowAmount_, uint256 borrowAmount_)
    {
        TokenData memory tokenData_ = getTokenData(token_);
        rawBorrowAmount_ = unpack(_userData[user_][token_], 59, 116);
        borrowAmount_ =
            (rawBorrowAmount_ *
                unpack(_poolData[token_], 99, 138) *
                (10**tokenData_.decimals)) /
            1e16;
    }

    function getUserSupplyAmount(address user_, address token_)
        public
        view
        returns (uint256 rawSupplyAmount, uint256 supplyAmount)
    {
        TokenData memory tokenData_ = getTokenData(token_);
        rawSupplyAmount = unpack(_userData[user_][token_], 0, 58);
        supplyAmount =
            (rawSupplyAmount *
                unpack(_poolData[token_], 59, 98) *
                (10**tokenData_.decimals)) /
            1e16;
    }
}
