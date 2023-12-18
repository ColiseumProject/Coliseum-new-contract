// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Coliseum is ERC20, Ownable {
    uint256 public maxSupply = 1000000000 * 10 ** decimals(); 
    uint256 public totalMinted;
    bool public mintingPaused;
    uint256 public maxMintPerWallet;
    uint256 public maxMintPerTransaction;

    mapping(address => uint256) public mintedPerWallet;

    constructor(uint256 _maxMintPerWallet, uint256 _maxMintPerTransaction) ERC20("COLISEUM", "CMAX") {
        totalMinted = 0;
        mintingPaused = false;
        maxMintPerWallet = _maxMintPerWallet;
        maxMintPerTransaction = _maxMintPerTransaction;
    }

    modifier mintingNotPaused() {
        require(!mintingPaused, "Minting is paused");
        _;
    }

    function setMaxMintPerWallet(uint256 _maxMint) external onlyOwner {
        maxMintPerWallet = _maxMint;
    }

    function setMaxMintPerTransaction(uint256 _maxMint) external onlyOwner {
        maxMintPerTransaction = _maxMint;
    }

    function pauseMinting() external onlyOwner {
        mintingPaused = true;
    }

    function resumeMinting() external onlyOwner {
        mintingPaused = false;
    }

    function mint(address to, uint256 amount) public mintingNotPaused {
        require(totalMinted + amount <= maxSupply, "Exceeds max supply");
        require(mintedPerWallet[to] + amount <= maxMintPerWallet, "Exceeds max mint per wallet");
        require(amount <= maxMintPerTransaction, "Exceeds max mint per transaction");
        
        _mint(to, amount);
        totalMinted += amount;
        mintedPerWallet[to] += amount;
    }
}
