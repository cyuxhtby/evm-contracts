// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LendingPool {

    error TransferFailed();
    error InsufficientCollateral();
    error NoActiveBorrow();

    struct BorrowInfo {
        uint256 amount;
        uint256 borrowTimestamp;
    }

    IERC20 public token;
    mapping(address => uint256) public deposits;
    mapping(address => BorrowInfo) public borrows;

    event Deposited(address indexed caller, uint256 depositAmount);

    uint256 public constant INTEREST_RATE = 5; // 5% per year
    uint256 public constant SECONDS_IN_YEAR = 31536000; 

    constructor(address _token) {
        token = IERC20(_token);
    }

    function deposit(uint256 amount) external {
        if (!token.transferFrom(msg.sender, address(this), amount)) {
            revert TransferFailed();
        }
        deposits[msg.sender] += amount;
        emit Deposited(msg.sender, amount);
    }

    function borrow(uint256 amount) external {
        if (deposits[msg.sender] < amount) {
            revert InsufficientCollateral();
        }
        if (!token.transfer(msg.sender, amount)) {
            revert TransferFailed();
        }
        borrows[msg.sender] = BorrowInfo({
            amount: amount,
            borrowTimestamp: block.timestamp
        });
    }

    // TO DO
    function repay(uint256 amount) external {

    }
}
