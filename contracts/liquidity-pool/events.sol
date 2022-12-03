//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./variables.sol";

contract Events is Variables {
    constructor(
        address wethAddr_,
        address usdcAddr_,
        address daiAddr_,
        address wbtcAddr_,
        address oc_,
        address uc_
    ) Variables(wethAddr_, usdcAddr_, daiAddr_, wbtcAddr_, oc_, uc_) {}

    event updateProtocolParamsLog(
        address protocolAddr_,
        address[] supplyTokens_,
        bool[] supplyAllowances_,
        address[] borrowTokens_,
        uint256[] borrowAllowances_
    );

    event supplyLog(
        address userAddr_,
        address tokens_,
        uint256 amounts_,
        address from_
    );

    event withdrawLog(
        address userAddr_,
        address token_,
        uint256 amount_,
        address to_
    );

    event borrowLog(
        address userAddr_,
        address token_,
        uint256 amount_,
        address to_
    );

    event paybackLog(
        address userAddr_,
        address token_,
        uint256 amount_,
        address from_
    );

    event updateStorageLog(
        address token_,
        address user_,
        uint256 newSupplyExchangePrice_,
        uint256 newBorrowExchangePrice_,
        uint256 totalSupply_,
        uint256 totalBorrow_
    );
}
