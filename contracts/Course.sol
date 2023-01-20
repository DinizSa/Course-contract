// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Course {
    string public name;
    enum Status {Open, Closed}
    Status public status = Status.Open;
    
    struct Student {
        string name;
        bool isRegistered;
        uint16[] grades;
        uint totalScore;
    }
    mapping(address => Student) public students;
    address[] public studentAddresses;

    constructor(string memory _courseName) {
        name = _courseName;
    }

    function closeCourse() public onlyOpenCourse {
        status = Status.Closed;
    }

    modifier onlyOpenCourse() {
        require(status == Status.Open, "Course not open");
        _;
    }
    modifier onlyClosedCourse() {
        require(status == Status.Closed, "Course not closed");
        _;
    }
}