import { ethers } from 'hardhat';

async function main() {
  // hardhat network generated accounts
  const payees = ['0x70997970C51812dc3A010C7d01b50e0d17dc79C8', '0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC', '0x90F79bf6EB2c4f870365E785982E1f101E93b906']; 
  // first payee will receive 1/6th of the total payment, the second payee will receive 2/6ths (or 1/3rd), and the third payee will receive 3/6ths or 1/2
  const shares = [1, 2, 3]; 

  const PaymentSplitter = await ethers.getContractFactory('PaymentSplitter');
  const paymentSplitter = await PaymentSplitter.deploy(payees, shares);

  console.log('PaymentSplitter deployed to:', paymentSplitter.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
