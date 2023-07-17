// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Updated contracted that get passed into proxy's upgradeTo()

contract GreeterV2 {
    string public greeting;
    bool private initialized;

    // Upgradable contracts cannot have constructors so we use initialize() instead.
    function initialize() public {
        require(!initialized, "Contract instance has already been initialized");
        initialized = true;
        greeting = "Hello, World...Again!";
    }

    function getGreeting() public view returns (string memory) {
        return greeting;
    }
}
