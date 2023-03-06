import { ethers, run } from "hardhat";

async function main() {

  //  // ******Deploying the USDT contract ****//
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
  //  const _minimumJoinDAO = BigInt(1000 * 10**18)
  //  const _maximumJoinDAO = BigInt(10000 * 10**18)

  //  console.log(_minimumJoinDAO, _maximumJoinDAO, "dhsd")
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
    address: "0x8045D17C25568f8Ea1cCa286d88926bB2A957b99",
    constructorArguments: [
      "0xE8377ef90628B7f03b440bd2c18956fDAFA355D9"
    ]
  });
  console.log(`Verified InsureLab Contract`);
  console.log(`Verifying Governance contract......`)
  await run("verify:verify", {
    address: "0xD287cc4B99cA787c0d7F949deD9961531aEda71E",
    constructorArguments: [
      "0xE8377ef90628B7f03b440bd2c18956fDAFA355D9",
      "0x8045D17C25568f8Ea1cCa286d88926bB2A957b99",
      BigInt(1000 * 10**18),
      BigInt(10000 * 10**18),
    ],
  })
  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

