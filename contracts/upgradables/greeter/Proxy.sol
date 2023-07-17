// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// This contract serves as a transparent interface to an underlying implementation contract.
// The state is held in this proxy contract while the logic is in the implementation.

contract Proxy {
    address private implementation;
    address public owner;

    constructor(address _implementation) {
        implementation = _implementation;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
    }

    function upgradeTo(address _newImplementation) public onlyOwner {
        implementation = _newImplementation;
    }

    // Function calls other than to upgrade() get forewarded to the set implementation.
    fallback() external payable {
        address _imp = implementation;
        // We must use an inline assembly block to work with EVM opcodes directly.
        assembly {
            // Copy the entire calldata of the transaction into memory
            // calldatacopy(destinationOffset, offset, len)
            calldatacopy(0, 0, calldatasize())

            // Forward call to logic contract
            // delegatecall(gas, addr, argOffset, argLen, returnOffset, returnLen)
            let result := delegatecall(gas(), _imp, 0, calldatasize(), 0, 0)

            // Copy the return data back to memory
            returndatacopy(0, 0, returndatasize())

            // Check the delegatecall result and return data back to caller
            switch result
            case 0 {
                // If unsuccessful, revert transaction and return error data
                // revert(offset, returnLen)
                revert(0, returndatasize())
            }
            default {
                // If successful, return intended data
                return(0, returndatasize())
            }
        }
    }
}
