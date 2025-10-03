// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract MameVoter {
    string[] public candidateNames;
    mapping(uint32 => uint256) public votesReceived;
    mapping(address => bool) private hasVoted;
    address payable public owner;

    constructor(string[] memory candidateList) {
        candidateNames = candidateList;
        owner = payable(msg.sender);
    }

    event VoteEmitted(string candidateName);

    // Restrict voting to one per address
    modifier hasNotVoted() {
        require(!hasVoted[msg.sender], "You have already voted.");
        _;
    }

    // Restrict access to the owner
    modifier ownerOnly() {
        require(msg.sender == owner, "You are not the owner.");
        _;
    }

    // allow an address to vote for a candidate
    function vote(uint32 candidateId) external hasNotVoted {
        require(candidateId < candidateNames.length, "Invalid candidate ID.");
        votesReceived[candidateId]++;
        hasVoted[msg.sender] = true;
        emit VoteEmitted(candidateNames[candidateId]);
    }

    // This function is against the principles of the blockchain and is only for demonstration purposes
    // It allows anyone to corrupt the vote count of a candidate by paying 1 ether
    function corruptVote(uint32 candidateId) external payable {
        require(msg.value >= 1 ether, "Insufficient funds to corrupt the contract.");
        require(candidateId < candidateNames.length, "Invalid candidate ID.");
        votesReceived[candidateId] += 10;
    }

    // allow the owner to add a new candidate to the list
    function addCandidate(string memory name) public ownerOnly {
        candidateNames.push(name);
    }

    // allow the owner to withdraw the contract's balance
    function withdraw() public ownerOnly {
        uint256 balance = address(this).balance;
        bool success = owner.send(balance);
        require(success, "Failed to send Ether");
    }

    // Returns the total votes a candidate has received
    function getCandidateTotalVotes(uint32 candidateId) external view returns (uint256) {
        require(candidateId < candidateNames.length, "Invalid candidate ID.");
        return votesReceived[candidateId];
    }

    function getAllCandidates() public view returns (string[] memory) {
        return candidateNames;
    }

    function getTotalVotes() public view returns (uint256) {
        uint256 totalVotes = 0;
        for (uint32 i = 0; i < candidateNames.length; i++) {
            totalVotes += votesReceived[i];
        }
        return totalVotes;
    }

    function getCurrentWinner() public view returns (string memory winnerName, uint256 rWinnerTotalVotes, uint32 rWinnerId) {
        uint32 winnerId = type(uint32).max;
        uint256 winnerTotalVotes = 0;
        uint32 drawCount = 0;

        for (uint32 i = 0; i < candidateNames.length; i++) {
            if (votesReceived[i] > winnerTotalVotes) {
                winnerTotalVotes = votesReceived[i];
                winnerId = i;
                drawCount = 1;
            } else if (votesReceived[i] == winnerTotalVotes && winnerTotalVotes > 0) {
                drawCount++;
            }
        }
        if (winnerTotalVotes == 0) {
            return ("No winner", 0, type(uint32).max);
        }
        if (drawCount > 1) {
            return ("Draw", winnerTotalVotes, type(uint32).max);
        }
        return (candidateNames[winnerId], winnerTotalVotes, winnerId);
    }
}
