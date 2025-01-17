// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

abstract contract ReentrancyGuard {

    
    // Updating a bool triggers a read modify write cycle since it only uses a portion of a 256 bit word.
    // We define states with a uint256 since an update overwrites the entire slot, making it less gas-intensive.
    // The choice of states 1 and 2 avoids relying on the evm gas refund for resetting values to 0 as defined in EIP-2200.
    // This simplifies gas cost calculations and avoids issues with refund caps (limited to 20% of transaction gas).
    uint256 private constant ENTERED = 1;
    uint256 private constant NOT_ENTERED = 2;

    uint256 private _status;

    error ReentrancyGuardReentrantCall();

    // Eat the init cost
    constructor() {
        _status = NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = NOT_ENTERED;
    } 

    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }

}
