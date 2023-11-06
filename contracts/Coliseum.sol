// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Coliseum is ERC20, Ownable {
    uint256 public maxSupply = 1000000000 * 10 ** decimals(); // 1 billion tokens
    uint256 public totalMinted;

    constructor() ERC20("COLISEUM", "CMAX") {
        totalMinted = 0;
    }

    function mint(address to, uint256 amount) public {
        require(totalMinted + amount <= maxSupply, "Exceeds max supply");
        _mint(to, amount);
        totalMinted += amount;
    }
}