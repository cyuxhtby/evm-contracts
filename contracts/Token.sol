// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

using SafeMath for uint256;

contract Token is ERC20, Ownable, Pausable {

    // Constructor and token management functions
    constructor() ERC20("Token", "TOKEN") {
        _mint(msg.sender, 100 * (10 ** uint256(decimals())));
    }

    function mint(uint256 amount) public onlyOwner {
        _mint(msg.sender, amount);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    // Time lock functions
    struct TimeLock {
        uint256 releaseTime;
        uint256 amount;
    }

    mapping (address => mapping (address => TimeLock[])) private _timeLocks;

    function lockTokens(address beneficiary, uint256 amount, uint256 releaseTime) public {
        require(releaseTime > block.timestamp, "Release time must be in the future");
        require(beneficiary != address(0), "Cannot lock tokens for zero address");
        _transfer(msg.sender, address(this), amount);
        _timeLocks[msg.sender][beneficiary].push(TimeLock(releaseTime, amount));
    }

    function unlockTokens(address sender, address beneficiary, uint256 index) public {
        TimeLock storage timeLock = _timeLocks[sender][beneficiary][index];
        require(block.timestamp >= timeLock.releaseTime, "Tokens are still locked");
        _timeLocks[sender][beneficiary][index] = _timeLocks[sender][beneficiary][_timeLocks[sender][beneficiary].length - 1];
        _timeLocks[sender][beneficiary].pop();
        _transfer(address(this), beneficiary, timeLock.amount);
    }

    function getTimeLockedAmount(address sender, address beneficiary) public view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < _timeLocks[sender][beneficiary].length; i++) {
            total += _timeLocks[sender][beneficiary][i].amount;
        }
        return total;
    }

    // Token swap function
    function swapTokens(uint256 amount, address recipient, address targetToken) public {
        require(targetToken != address(this), "Cannot swap tokens with self");
        require(ERC20(targetToken).totalSupply() > 0, "Invalid token address");
        _transfer(msg.sender, address(this), amount);
        uint256 targetTokenBalanceBefore = ERC20(targetToken).balanceOf(address(this));
        // call external function to perform the swap
        // e.g. Uniswap.swapTokens(amount, targetToken);
        uint256 targetTokenBalanceAfter = ERC20(targetToken).balanceOf(address(this));
        uint256 targetTokenReceived = targetTokenBalanceAfter - targetTokenBalanceBefore;
        ERC20(targetToken).transfer(recipient, targetTokenReceived);

        emit TokensSwapped(msg.sender, recipient, amount, targetTokenReceived);
    }

    // Event emitted when tokens are swapped
    event TokensSwapped(address indexed from, address indexed to, uint256 amount, uint256 receivedAmount);

    // Fee functions
    uint256 public constant MAX_FEE_PERCENTAGE = 1000; // 10%
    uint256 public feePercentage = 0;
    address public feeRecipient;

    function setFeePercentage(uint256 _feePercentage) external onlyOwner {
        require(_feePercentage <= MAX_FEE_PERCENTAGE, "Fee percentage cannot exceed MAX_FEE_PERCENTAGE");
        feePercentage = _feePercentage;
    }

    function setFeeRecipient(address _feeRecipient) external onlyOwner {
        require(_feeRecipient != address(0), "Fee recipient cannot be zero address");
        feeRecipient = _feeRecipient;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {
    uint256 feeAmount = 0;
    if (feePercentage > 0) {
    feeAmount = amount.mul(feePercentage).div(10000); // calculate fee amount using SafeMath
    super._transfer(sender, feeRecipient, feeAmount); // transfer fee to fee recipient
    amount = amount.sub(feeAmount); // subtract fee from amount to transfer using SafeMath
    }
    super._transfer(sender, recipient, amount); // transfer remaining amount
}
}
