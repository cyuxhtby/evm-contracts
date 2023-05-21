import { ethers } from 'hardhat';

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(`Deploying contracts with the account: ${deployer.address}`);

  // Deploy Voting contract
  const Voting = await ethers.getContractFactory("Voting");
  const voting = await Voting.deploy("my test proposal");

  console.log(`Voting contract deployed at address: ${voting.address}`);
}

main().then(() => process.exit(0)).catch(error => {
  console.error(error);
  process.exit(1);
});
