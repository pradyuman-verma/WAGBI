// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../../../dependencies/ERC4337/ERC4337.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./main.sol";

contract WagbiWallet is ERC4337, UCMarket {
    using ECDSA for bytes32;

    uint256 public wNonce;

    bytes32 internal constant DOMAIN_SEPARATOR_TYPEHASH =
        0x47e79534a245952e8b16893a336b85a3d9ea9fa8c573f3d803afb92a79469218;

    bytes32 internal constant WALLET_TX_TYPEHASH =
        0xeedfef42e81fe8cd0e4185e4320e9f8d52fd97eb890b85fa9bd7ad97c9a18de2;

    // authority
    // address public auth;

    constructor(
        address owner_,
        address entry_,
        address liquidityPoolAddr_,
        address oracleAddr_,
        address aaveDataProviderAddr_,
        address wethAddr_,
        address usdcAddr_,
        address daiAddr_,
        address wbtcAddr_
    )
        payable
        UCMarket(
            entry_,
            liquidityPoolAddr_,
            oracleAddr_,
            aaveDataProviderAddr_,
            wethAddr_,
            usdcAddr_,
            daiAddr_,
            wbtcAddr_
        )
    {}

    modifier onlyOwner() {
        require(msg.sender == auth, "NOT-AUTH");
        _;
    }

    modifier onlyEntryPoint() {
        require(msg.sender == address(ENTRY_POINT), "not-entry-point");
        _;
    }

    function nonce() public view virtual override returns (uint256) {
        return wNonce;
    }

    function entryPoint() public view virtual override returns (IEntryPoint) {
        return ENTRY_POINT;
    }

    function getMessageHash(address from_, uint256 _nonce)
        public
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    WALLET_TX_TYPEHASH,
                    DOMAIN_SEPARATOR_TYPEHASH,
                    from_,
                    _nonce
                )
            );
    }

    // over-riding Parent contract existing method
    function _validateAndUpdateNonce(UserOperation calldata userOp_)
        internal
        override
    {
        require(wNonce++ == userOp_.nonce, "wallet: invalid nonce");
    }

    function _payPrefund(uint256 requiredPrefund_) internal override {
        if (requiredPrefund_ != 0)
            payable(msg.sender).call{
                value: requiredPrefund_,
                gas: type(uint256).max
            }("");
    }

    function _validateSignature(
        UserOperation calldata userOp_,
        bytes32 data_,
        address
    ) internal view override {
        require(
            auth == data_.toEthSignedMessageHash().recover(userOp_.signature) ||
                tx.origin == address(0),
            "wrong-sig"
        );
    }

    function setOwner(address newOwner_) external onlyOwner {
        require(newOwner_ != address(0), "zero-owner");
        auth = newOwner_;
    }

    function domainSeparator() public view returns (bytes32) {
        return
            keccak256(
                abi.encode(DOMAIN_SEPARATOR_TYPEHASH, getChainId(), this)
            );
    }

    function getChainId() public view returns (uint256) {
        uint256 id_;
        assembly {
            id_ := chainid()
        }
        return id_;
    }

    receive() external payable {}
}
