// SPDX-License-Identifier: MIT

// Min needed EIP-1153 Transient storage
pragma solidity ^0.8.24;

abstract contract ReentrancyGuardTransient {


    // Transient storage based reentrancy guard requires a dedicated slot to store entered and non-entered states during a transaction's execution and automatically resets values to defaults on completion.
    // The slot is the hash of the unique string, subtracts 1, and clears the last bytes to align with the 32-byte word and to reside outside of dynamically computed slots, avoiding conflicts.

    // Specifically, the hash is the unique key for evm key-value storage mapping
    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ReentrancyGuard")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant REENTRANT_GUARD_STORAGE = 0x9b779b17422d0df92223018b32b4d1fa46e071723d6817e2486d003becc55f00;

    error ReentrancyGuardReentrantCall();

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() internal {
        if (_reentrancyGuardEntered()) {
            revert ReentrancyGuardReentrantCall();
        }

        assembly ("memory-safe") {
            tstore(REENTRANT_GUARD_STORAGE, true)
        }
    }

    function _nonReentrantAfter() internal {
        assembly ("memory-safe") {
            tstore(REENTRANT_GUARD_STORAGE, false)
        }
    }

    function _reentrancyGuardEntered() internal view returns (bool) {
        bool value;
        assembly ("memory-safe") {
            value := tload(REENTRANT_GUARD_STORAGE)
        }
        return value;
    }

}