// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../../../dependencies/IERC20.sol";

interface IWalletFactory {
    function create(address auth_) external returns (address walletAddr_);
}

interface IWalletImplementation {
    function supplyLiquidity(
        address token_,
        uint256 amount_,
        bool fromOsw_
    ) external;

    function supply(address token_, uint256 amount_) external;

    function withdrawLiquidity(
        address token_,
        uint256 amount_,
        address to_
    ) external;

    function withdraw(
        address token_,
        uint256 amount_,
        address to_
    ) external;

    function borrow(address token_, uint256 amount_) external;

    function payback(
        address token_,
        uint256 amount_,
        bool fromOsw_
    ) external;

    function dispatchToPlanet(uint8[] calldata types_, bytes[] calldata params_)
        external;

    function oswData() external view returns (uint256);
}
