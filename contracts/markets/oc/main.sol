// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./helpers.sol";

contract OCImplementation is Helpers {
    constructor(
        address liquidityPoolAddr_,
        address oracleAddr_,
        address wethAddr_,
        address usdcAddr_,
        address daiAddr_,
        address wbtcAddr_
    )
        Helpers(
            liquidityPoolAddr_,
            oracleAddr_,
            wethAddr_,
            usdcAddr_,
            daiAddr_,
            wbtcAddr_
        )
    {}

    modifier nonReentrant() {
        require(_status == 1, "ReentrancyGuard: reentrant call");
        _status = 2;
        _;
        _status = 1;
    }

    function supply(
        address token_,
        uint256 amount_,
        address for_
    ) external nonReentrant {
        uint256 assetIndex_ = getAssetToIndex(token_);

        (uint256 oldRawAmount_, uint256 newRawAmount_, , ) = LIQUIDITY_POOL
            .supply(token_, amount_, msg.sender);

        // update user amounts data
        uint256 userAmountsData_ = userAmountsData[for_][token_];
        userAmountsData[for_][token_] = pack(
            userAmountsData_,
            unpack(userAmountsData_, 0, 58) + newRawAmount_ - oldRawAmount_,
            0,
            58
        );

        // update user tokens data
        uint256 userTokensData_ = userTokensData[for_];
        uint256 newUserTokensData_ = addToSupplyTokens(
            userTokensData_,
            assetIndex_
        );
        if (newUserTokensData_ != userTokensData_)
            userTokensData[for_] = newUserTokensData_;

        // TODO: event
    }

    function withdraw(
        address token_,
        uint256 amount_,
        address to_
    ) external nonReentrant {
        uint256 assetIndex_ = getAssetToIndex(token_);

        (uint256 oldRawAmount_, uint256 newRawAmount_, , ) = LIQUIDITY_POOL
            .withdraw(token_, amount_, to_);

        // update user amounts data
        uint256 userAmountsData_ = userAmountsData[msg.sender][token_];
        uint256 userFinalSuppliedAmount_ = unpack(userAmountsData_, 0, 58) +
            newRawAmount_ -
            oldRawAmount_;
        userAmountsData[msg.sender][token_] = pack(
            userAmountsData_,
            userFinalSuppliedAmount_,
            0,
            58
        );

        uint256 userTokensData_ = userTokensData[msg.sender];
        uint256 newUserTokensData_ = userTokensData_;
        // update user tokens data
        if (userFinalSuppliedAmount_ == 0) {
            newUserTokensData_ = removeFromSupplyTokens(
                userTokensData_,
                assetIndex_
            );
            if (newUserTokensData_ != userTokensData_)
                userTokensData[msg.sender] = newUserTokensData_;
        }

        checkHf(msg.sender, newUserTokensData_);

        // TODO: event
    }

    function borrow(
        address token_,
        uint256 amount_,
        address to_
    ) external nonReentrant {
        uint256 assetIndex_ = getAssetToIndex(token_);

        (uint256 oldRawAmount_, uint256 newRawAmount_, , ) = LIQUIDITY_POOL
            .borrow(token_, amount_, to_);

        // update user amounts data
        uint256 userAmountsData_ = userAmountsData[msg.sender][token_];
        userAmountsData[msg.sender][token_] = pack(
            userAmountsData_,
            unpack(userAmountsData_, 59, 116) + newRawAmount_ - oldRawAmount_,
            59,
            116
        );

        // update user tokens data
        uint256 userTokensData_ = userTokensData[msg.sender];
        uint256 newUserTokensData_ = addToBorrowTokens(
            userTokensData_,
            assetIndex_
        );
        if (newUserTokensData_ != userTokensData_)
            userTokensData[msg.sender] = newUserTokensData_;

        checkHf(msg.sender, newUserTokensData_);

        // TODO: event
    }

    function payback(
        address token_,
        uint256 amount_,
        address for_
    ) external nonReentrant {
        uint256 assetIndex_ = getAssetToIndex(token_);

        (uint256 oldRawAmount_, uint256 newRawAmount_, , ) = LIQUIDITY_POOL
            .payback(token_, amount_, msg.sender);

        uint256 userAmountsData_ = userAmountsData[for_][token_];
        uint256 userFinalBorrowedAmount_ = unpack(userAmountsData_, 59, 116) +
            newRawAmount_ -
            oldRawAmount_;
        userAmountsData[for_][token_] = pack(
            userAmountsData_,
            userFinalBorrowedAmount_,
            59,
            116
        );

        // update user tokens data
        if (userFinalBorrowedAmount_ == 0) {
            uint256 userTokensData_ = userTokensData[for_];
            uint256 newUserTokensData_ = removeFromBorrowTokens(
                userTokensData_,
                assetIndex_
            );
            if (newUserTokensData_ != userTokensData_)
                userTokensData[for_] = newUserTokensData_;
        }

        // TODO: event
    }

    // TODO: Liquidate function

    function initialize() external {
        if (_status != 0) revert("only-once");
        _status = 1;
    }
}
