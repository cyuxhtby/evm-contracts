// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "@fhenixprotocol/contracts/FHE.sol";
import "@fhenixprotocol/access/Permissioned.sol";

contract PrivateToken {

    uint32 public totalSupply;

    mapping (address => euint32) internal balances;

    address public contractOwner;

    function mint(inEunt32 calldata encryptedAmount) public onlyOwner {
        euint32 amount = FHE.asEuint32(encryptedAmount);
        balances[contractOwner] = balances[contractOwner] + amount;
        totalSupply = totalSupply + amount;
    }

    function transfer(address to, inEunt32 calldata encryptedAmount) public {
        euint32 amount = FHE.asEuint32(encryptedAmount);
        require(FHE.le(amount, balances[msg.sender]), "Insufficient balance");
        balances[to] = balances[to] + amount;
        balances[msg.sender] = balances[msg.sender] - amount;
    }

    modifier onlyOwner() {
        require(msg.sender == contractOwner, "You are not the owner");
        _;
    }


}