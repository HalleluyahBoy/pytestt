pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT

contract Platform {
    address public owner;

    // Struct to hold user data
    struct User {
        uint256 balance;
        uint256 rewardPoints;
        mapping (uint256 => bool) jobsCompleted;
    }



    // Struct to hold job data
    struct Job {
        uint256 jobId;
        string jobDescription;
        uint256 rewardAmount;
        address worker;
        bool isCompleted;
    }
    
    // Mapping to store users
    mapping (address => User) public users;
    
    // Mapping to store jobs
    mapping (uint256 => Job) public jobs;
    
    // Counter to keep track of job IDs
    uint256 public jobIdCounter;
    
    constructor() {
        owner = msg.sender;
    }
    
    // Function to add funds to user balance
    function addFunds() public payable {
        users[msg.sender].balance += msg.value;
    }
    
    // Function to allocate a job to a worker
    function allocateJob(string memory description, uint256 reward, address worker) public {
        require(msg.sender == owner, "Only the platform owner can allocate jobs.");
        require(users[worker].balance >= reward, "The worker has insufficient funds.");
        jobIdCounter++;
        jobs[jobIdCounter] = Job(jobIdCounter, description, reward, worker, false);
        users[worker].balance -= reward;
    }
    
    // Function for a worker to complete a job and claim the reward
    function completeJob(uint256 jobId) public {
        require(jobs[jobId].worker == msg.sender, "Only the worker assigned to the job can complete it.");
        require(jobs[jobId].isCompleted == false, "The job has already been completed.");
        jobs[jobId].isCompleted = true;
        users[msg.sender].jobsCompleted[jobId] = true;
        users[jobs[jobId].worker].rewardPoints += jobs[jobId].rewardAmount;
        jobs[jobId].worker = address(0);
    }
    
    // Function for a user to claim their reward points
    function claimRewardPoints() public {
        uint256 rewardPoints = users[msg.sender].rewardPoints;
        require(rewardPoints > 0, "No reward points available.");
        users[msg.sender].rewardPoints = 0;
        users[msg.sender].balance += rewardPoints;
    }
}