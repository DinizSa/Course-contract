// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Ownable.sol";

contract Course is Ownable {
    string public name;
    enum Status {Open, Closed}
    Status public status = Status.Open;
    uint public immutable registrationFee;
    uint16 constant internal MAX_GRADE = 1_000;
    
    struct Student {
        string name;
        bool isRegistered;
        uint16[] grades;
        uint totalScore;
    }
    mapping(address => Student) public students;
    address[] public studentAddresses;

    error InvalidRegistrationFee();

    constructor(string memory _courseName, uint _registrationFee) Ownable(msg.sender) {
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

    function addGrade(address student, uint16 grade) internal {
        require(grade <= MAX_GRADE, "Grade exceeds maximum");
        students[student].grades.push(grade);
        students[student].totalScore += grade;
    }

    function addGrades(address student, uint16[] memory grades) public onlyOpenCourse onlyOwner {
        for (uint i = 0; i < grades.length; i++) {
            addGrade(student, grades[i]);
        }
    }

    function getGrades(address student) external view returns (uint16[] memory) {
        return students[student].grades;
    }

    function getFinalScore(address student) public view onlyClosedCourse returns (uint) {
        return students[student].totalScore / students[student].grades.length;
    }

    function closeCourse() public onlyOpenCourse onlyOwner {
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