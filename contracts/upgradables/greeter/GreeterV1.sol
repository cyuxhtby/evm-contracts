// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Base contract that gets passed into proxy constructor

contract GreeterV1 {
    string public greeting;
    bool private initialized;

    // Upgradable contracts cannot have constructors so we use initialize() instead.
    function initialize() public {
        require(!initialized, "Contract instance has already been initialized");
        initialized = true;
        greeting = "Hello, World!";
    }

    function getGreeting() public view returns (string memory) {
        return greeting;
    }
}
