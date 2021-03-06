// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const { ethers, upgrades } = require("hardhat")

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');
  ;[owner] = await ethers.getSigners()
  // // We get the contract to deploy
  // const getcontract = await ethers.getContractFactory(
  //   "DepositAndWithdrawUpgrade"
  // )
  // const contractMain = await upgrades.deployProxy(getcontract)
  // await contractMain.deployTransaction.wait(1)
  // const contract2 = await ethers.getContractFactory("DappToken")
  // const DappToken = await contract2.deploy()
  // await DappToken.deployTransaction.wait(1)
  // const contract3 = await ethers.getContractFactory("MockToken")
  // const MockToken = await contract3.deploy()
  // await MockToken.deployTransaction.wait(1)

  // console.log("contract token", contractMain.address) //0xa3b5a08575150c513bDe88A5BE459Ce8b94FB1Be
  // console.log("dapptoken ", DappToken.address) //0x0bC5A7d14A530D13CabD90f1c6b719C2D484357A
  // console.log("mocktoken ", MockToken.address) //0xBCC84aB2ab1f84dC002EE2e6d5DE521c981453F3

  console.log("adding allowed tokens")

  // implementation contract = 0xdbc765fb8f396209afe38286a4343be4651794b8
  const contractMain = await ethers.getContractAt(
    "DepositAndWithdrawUpgrade",
    "0xE81B360050221377AFbb980c828792146Dc81612"
  )
  const DappToken = await ethers.getContractAt(
    "DappToken",
    "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56"
  )
  const MockToken = await ethers.getContractAt(
    "MockToken",
    "0x8D672014Fb107cB409dCcd9042DdA3b97313F4C3"
  )
  tx1 = await contractMain.connect(owner).addAllowedToken(DappToken.address)
  await tx1.wait(1)
  console.log("added dapp token")
  tx2 = await contractMain.connect(owner).addAllowedToken(MockToken.address)
  await tx2.wait(1)
  console.log("added mock token")

  const approveDT = await DappToken.connect(owner).approve(
    "0xE81B360050221377AFbb980c828792146Dc81612",
    ethers.utils.parseEther("3.5")
  )
  await approveDT.wait(1)
  const depositDT = await contractMain
    .connect(owner)
    .deposit(
      "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56",
      ethers.utils.parseEther("3.5")
    )
  await depositDT.wait(1)
  console.log("deposit DappToken successfull")
  const approveMT = await MockToken.connect(owner).approve(
    "0xE81B360050221377AFbb980c828792146Dc81612",
    ethers.utils.parseEther("99000")
  )
  await approveMT.wait(1)
  const depositMT = await contractMain
    .connect(owner)
    .deposit(
      "0x8D672014Fb107cB409dCcd9042DdA3b97313F4C3",
      ethers.utils.parseEther("99000")
    )
  await depositMT.wait(1)
  console.log("deposit MockToken successfull")
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
