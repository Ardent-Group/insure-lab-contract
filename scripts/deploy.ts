import { ethers } from "hardhat";

async function main() {

   // ******Deploying the USDT contract ****//
   const USDT = await ethers.getContractFactory("USDT");
   const usdt = await USDT.deploy();
 
   await usdt.deployed();
   console.log(`USDT deployed to ${usdt.address}`);

  // ******Deploying the insurance contract ****//
  const Insure = await ethers.getContractFactory("insure");
  const insure = await Insure.deploy(usdt.address);
  await insure.deployed();

  console.log(`Insurance contrat deployed to ${insure.address}`);

   // ******Deploying the Governance contract ****// 
   const _minimumJoinDAO = 1e22
   const _maximumJoinDAO = 1e23
   const Governance = await ethers.getContractFactory("Governance");
   const governance = await Governance.deploy(usdt.address, insure.address, _minimumJoinDAO, _maximumJoinDAO);
   await governance.deployed();

   console.log(`Insurance contrat deployed to ${governance.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
