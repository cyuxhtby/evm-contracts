// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// This contract allows users to vote on a proposal.
contract Voting {
    // The proposal being voted on.
    string public proposal;

    // The list of voters.
    address[] public voters;

    // The mapping of votes.
    mapping(address => bool) public votes;

    // Constructor to set the initial proposal.
    constructor(string memory _proposal) {
        proposal = _proposal;
    }

    // Function to add a new voter.
    function addVoter(address _voter) external {
        require(!isVoter(_voter), "Voter already exists");
        voters.push(_voter);
    }

    // Function to check if an address is a registered voter.
    function isVoter(address _voter) public view returns (bool) {
        for (uint i = 0; i < voters.length; i++) {
            if (voters[i] == _voter) {
                return true;
            }
        }
        return false;
    }

    // Function to vote.
    function vote() external {
        require(isVoter(msg.sender), "Not a registered voter");
        require(!votes[msg.sender], "Already voted");
        votes[msg.sender] = true;
    }

    // Function to get the total number of votes.
    function totalVotes() public view returns (uint) {
        uint count = 0;
        for (uint i = 0; i < voters.length; i++) {
            if (votes[voters[i]]) {
                count++;
            }
        }
        return count;
    }
}
