// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import "./Rsc.sol"; // Import the Rsc token contract

contract APIConsumer is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    uint256 public volume;
    bytes32 private jobId;
    uint256 private fee;
    Rsc public rscToken;
    event RequestVolume(bytes32 indexed requestId, uint256 volume);

  
    constructor(address _rscTokenAddress) ConfirmedOwner(msg.sender) {
        setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
        setChainlinkOracle(0x40193c8518BB267228Fc409a613bDbD8eC5a97b3);
        jobId = "ca98366cc7314957b8c012c72f05aeeb";
        fee = (1 * LINK_DIVISIBILITY) / 10; 
        rscToken = Rsc(_rscTokenAddress);
    }

    
    
    function requestVolumeData() public returns (bytes32 requestId) {
        Chainlink.Request memory req = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfill.selector
        );

       
        req.add(
            "get",
            "https://rscapi.onrender.com/api/fetchData"
        );

        
        req.add("path", "data"); // Chainlink nodes 1.0.0 and later support this format

       int256 timesAmount = 1;
        req.addInt("times", timesAmount);
       
        // Sends the request
        return sendChainlinkRequest(req, fee);
    }

   

    /**
     * Receive the response in the form of uint256
     */
    function fulfill(
        bytes32 _requestId,
        uint256 _volume
    ) public recordChainlinkFulfillment(_requestId) {
        emit RequestVolume(_requestId, _volume);
        volume = _volume;
    }

     function mintTokens(uint256 _balance) public {
        rscToken.mint(owner(), _balance); // Mint tokens to the owner's address
    }

    /**
     * Allow withdraw of Link tokens from the contract
     */
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }
}
