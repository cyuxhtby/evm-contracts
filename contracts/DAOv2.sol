// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Extended DAO functionality by introducing proposals, voting, admin role, and member struct.

contract DAOv2 {

    struct Proposal {
        string description;
        uint256 voteCount;
        bool executed;
    }

    struct Member {
        address memberAddress;
        uint256 memberSince;
    }

    address public admin;
    address[] public members;
    Proposal[] public proposals;
    
    mapping (address => Member) public memberInfo;
    mapping (address => mapping(uint256 => bool)) public votes;
    mapping (address => uint256) public balances;
    mapping (address => bool) public isMember;
    uint256 public totalBalance;


    event Deposit(address indexed depositor, uint256 amount);
    event Withdrawal(address indexed recipient, uint256 amount);
    event AddMember(address indexed newMember);
    event RemovedMember(address indexed member);
    event ProposalCreated(uint256 proposalId, string description);
    event Voted(address indexed voter, uint256 proposalId, uint256 tokenAmount);
    event ProposalExecuted(uint256 proposalId);

    constructor(){
        admin = msg.sender;
        isMember[msg.sender] = true;
    }

    modifier onlyMembers() {
        require(isMember[msg.sender], "Must be a member");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Must be the admin");
        _;
    }

    function deposit() external payable{
        require(msg.value > 0, "Deposit must be greater than zero");
        balances[msg.sender]+= msg.value;
        totalBalance += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) external onlyMembers{
        require(_amount > 0, "Withdrawal must be greater than zero");
        require(_amount <= balances[msg.sender], "Insufficient balance");
        balances[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
        totalBalance -= _amount;
        emit Withdrawal(msg.sender, _amount);
    }

    function addMember(address _member) external onlyAdmin{
        require(_member != address(0), "Invalid member address");
        require(!isMember[_member], "Address is already a member");
        isMember[_member] = true;
        emit AddMember(_member);
    }

    function removeMember(address _member) external onlyAdmin{
        require(isMember[_member], "Address is not a member");
        isMember[_member] = false;
        emit RemovedMember(_member);
    }

    function createProposal(string memory _description) public onlyMembers {
        Proposal memory newProposal = Proposal({
            description: _description,
            voteCount: 0,
            executed: false
        });

        proposals.push(newProposal);
        emit ProposalCreated(proposals.length - 1, _description);
    }

    function vote(uint256 _proposalId) public onlyMembers {
        require(!votes[msg.sender][_proposalId], "Member has already voted on this proposal");
        require(_proposalId < proposals.length, "Proposal does not exist");

        proposals[_proposalId].voteCount += 1;
        votes[msg.sender][_proposalId] = true;

        emit Voted(msg.sender, _proposalId, 1);
    }

    function executeProposal(uint256 proposalId) public onlyAdmin {
        require(proposalId < proposals.length, "Proposal does not exist");
        require(!proposals[proposalId].executed, "Proposal has already been executed");

        proposals[proposalId].executed = true;
        emit ProposalExecuted(proposalId);
    }   
}
