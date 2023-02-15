import { loadFixture } from "@nomicfoundation/hardhat-network-helpers"
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs"
import { expect } from "chai";
import { ethers } from "hardhat";


describe("InsureLab", function() {
    // ficture deployer

    async function deployInsureLabFixture() {
        const [owner, accountTwo, accountThree] = await ethers.getSigners();

        // deploy mUSDT
        const mUSDT = await ethers.getContractFactory("USDT");
        const usdt = await mUSDT.deploy();

        // deploy insure contract
        const INSURELab = await ethers.getContractFactory("insure");
        const insureLab = await INSURELab.deploy(usdt.address);

        // deploy governance contract
        const _minimumJoinDAO = BigInt(1e22)
        const _maximumJoinDAO = BigInt(1e23)
        const Governance = await ethers.getContractFactory("Governance");
        const governance = await Governance.deploy(usdt.address, insureLab.address, _minimumJoinDAO, _maximumJoinDAO)


        return { usdt, owner, accountTwo, accountThree, insureLab, governance, _minimumJoinDAO, _maximumJoinDAO }
    }

    describe("AfterDeployment", function() {
        it("Should check owner balance", async function() {
            const {usdt, owner} = await loadFixture(deployInsureLabFixture);
            const expectedAmount = ethers.utils.parseEther("1000000000")

            expect(Number( await usdt.balanceOf(owner.address))).to.be.equal(Number(expectedAmount));
        })
    })

    describe("Insurer", function() {
        it("should create new insurance cover and add to existing", async function() {
            const {insureLab, owner, usdt, accountTwo, accountThree } = await loadFixture(deployInsureLabFixture);
            const _protocolName = "Uniswap"
            const _protocolDomain = "https://app.uniswap.org/"
            const _description = "A proper check have benn made that this protocol is entirely safe from hack";
            const _coverAmount = ethers.utils.parseEther("10000")
            const _riskLevel = 0;

            await usdt.approve(insureLab.address, _coverAmount)
            expect(Number(await usdt.allowance(owner.address, insureLab.address))).to.be.equal(Number(_coverAmount))
            const id = await insureLab.id();
            await insureLab.createNewInsure(_protocolName,_protocolDomain,_description, _coverAmount, _riskLevel);

            console.log(await insureLab.getProtocolData(id), "protocol data by id after creating insurance")


            // Creating on existing insure
            const _coverAmount2 = ethers.utils.parseEther("1000");
            
            await usdt.transfer(accountTwo.address, _coverAmount2);
            await usdt.transfer(accountThree.address, _coverAmount2);
            expect(Number(await usdt.balanceOf(accountTwo.address))).to.be.equal(Number(_coverAmount2))
            expect(Number(await usdt.balanceOf(accountThree.address))).to.be.equal(Number(_coverAmount2))

            await usdt.connect(accountTwo).approve(insureLab.address, _coverAmount2)
            expect(Number(await usdt.connect(accountTwo).allowance(accountTwo.address, insureLab.address))).to.be.equal(Number(_coverAmount2))


            await insureLab.connect(accountTwo).createOnExistinginsure(id, _coverAmount2)

            console.log(await insureLab.getProtocolData(id), "protocol data by id")


            // buy cover base on the available cover
            const _coverPeriod = "30" // 13-Mar-2023

            // not proper test for determining actual cover to pay
            await usdt.connect(accountThree).approve(insureLab.address, _coverAmount2)
            expect(Number(await usdt.connect(accountThree).allowance(accountThree.address, insureLab.address))).to.be.equal(Number(_coverAmount2))
            
            await insureLab.connect(accountThree).buyCover(id, _coverPeriod, _coverAmount2)

            console.log(await usdt.connect(accountThree).balanceOf(accountThree.address), "balance after buying cover");


        })
    })
})