// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Greeting {
    string public greeting;

    constructor() {
        greeting = "Hello, World!";
    }

    function getGreeting() public view returns (string memory) {
        return greeting;
    }
}
