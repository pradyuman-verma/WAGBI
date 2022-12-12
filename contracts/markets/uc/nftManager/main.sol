// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./interfaces.sol";
import {SafeERC20} from "../../../dependencies/SafeERC20.sol";
import {ERC721} from "../../../dependencies/ERC721.sol";

contract NftManagerImplementation is ERC721 {
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

    function getTokenIdToCapsule(uint256 tokenId_)
        external
        view
        returns (address capsuleAddr_)
    {
        capsuleAddr_ = tokenIdToCapsule[tokenId_];
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

    function supplyToLiquidityPoolFromWallet(
        uint256 tokenId_,
        address token_,
        uint256 amount_
    ) external onlyNftOwner(tokenId_) {
        address capsule_ = tokenIdToCapsule[tokenId_];
        IWalletImplementation(capsule_).supplyToLiquidityPool(
            token_,
            amount_,
            true
        );
    }

    function supplyToWallet(
        uint256 tokenId_,
        address token_,
        uint256 amount_
    ) external onlyNftOwner(tokenId_) {
        address capsule_ = tokenIdToCapsule[tokenId_];

        // get and send amount;
        IERC20(token_).safeTransferFrom(msg.sender, address(this), amount_);
        IERC20(token_).safeApprove(capsule_, amount_);

        IWalletImplementation(capsule_).supplyToWallet(token_, amount_);
    }

    function withdrawFromLiquidityPool(
        uint256 tokenId_,
        address token_,
        uint256 amount_
    ) external onlyNftOwner(tokenId_) {
        address capsule_ = tokenIdToCapsule[tokenId_];
        IWalletImplementation(capsule_).withdrawFromLiquidityPool(
            token_,
            amount_,
            msg.sender
        );
    }

    function withdrawFromLiquidityPoolToWallet(
        uint256 tokenId_,
        address token_,
        uint256 amount_
    ) external onlyNftOwner(tokenId_) {
        address capsule_ = tokenIdToCapsule[tokenId_];
        IWalletImplementation(capsule_).withdrawFromLiquidityPool(
            token_,
            amount_,
            capsule_
        );
    }

    function borrowToWallet(
        uint256 tokenId_,
        address token_,
        uint256 amount_
    ) external onlyNftOwner(tokenId_) {
        address capsule_ = tokenIdToCapsule[tokenId_];
        IWalletImplementation(capsule_).borrowToWallet(token_, amount_);
    }

    function paybackFromWallet(
        uint256 tokenId_,
        address token_,
        uint256 amount_
    ) external onlyNftOwner(tokenId_) {
        address capsule_ = tokenIdToCapsule[tokenId_];
        IWalletImplementation(capsule_).payback(token_, amount_, true);
    }

    function payback(
        uint256 tokenId_,
        address token_,
        uint256 amount_
    ) external onlyNftOwner(tokenId_) {
        address capsule_ = tokenIdToCapsule[tokenId_];
        IERC20(token_).safeTransferFrom(msg.sender, address(this), amount_);
        IERC20(token_).safeApprove(address(POOL), amount_);
        IWalletImplementation(capsule_).payback(token_, amount_, false);
    }

    function useAave(uint256 tokenId_, bytes calldata params_)
        external
        onlyNftOwner(tokenId_)
    {
        address capsule_ = tokenIdToCapsule[tokenId_];
        IWalletImplementation(capsule_).useAave(params_);
    }
}
