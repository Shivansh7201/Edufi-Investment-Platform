// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EduFiInvestmentPlatform {
    address public owner;

    struct Student {
        string name;
        uint256 fundsRequested;
        uint256 fundsReceived;
        bool isApproved;
    }

    struct Investor {
        uint256 totalContribution;
    }

    mapping(address => Student) public students;
    mapping(address => Investor) public investors;

    event FundsContributed(address indexed investor, uint256 amount);
    event StudentRegistered(address indexed student, string name, uint256 fundsRequested);
    event FundsApproved(address indexed student, uint256 amount);
    event FundsWithdrawn(address indexed student, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    modifier onlyApprovedStudent() {
        require(students[msg.sender].isApproved, "You are not approved to withdraw funds.");
        _;
    }

    // Register a student
    function registerStudent(string memory _name, uint256 _fundsRequested) public {
        require(students[msg.sender].fundsRequested == 0, "Student is already registered.");
        students[msg.sender] = Student(_name, _fundsRequested, 0, false);

        emit StudentRegistered(msg.sender, _name, _fundsRequested);
    }

    // Contribute funds as an investor
    function contributeFunds() public payable {
        require(msg.value > 0, "Contribution must be greater than 0.");
        investors[msg.sender].totalContribution += msg.value;

        emit FundsContributed(msg.sender, msg.value);
    }

    // Approve funds for a student
    function approveFunds(address _student) public onlyOwner {
        require(students[_student].fundsRequested > 0, "Student is not registered.");
        require(!students[_student].isApproved, "Funds are already approved for this student.");

        students[_student].isApproved = true;
        students[_student].fundsReceived = students[_student].fundsRequested;

        emit FundsApproved(_student, students[_student].fundsRequested);
    }

    // Withdraw funds as an approved student
    function withdrawFunds() public onlyApprovedStudent {
        uint256 amount = students[msg.sender].fundsReceived;
        require(amount > 0, "No funds available for withdrawal.");

        students[msg.sender].fundsReceived = 0;
        payable(msg.sender).transfer(amount);

        emit FundsWithdrawn(msg.sender, amount);
    }

    // Get balance of the contract
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
