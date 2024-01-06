// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import 'fhevm/lib/TFHE.sol';    

contract PrivateToken {

    uint32 public totalSupply;

    mapping (address => euint32) internal balances;

    address public contractOwner;

    function mint(euint32 encryptedAmount) public onlyOwner {
        euint32 amount = TFHE.asEuint32(encryptedAmount);
        balances[contractOwner] = balances[contractOwner] + amount;
        totalSupply = totalSupply + amount;
    }

    function transfer(address to, euint32 encryptedAmount) public {
        euint32 amount = TFHE.asEuint32(encryptedAmount);
        require(TFHE.le(amount, balances[msg.sender]), "Insufficient balance");
        balances[to] = balances[to] + amount;
        balances[msg.sender] = balances[msg.sender] - amount;
    }

    modifier onlyOwner() {
        require(msg.sender == contractOwner, "You are not the owner");
        _;
    }


}