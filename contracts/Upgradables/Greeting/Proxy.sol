// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Proxy {
    address private implementation;

    constructor(address _implementation) {
        implementation = _implementation;
    }

    // Fallback function that delegates calls to the address returned by _implementation(). 
    // Will run if no other function in the contract matches the call data.
    fallback() external payable {
        address _impl = implementation;
        // We need to use an inline assembly block to perform delegatecall
        // `delegatecall` is a low-level function that allows a contract to dynamically load code from a different contract at runtime.
        assembly {
            // Copy the calldata to memory
            calldatacopy(0, 0, calldatasize())

            // Delegate the call to the implementation contract
            let result := delegatecall(gas(), _impl, 0, calldatasize(), 0, 0)

            // Copy the return data back to memory
            returndatacopy(0, 0, returndatasize())

            // Check the delegatecall result
            switch result
            // If the delegatecall was unsuccessful (result is 0), we revert the entire transaction, forwarding the return data as the reason.
            case 0 { revert(0, returndatasize()) }
            // If the delegatecall was successful (result is 1), we return the data that was returned from the delegatecall.
            default { return(0, returndatasize()) }
        }
    }
}
