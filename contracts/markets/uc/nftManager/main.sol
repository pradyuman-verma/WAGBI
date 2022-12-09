// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./interfaces.sol";
import {SafeERC20} from "../../../dependencies/SafeERC20.sol";
import {ERC721} from "../../../dependencies/ERC721.sol";

contract OrbitNftManager is ERC721 {
    using SafeERC20 for IERC20;

    IWalletFactory internal immutable WALLET_FACTORY;

    address internal immutable POOL;

    uint256 public tokenId;

    mapping(uint256 => address) internal tokenIdToCapsule;

    constructor(address factory_, address pool_)
        ERC721("Orbit Capsules NFT", "ORBIT-CAPSULES")
    {
        WALLET_FACTORY = IWalletFactory(factory_);
        POOL = pool_;
    }

    function mint(address recipient_) external returns (address capsule_) {
        capsule_ = WALLET_FACTORY.create(address(this));
        _mint(recipient_, ++tokenId); // no minting of zero
        tokenIdToCapsule[tokenId] = capsule_;
    }

    modifier onlyNftOwner(uint256 tokenId_) {
        if (ownerOf(tokenId_) != msg.sender) revert("not-nft-owner");
        _;
    }

    function supplyToLiquidityPool(
        uint256 tokenId_,
        address token_,
        uint256 amount_
    ) external onlyNftOwner(tokenId_) {
        address capsule_ = tokenIdToCapsule[tokenId_];
        IERC20(token_).safeTransferFrom(msg.sender, address(this), amount_);
        IERC20(token_).safeApprove(address(POOL), amount_);
        IWalletImplementation(capsule_).supplyToLiquidityPool(
            token_,
            amount_,
            false
        );
    }

    // function supplyLiquidity(
    //     uint256 tokenId_,
    //     address token_,
    //     uint256 amount_
    // ) external onlyNftOwner(tokenId_) {
    //     address capsule_ = tokenIdToCapsule[tokenId_];

    //     IERC20(token_).safeTransferFrom(msg.sender, address(this), amount_);
    //     IERC20(token_).safeApprove(address(POOL), amount_);

    //     IWalletImplementation(capsule_).supplyLiquidity(token_, amount_, false);
    // }

    // function supply(
    //     uint256 tokenId_,
    //     address token_,
    //     uint256 amount_
    // ) external onlyNftOwner(tokenId_) {
    //     address capsule_ = tokenIdToCapsule[tokenId_];

    //     // get and send amount;
    //     IERC20(token_).safeTransferFrom(msg.sender, address(this), amount_);
    //     IERC20(token_).safeApprove(capsule_, amount_);

    //     IWalletImplementation(capsule_).supply(token_, amount_);
    // }

    // function withdrawLiquidityToOsw(
    //     uint256 tokenId_,
    //     address token_,
    //     uint256 amount_
    // ) external onlyNftOwner(tokenId_) {
    //     address capsule_ = tokenIdToCapsule[tokenId_];
    //     IWalletImplementation(capsule_).withdrawLiquidity(
    //         token_,
    //         amount_,
    //         capsule_
    //     );
    // }

    // function withdrawLiquidity(
    //     uint256 tokenId_,
    //     address token_,
    //     uint256 amount_
    // ) external onlyNftOwner(tokenId_) {
    //     address capsule_ = tokenIdToCapsule[tokenId_];
    //     IWalletImplementation(capsule_).withdrawLiquidity(
    //         token_,
    //         amount_,
    //         msg.sender
    //     );
    // }

    // function withdraw(
    //     uint256 tokenId_,
    //     address token_,
    //     uint256 amount_,
    //     address to_
    // ) external onlyNftOwner(tokenId_) {
    //     address capsule_ = tokenIdToCapsule[tokenId_];
    //     IWalletImplementation(capsule_).withdraw(token_, amount_, to_);
    // }

    // function borrowToOsw(
    //     uint256 tokenId_,
    //     address token_,
    //     uint256 amount_
    // ) external onlyNftOwner(tokenId_) {
    //     address capsule_ = tokenIdToCapsule[tokenId_];
    //     IWalletImplementation(capsule_).borrow(token_, amount_);
    // }

    // function paybackFromOsw(
    //     uint256 tokenId_,
    //     address token_,
    //     uint256 amount_
    // ) external onlyNftOwner(tokenId_) {
    //     address capsule_ = tokenIdToCapsule[tokenId_];
    //     IWalletImplementation(capsule_).payback(token_, amount_, true);
    // }

    // function payback(
    //     uint256 tokenId_,
    //     address token_,
    //     uint256 amount_
    // ) external onlyNftOwner(tokenId_) {
    //     address capsule_ = tokenIdToCapsule[tokenId_];
    //     IERC20(token_).safeTransferFrom(msg.sender, address(this), amount_);
    //     IERC20(token_).safeApprove(address(POOL), amount_);
    //     IWalletImplementation(capsule_).payback(token_, amount_, false);
    // }
}
