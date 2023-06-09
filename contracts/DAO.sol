// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Simple DAO contract that manages members and allows them to deposit and withdraw funds.

contract DAO {
    mapping (address => uint256) public balances;
    mapping (address => bool) public isMember;
    uint256 public totalBalance;

    event Deposit(address indexed depositor, uint256 amount);
    event Withdrawal(address indexed recipient, uint256 amount);
    event AddedMember(address indexed newMember);
    event RemovedMember(address indexed member);

    constructor(){
        isMember[msg.sender] = true; //deployer is first member
    }

    modifier onlyMembers(){
        require(isMember[msg.sender], "Must be a member");
        _;
    }

    function deposit() external payable{
        require(msg.value > 0, "Deposit must be greater than zero");
        balances[msg.sender] += msg.value;
        totalBalance += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external onlyMembers {
        require(amount > 0, "Withdawal must be greater than zero");
        require(amount <= balances[msg.sender], "Insufficient balance");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        totalBalance -= amount;
        emit Withdrawal(msg.sender, amount);
    }

    function addMember(address newMember) external onlyMembers(){
        require(newMember != address(0), "Invalid member adress");
        require(!isMember[newMember], "Address is already a member");
        isMember[newMember] = true;
        emit AddedMember(newMember);
    }

    function removeMember(address member) external onlyMembers{
        require(isMember[member], "Address is not a member");
        isMember[member] = false;
        emit RemovedMember(member);
    }

}