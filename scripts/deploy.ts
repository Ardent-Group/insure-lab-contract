import { ethers, run } from "hardhat";

async function main() {

   // ******Deploying the USDT contract ****//
  //  const USDT = await ethers.getContractFactory("USDT");
  //  const usdt = await USDT.deploy();
 
  //  await usdt.deployed();
  //  console.log(`USDT deployed to ${usdt.address}`);

  // // ******Deploying the insurance contract ****//
  // const Insure = await ethers.getContractFactory("insure");
  // const insure = await Insure.deploy(usdt.address);
  // await insure.deployed();

  // console.log(`Insurance contract deployed to ${insure.address}`);

  //  // ******Deploying the Governance contract ****// 
   const _minimumJoinDAO = BigInt(1e22)
   const _maximumJoinDAO = BigInt(1e23)
  //  const Governance = await ethers.getContractFactory("Governance");
  //  const governance = await Governance.deploy(usdt.address, insure.address, _minimumJoinDAO, _maximumJoinDAO);
  //  await governance.deployed();

  //  console.log(`Governance contract deployed to ${governance.address}`);



  // //  Verify contract
  // console.log(`Verifying mocked USDT.....`)
  // await run("verify:verify", {
  //   address: usdt.address,
  //   constructorArguments: []
  // });
  // console.log(`Verified mocked USDT`);

  console.log(`Verifying InsureLab Contract.....`);
  await run("verify:verify", {
    address: "0x06bF8c3D4B8fEa715D403693d532f5bF99C47ae3",
    constructorArguments: [
      "0x18d3BD3f2A9e1af0C2dF26a0f80E3af34abEe4F7"
    ]
  });
  console.log(`Verified InsureLab Contract`);
  console.log(`Verifying Governance contract......`)
  await run("verify:verify", {
    address: "0xA87F30B7CD469D65B08bb74f669821259AfD0e7d",
    constructorArguments: [
      "0x18d3BD3f2A9e1af0C2dF26a0f80E3af34abEe4F7",
      "0x06bF8c3D4B8fEa715D403693d532f5bF99C47ae3",
      _minimumJoinDAO,
      _maximumJoinDAO,
    ],
  })
  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
