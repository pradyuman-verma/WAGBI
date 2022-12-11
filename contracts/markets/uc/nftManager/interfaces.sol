// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../../../dependencies/IERC20.sol";

interface IWalletFactory {
    function create(address auth_) external returns (address walletAddr_);
}

interface IWalletImplementation {
    function supplyToLiquidityPool(
        address token_,
        uint256 amount_,
        bool fromWallet_
    ) external;

    function supplyToWallet(address token_, uint256 amount_) external;

    function withdrawFromLiquidityPool(
        address token_,
        uint256 amount_,
        address to_
    ) external;

    function withdrawFromWallet(
        address token_,
        uint256 amount_,
        address to_
    ) external;

    function borrowToWallet(address token_, uint256 amount_) external;

    function payback(
        address token_,
        uint256 amount_,
        bool fromOsw_
    ) external;

    function useAave(bytes calldata params_) external;
}
