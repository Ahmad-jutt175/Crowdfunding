// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    address payable public projectOwner;
    uint public fundingGoal;
    uint public deadline;
    mapping(address => uint) public contributions;
    uint public totalContributions;

    constructor(address payable _projectOwner, uint _fundingGoalInEther, uint _durationInMinutes) {
        projectOwner = _projectOwner;
        fundingGoal = _fundingGoalInEther * 1 ether; // convert ETH to wei
        deadline = block.timestamp + _durationInMinutes * 1 minutes; // calculate deadline
    }

    modifier onlyOwner() {
        require(msg.sender == projectOwner, "Only the project owner can call this function");
        _;
    }

    function contribute() external payable {
        require(block.timestamp < deadline, "Funding period has ended");
        contributions[msg.sender] += msg.value;
        totalContributions += msg.value;
    }

    function checkGoalReached() external view returns (bool) {
        return totalContributions >= fundingGoal;
    }

    function claimFunds() external {
        require(block.timestamp >= deadline, "Funding period has not ended yet");
        require(totalContributions >= fundingGoal, "Funding goal has not been reached");

        uint amount = address(this).balance;
        projectOwner.transfer(amount);
    }

    function reclaimContribution() external {
        require(block.timestamp >= deadline, "Funding period has not ended yet");
        require(totalContributions < fundingGoal, "Funding goal has been reached");

        uint contribution = contributions[msg.sender];
        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(contribution);
    }

    // Fallback function to receive Ether
    receive() external payable {
        contribute();
    }

    // Function to get the current contract balance (in Wei)
    function getContractBalance() external view returns (uint) {
        return address(this).balance;
    }
}

