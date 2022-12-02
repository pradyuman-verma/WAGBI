//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./events.sol";

contract Helpers is Events {
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
}
