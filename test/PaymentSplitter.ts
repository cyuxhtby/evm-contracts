const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("PaymentSplitter", function() {
  it("should split a payment equally between payees", async function() {
    const [owner, payee1, payee2, payee3] = await ethers.getSigners();
    const PaymentSplitter = await ethers.getContractFactory("PaymentSplitter");
    const paymentSplitter = await PaymentSplitter.deploy(
      [payee1.address, payee2.address, payee3.address],
      [1, 1, 1]
    );
    await paymentSplitter.connect(owner).release(payee1.address);
    const payee1Balance = await ethers.provider.getBalance(payee1.address);
    const payee2Balance = await ethers.provider.getBalance(payee2.address);
    const payee3Balance = await ethers.provider.getBalance(payee3.address);
    expect(payee1Balance).to.be.gt(0);
    expect(payee1Balance).to.equal(payee2Balance);
    expect(payee2Balance).to.equal(payee3Balance);
  });
});
