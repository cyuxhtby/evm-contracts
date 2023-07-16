// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract UpgradedGreeting {
    string public greeting;

    constructor() {
        greeting = "Hello, World! This contract has been upgraded!";
    }

    function getGreeting() public view returns (string memory) {
        return greeting;
    }
}