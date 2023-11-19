
const { ethers } = require('hardhat');


async function main() {

    // Deploy NFT contract
    const TokenRequest = await hre.ethers.getContractFactory("TokenRequest");
    const tokenRequest = await TokenRequest.deploy("Token Receipt","TB","0x9525e3F33fDC428291AB8ae261C5AEe41adBeE1E","0xe6b8a5CF854791412c1f6EFC7CAf629f5Df1c747", ethers.BigNumber.from("1").div(10)  , "0x361E9351a5A16Fd742A30a1c53880B85A4c23929");
    await tokenRequest.deployed();
    const confirmations = 5; // You can adjust this number as needed
    await Promise.all([
      tokenRequest.deployTransaction.wait(confirmations),
    ]);
    console.log("TokenRequest deployed to:", tokenRequest.address);
    await hre.run("verify:verify", {
      address: tokenRequest.address,
      constructorArguments: ["Token Receipt","TB","0x9525e3F33fDC428291AB8ae261C5AEe41adBeE1E","0xe6b8a5CF854791412c1f6EFC7CAf629f5Df1c747", ethers.BigNumber.from("1").div(10)  , "0x361E9351a5A16Fd742A30a1c53880B85A4c23929"], // Add constructor arguments if any
    });
  

   //Deploy Rsc Token
   const Rsc = await hre.ethers.getContractFactory("Rsc");
   const rsc = await Rsc.deploy();
   await rsc.deployed();
   console.log("Rsc ERC20 token deployed to:", rsc.address);
 
   console.log("Deployment completed!");
 
// Deploy Chainlink Contract
  const ChainlinkContract = await hre.ethers.getContractFactory("ChainlinkContract");
  const chainlinkContract = await ChainlinkContract.deploy();
  await chainlinkContract.deployed();
  console.log("ChainlinkContract deployed to:", chainlinkContract.address);



  // Deploy Tita ERC20 token
  const ColiseumToken = await hre.ethers.getContractFactory("Coliseum");
  const coliseumToken = await ColiseumToken.deploy();
  await coliseumToken.deployed();
  const confirmation = 5; // You can adjust this number as needed
  await Promise.all([
    coliseumToken.deployTransaction.wait(confirmation),
  ]);
  console.log("Coliseum ERC20 token deployed to:", coliseumToken.address);

  await hre.run("verify:verify", {
    address: coliseumToken.address,
    constructorArguments: [],
  });
 

  // Deploy Cmax ERC20 token
  const TitaToken = await hre.ethers.getContractFactory("Tita");
  const titaToken = await TitaToken.deploy();
  await titaToken.deployed();
  console.log("Tita deployed to:", titaToken.address);
 
  



  


}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });