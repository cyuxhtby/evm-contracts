import { ethers } from 'hardhat';
import { Signer} from 'ethers';
import { expect } from 'chai';
import { Marketplace } from '../typechain';

describe('Marketplace', function() {
  let marketplace: Marketplace;
  let owner: Signer;
  let addr1: Signer;
  let addr2: Signer;

  beforeEach(async function () {
    const MarketplaceFactory = await ethers.getContractFactory("Marketplace");
    [owner, addr1, addr2] = await ethers.getSigners();
    marketplace = (await MarketplaceFactory.connect(owner).deploy()) as Marketplace;
    await marketplace.deployed();
  });

  it('Should be deployed properly', async function () {
    expect(marketplace.address).to.exist;
  });

  describe('Adding and Buying Items', function () {
    it('Should allow items to be added', async function () {
      await marketplace.connect(owner).addItem('Test Item', ethers.utils.parseEther('1'));
      const item = await marketplace.getItem(0);
      expect(item[0]).to.equal('Test Item');
      expect(item[2]).to.equal(ethers.utils.parseEther('1'));
      expect(item[3]).to.equal(false);
    });

    it('Should allow items to be bought', async function () {
      await marketplace.connect(owner).addItem('Test Item', ethers.utils.parseEther('1'));
      await marketplace.connect(addr1).buyItem(0, { value: ethers.utils.parseEther('1') });
      const item = await marketplace.getItem(0);
      expect(item[3]).to.equal(true);
    });

    it('Should not allow non-owners to remove an item', async function () {
      await marketplace.connect(owner).addItem('Test Item', ethers.utils.parseEther('1'));
      await expect(marketplace.connect(addr1).removeItem(0)).to.be.revertedWith('Only the seller can call this function');
    });
  });
});
