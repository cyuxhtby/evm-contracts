// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LendingPool {
    error TransferFailed();
    error InsufficientCollateral();
    error NoActiveBorrow();
    error NoActivePosition();
    error InsufficientRepayment();

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

    function repay(uint256 amount) external {
        if (borrows[msg.sender].amount <= 0) {
            revert NoActivePosition();
        }
        uint256 owed = getOwedAmount(msg.sender);
        if (amount <= owed) {
            revert InsufficientRepayment();
        }
        if (!token.transferFrom(msg.sender, address(this), amount)) {
            revert TransferFailed();
        }
        // Return excess
        if (amount > owed) {
            if (!token.transfer(msg.sender, amount - owed)) {
                revert TransferFailed();
            }
        }
        // Resets all BorrowInfo
        // Contract holds no record of fulfilled positions
        delete borrows[msg.sender];
    }

    function getOwedAmount(address borrower) public view returns (uint256) {
        if (borrows[borrower].amount == 0) {
            return 0;
        }

        uint256 timeElaped = block.timestamp - borrows[msg.sender].borrowTimestamp;
        uint256 interest = (borrows[borrower].amount * timeElaped * INTEREST_RATE) / (SECONDS_IN_YEAR * 100);
        return borrows[borrower].amount + interest;
    }
}
