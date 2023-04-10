import { ethers } from 'hardhat';
import { expect } from 'chai';
import { Voting } from '../typechain';

describe('Voting', function () {
  let voting: Voting;
  const contractAddress = ''; // replace with your contract address

  beforeEach(async function () {
    const VotingFactory = await ethers.getContractFactory('Voting');
    voting = await VotingFactory.attach(contractAddress) as Voting;
  });

  it('should allow adding voters', async function () {
    const voter1 = ethers.Wallet.createRandom().address;
    const voter2 = ethers.Wallet.createRandom().address;
    await voting.addVoter(voter1);
    await voting.addVoter(voter2);
    expect(await voting.isVoter(voter1)).to.equal(true);
    expect(await voting.isVoter(voter2)).to.equal(true);
  });

  it('should not allow adding the same voter twice', async function () {
    const voter1 = ethers.Wallet.createRandom().address;
    await voting.addVoter(voter1);
    await expect(voting.addVoter(voter1)).to.be.revertedWith('Voter already exists');
  });

  it('should allow voting', async function () {
    const voter1 = ethers.Wallet.createRandom();
    const voter2 = ethers.Wallet.createRandom();
    await voting.addVoter(voter1.address);
    await voting.addVoter(voter2.address);
    await voting.connect(voter1).vote();
    await voting.connect(voter2).vote();
    expect(await voting.totalVotes()).to.equal(2);
  });

  it('should not allow voting twice', async function () {
    const voter1 = ethers.Wallet.createRandom();
    await voting.addVoter(voter1.address);
    await voting.connect(voter1).vote();
    await expect(voting.connect(voter1).vote()).to.be.revertedWith('Already voted');
  });
});
