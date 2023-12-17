// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenVesting is Ownable {
    IERC20 public token;

    struct VestingDetails {
        uint256 vestingStartTime;
        uint256 vestingDuration;
        uint256 totalTokens;
        uint256 releasedTokens;
    }

    mapping(address => VestingDetails) public beneficiaries;
    address[] public beneficiaryList;

    constructor(IERC20 _token) {
        token = _token;
    }

    function addBeneficiaries(
        address[] memory _addresses,
        uint256[] memory _vestingStartTimes,
        uint256[] memory _vestingDurations,
        uint256[] memory _totalTokens
    ) external onlyOwner {
        require(
            _addresses.length == _vestingStartTimes.length &&
            _vestingStartTimes.length == _vestingDurations.length &&
            _vestingDurations.length == _totalTokens.length,
            "Invalid input lengths"
        );

        for (uint256 i = 0; i < _addresses.length; i++) {
            address beneficiary = _addresses[i];
            require(beneficiary != address(0), "Invalid beneficiary address");
            require(_vestingStartTimes[i] >= block.timestamp, "Invalid vesting start time");
            require(_vestingDurations[i] > 0, "Invalid vesting duration");
            require(_totalTokens[i] > 0, "Invalid total tokens");

            beneficiaries[beneficiary] = VestingDetails({
                vestingStartTime: _vestingStartTimes[i],
                vestingDuration: _vestingDurations[i],
                totalTokens: _totalTokens[i],
                releasedTokens: 0
            });

            beneficiaryList.push(beneficiary);
        }
    }

    function release() external {
        address beneficiary = msg.sender;
        VestingDetails storage vestingDetails = beneficiaries[beneficiary];

        require(vestingDetails.vestingStartTime > 0, "Beneficiary not found");
        require(block.timestamp >= vestingDetails.vestingStartTime, "Vesting has not started yet");

        uint256 elapsedTime = block.timestamp - vestingDetails.vestingStartTime;
        uint256 vestedTokens = (elapsedTime * vestingDetails.totalTokens) / vestingDetails.vestingDuration;
        uint256 unreleasedTokens = vestedTokens - vestingDetails.releasedTokens;

        require(unreleasedTokens > 0, "No tokens left to release");

        vestingDetails.releasedTokens = vestedTokens;
        token.transfer(beneficiary, unreleasedTokens);
    }

    function airdrop() external onlyOwner {
        for (uint256 i = 0; i < beneficiaryList.length; i++) {
            address beneficiary = beneficiaryList[i];
            VestingDetails storage vestingDetails = beneficiaries[beneficiary];

            if (vestingDetails.vestingStartTime > 0 && block.timestamp >= vestingDetails.vestingStartTime) {
                uint256 elapsedTime = block.timestamp - vestingDetails.vestingStartTime;
                uint256 vestedTokens = (elapsedTime * vestingDetails.totalTokens) / vestingDetails.vestingDuration;
                uint256 unreleasedTokens = vestedTokens - vestingDetails.releasedTokens;

                if (unreleasedTokens > 0) {
                    vestingDetails.releasedTokens = vestedTokens;
                    token.transfer(beneficiary, unreleasedTokens);
                }
            }
        }
    }
}
