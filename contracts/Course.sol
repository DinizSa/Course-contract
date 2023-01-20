// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Course {
    string public name;

    constructor(string memory _courseName) {
        name = _courseName;
    }
}