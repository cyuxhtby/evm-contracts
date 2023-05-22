import { ethers } from 'hardhat';

async function main() {
    const Marketplace = await ethers.getContractFactory("Marketplace");
    const marketplace = await Marketplace.deploy();
    await marketplace.deployed();

    console.log(
        `Marketplace deployed to address: ${marketplace.address}`
    );
}

main().catch((error) => {
    console.log(error);
    process.exitCode = 1;
});