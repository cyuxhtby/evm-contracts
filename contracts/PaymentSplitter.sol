// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract PaymentSplitter {
    address[] private payees;
    mapping(address => uint256) private shares;
    address private owner;
    
    event PayeeAdded(address account, uint256 shares);
    event PaymentReleased(address to, uint256 amount);

    constructor(address[] memory _payees, uint256[] memory _shares) payable {
        require(_payees.length == _shares.length);
        require(_payees.length > 0);

        owner = msg.sender;

        uint256 totalShares = 0;
        for (uint256 i = 0; i < _payees.length; i++) {
            require(_payees[i] != address(0));
            require(_shares[i] > 0);
            require(shares[_payees[i]] == 0);
            payees.push(_payees[i]);
            shares[_payees[i]] = _shares[i];
            totalShares += _shares[i];
            emit PayeeAdded(_payees[i], _shares[i]);
        }
    }

    function release(address payable _account) public {
        require(msg.sender == owner, "Only owner can release payments");
        require(shares[_account] > 0, "Account has no shares to release.");

        uint256 totalShares = 0;
        uint256 totalReleased = 0;
        for (uint256 i = 0; i < payees.length; i++) {
            totalShares += shares[payees[i]];
        }

        uint256 payment = address(this).balance * shares[_account] / totalShares;

        require(payment != 0);
        require(address(this).balance >= payment);

        totalReleased += payment;

        shares[_account] = 0;
        if (payment > 0) {
            _account.transfer(payment);
        }
        emit PaymentReleased(_account, payment);

    }

    function getPayees() public view returns (address[] memory) {
        return payees;
    }

    function getShares(address account) public view returns (uint256) {
        return shares[account];
    }
}
