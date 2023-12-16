const { expect } = require("chai");
const { ethers } = require("hardhat");

const TOTAL_SUPPLY = ethers.utils.parseEther("150000000"); 

describe("Rsc", function () {

  let Rsc;
  let rsc;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {

    [owner, addr1, addr2] = await ethers.getSigners();

    Rsc = await ethers.getContractFactory("Rsc");
    rsc = await Rsc.deploy();

    // Mint tokens after deploy
    await rsc.mint(owner.address, TOTAL_SUPPLY);

  });

  describe("Deployment", function () {

    it("Should set the right owner", async function () {
      
      expect(await rsc.owner()).to.equal(owner.address);

    });

    it("Should mint total supply to owner", async function () {

      expect(await rsc.totalSupply()).to.equal(TOTAL_SUPPLY);
      
      const ownerBalance = await rsc.balanceOf(owner.address);
      expect(ownerBalance).to.equal(TOTAL_SUPPLY);

    });

  });

  describe("Transactions", function () {

    beforeEach(async function() {
      // Transfer tokens to addr1 first
      await rsc.transfer(addr1.address, 50);    
    })

    it("Should transfer tokens between accounts", async function () {   
      await rsc.connect(addr1).transfer(addr2.address, 50);

      const addr1Balance = await rsc.balanceOf(addr1.address);
      expect(addr1Balance).to.equal(0);

      const addr2Balance = await rsc.balanceOf(addr2.address);
      expect(addr2Balance).to.equal(50);
    });

  });  

  describe("Minting", async function () {

    it("Should only allow owner to mint tokens", async function () {
      
      await expect(
        rsc.connect(addr1).mint(addr1.address, 100)    
      ).to.be.revertedWith("Ownable: caller is not the owner");

      await rsc.mint(addr1.address, 100);

      const addr1Balance = await rsc.balanceOf(addr1.address);
      expect(addr1Balance).to.equal(100);

    }).timeout(100000);

  });

});