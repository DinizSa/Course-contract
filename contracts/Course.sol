// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Course {
    string public name;
    enum Status {Open, Closed}
    Status public status = Status.Open;
    uint public immutable registrationFee;
    
    struct Student {
        string name;
        bool isRegistered;
        uint16[] grades;
        uint totalScore;
    }
    mapping(address => Student) public students;
    address[] public studentAddresses;

    error InvalidRegistrationFee();

    constructor(string memory _courseName, uint _registrationFee) {
        name = _courseName;
        registrationFee = _registrationFee;
    }

    function register(string calldata studentName) public payable onlyOpenCourse {
        Student storage student = students[msg.sender];
        require(!student.isRegistered, "Student already registered");
        if (msg.value != registrationFee) {
            revert InvalidRegistrationFee();
        }
        
        student.name = studentName;
        student.isRegistered = true;
        assert(student.isRegistered);
        studentAddresses.push(msg.sender);
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