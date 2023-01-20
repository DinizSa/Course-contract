// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Ownable {
    address internal owner; 

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }
    constructor(address _owner) {
        owner = _owner;
    }
}