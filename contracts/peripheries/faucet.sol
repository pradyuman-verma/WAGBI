// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {IERC20} from "../dependencies/IERC20.sol";
import {SafeERC20} from "../dependencies/SafeERC20.sol";

interface IFaucet {
    function mint(address tokenAddr_, uint256 amount_) external;
}

interface IWethFaucet {
    function mint(uint256 amount_) external;
}

contract Faucet {
    using SafeERC20 for IERC20;

    IFaucet internal immutable FAUCET;

    IWethFaucet internal immutable WETH_FAUCET;

    function mint(
        address token_,
        uint256 amount_,
        address to_
    ) external {
        if (token_ == address(WETH_FAUCET)) {
            WETH_FAUCET.mint(amount_);
        } else {
            FAUCET.mint(token_, amount_);
        }
        IERC20(token_).safeTransfer(to_, amount_);
    }

    constructor(
        address faucetAddr_,
        address wethAddr_
    ) payable {
        FAUCET = IFaucet(faucetAddr_);
        WETH_FAUCET = IWethFaucet(wethAddr_);
    }
}
