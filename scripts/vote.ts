import { ethers } from "hardhat";

async function main() {
    const [owner, address1] = await ethers.getSigners();

    const votingContract = await ethers.getContractFactory("Vote");

    const VotingContract = await votingContract.deploy("w3school", "w3s");
    
    await VotingContract.deployed();
    


    const minter = await VotingContract.mint(1000000);
    
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });