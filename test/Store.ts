import { expect } from 'chai';
import { ethers } from 'hardhat';
import { Contract, Signer, BigNumber } from 'ethers';


interface Item {
    name: string;
    id: number;
    price: BigNumber;
    isSold: boolean;
}

describe("Store", function () {
    let store: Contract;
    let manager: Signer;
    // to test one account
    let addr1: Signer;
    // to test multiple accounts
    let addresses: Signer[];

    before(async () => {
        // Get contract factory and signers 
        const Store = await ethers.getContractFactory("Store");
        [manager, addr1, ...addresses] = await ethers.getSigners();

        // Using the Store ContractFactory to deploy the contract. This returns a Promise.
        store = await Store.deploy();
        // Ensuring the Promise resolves by waiting for the contract to be fully deployed.
        await store.deployed();


    });

    it("should add a collection of items to inventory as manager", async function () {
        const item1: Item = { name: "blue shirt", id: 0, price: ethers.utils.parseEther("0.01"), isSold: false };
        const item2: Item = { name: "black pants", id: 1, price: ethers.utils.parseEther("0.01"), isSold: false };
        const item3: Item = { name: "purple shoes", id: 2, price: ethers.utils.parseEther("0.02"), isSold: false };

        // Add items as manager
        await store.connect(manager).addToInventory(item1.name, item1.id, item1.price);
        await store.connect(manager).addToInventory(item2.name, item2.id, item2.price);
        await store.connect(manager).addToInventory(item3.name, item3.id, item3.price);
    });

    it("should fail to add an item to inventory as a non-manager", async function(){
        const item4: Item = { name: "red cap", id: 3, price: ethers.utils.parseEther("0.01"), isSold: false};

        // Add item as non-manager
        await expect(store.connect(addr1).addToInventory(item4.name, item4.id, item4.price)).to.be.rejectedWith("You are not the manager");
    });

    it("should list the items in the inventory", async function () {
        // Retrieve the count of items in the inventory
        const count = await store.getInventoryCount();

        for (let i = 0; i < count; i++) {
            const [name, id, price, isSold] = await store.getItem(i);
            console.log(`Item ${i}: ${name}, ${id}, ${price.toString()}, ${isSold}`);
        }
    });

    it("should allow a user to buy and item", async function () {
        await store.connect(addr1).buy(0, { value: ethers.utils.parseEther("0.01") });

        // Check that the item is now marked as sold
        const item = await store.getItem(0);
        expect(item[3]).to.equal(true);
    });
})

