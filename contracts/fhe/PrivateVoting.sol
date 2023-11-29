// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.19;

import "fhevm/lib/TFHE.sol";
import "fhevm/abstracts/EIP712WithModifier.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract PrivateVoting is EIP712WithModifier, Ownable {
    
    string public proposal;
    mapping(address => bool) public registered;
    mapping(address => ebool) public votes;
    mapping(address => bool) public hasVoted;
    euint32 public yesTotal;
    euint32 public noTotal;

    event Result(uint32 yesTotal, uint32 noTotal);

    constructor() EIP712WithModifier("Authorization token", "1") {
        yesTotal = TFHE.asEuint32(0);
        noTotal = TFHE.asEuint32(0);
    }

    function setProposal(string memory _proposal) public onlyOwner {
        proposal = _proposal;
    }

    function register() public{
        require(!registered[msg.sender], "Already registered");
        registered[msg.sender] = true;
    }

    function submitVote(bytes calldata encryptedVote) external {
        require(registered[msg.sender], "Not a registered voter");
        require(!hasVoted[msg.sender], "Already voted");
        ebool vote = TFHE.asEbool(encryptedVote);
        votes[msg.sender] = vote;

        // Define incrementors of encrypted state
        euint32 one = TFHE.asEuint32(1); // increment
        euint32 zero = TFHE.asEuint32(0); // no increment

        // Ternary logic 
        euint32 incrementYes = TFHE.cmux(vote, one, zero); // (condition: vote, true value: one, false value: zero)
        euint32 incrementNo = TFHE.cmux(TFHE.not(vote), one, zero); // (condition: not vote, true value: one, false value: zero)

        yesTotal = TFHE.add(yesTotal, incrementYes);
        noTotal = TFHE.add(noTotal, incrementNo);
        hasVoted[msg.sender] = true;
    }

    function announceResult() public {
        uint32 finalYesTotal = TFHE.decrypt(yesTotal);
        uint32 finalNoTotal = TFHE.decrypt(noTotal);
        emit Result(finalYesTotal, finalNoTotal);
    }
    
}