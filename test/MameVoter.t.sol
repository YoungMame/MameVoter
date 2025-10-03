// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {MameVoter} from "../src/MameVoter.sol";

contract MameVoterTest is Test {
    MameVoter public mameVoter;

    address voter1 = address(0xA11CE);
    address voter2 = address(0xB0B);
    address voter3 = address(0xCA10);
    address voter4 = address(0xD0D);
    address owner = address(0x123);
        
    function setUp() public {
        string[] memory candidateList = new string[](3);
        candidateList[0] = "alice";
        candidateList[1] = "bob";
        candidateList[2] = "carol";

        vm.prank(owner);
        mameVoter = new MameVoter(candidateList);
    }

    function test_vote() public {
        mameVoter.vote(1);
        assertEq(mameVoter.getCandidateTotalVotes(1), 1);
    }

    function test_voteAlreadyUsed() public {
        mameVoter.vote(1);
        vm.expectRevert("You have already voted.");
        mameVoter.vote(1);
        assertEq(mameVoter.getCandidateTotalVotes(1), 1);
    }

    function test_voteInvalidCandidate() public {
        vm.expectRevert("Invalid candidate ID.");
        mameVoter.vote(5);
    }

    function test_corruptVote() public {
        vm.prank(voter1);
        mameVoter.vote(1);
        vm.prank(voter2);
        mameVoter.vote(0);
        vm.prank(voter3);
        mameVoter.vote(2);
        vm.prank(voter4);
        mameVoter.vote(0);

        (string memory winnerName, uint256 winnerTotalVotes, uint32 winnerId) = mameVoter.getCurrentWinner();
        assertEq(winnerName, "alice");
        assertEq(winnerTotalVotes, 2);
        assertEq(winnerId, 0);

        vm.prank(voter1);
        vm.deal(voter1, 2 ether);
        mameVoter.corruptVote{value: 2 ether}(1);
        mameVoter.vote(1);

        (winnerName, winnerTotalVotes, winnerId) = mameVoter.getCurrentWinner();
        assertEq(winnerId, 1);
    }

    function test_drawInVote() public {
        vm.prank(voter1);
        mameVoter.vote(1);

        vm.prank(voter2);
        mameVoter.vote(2);

        (string memory winnerName, uint256 winnerTotalVotes, uint32 winnerId) = mameVoter.getCurrentWinner();
        assertEq(winnerName, "Draw");
        assertEq(winnerTotalVotes, 1);
        assertEq(winnerId, type(uint32).max);
    }

    function test_getCurrentWinnerWithNoVote() public view {
        (string memory winnerName, uint256 winnerTotalVotes, uint32 winnerId) = mameVoter.getCurrentWinner();
        assertEq(winnerName, "No winner");
        assertEq(winnerId, type(uint32).max);
        assertEq(winnerTotalVotes, 0);
    }

    function test_illegalwithdraw() public {
        vm.prank(voter1);
        vm.deal(voter1, 2 ether);
        mameVoter.corruptVote{value: 2 ether}(1);
        vm.prank(voter2);
        vm.deal(voter2, 2 ether);
        mameVoter.corruptVote{value: 2 ether}(1);

        vm.prank(owner);
        mameVoter.withdraw();
        assertEq(address(mameVoter).balance, 0);
        assertEq(owner.balance, 4 ether);
    }

    function test_getTotalVotes() public {
        vm.prank(voter1);
        mameVoter.vote(1);
        vm.prank(voter2);
        mameVoter.vote(0);
        vm.prank(voter3);
        mameVoter.vote(2);
        vm.prank(voter4);
        mameVoter.vote(0);

        assertEq(mameVoter.getTotalVotes(), 4);
    }

    function test_getAllCandidates() public view {
        string[] memory candidates = mameVoter.getAllCandidates();
        assertEq(candidates.length, 3);
        assertEq(candidates[0], "alice");
        assertEq(candidates[1], "bob");
        assertEq(candidates[2], "carol");
    }

    function test_getCandidateTotalVotes() public {
        vm.prank(voter1);
        mameVoter.vote(1);
        vm.prank(voter2);
        mameVoter.vote(0);
        vm.prank(voter3);
        mameVoter.vote(2);
        vm.prank(voter4);
        mameVoter.vote(0);

        assertEq(mameVoter.getCandidateTotalVotes(0), 2);
        assertEq(mameVoter.getCandidateTotalVotes(1), 1);
        assertEq(mameVoter.getCandidateTotalVotes(2), 1);
    }

    function test_addCandidate() public {
        vm.prank(owner);
        mameVoter.addCandidate("dave");
        string[] memory candidates = mameVoter.getAllCandidates();
        assertEq(candidates.length, 4);
        assertEq(candidates[3], "dave");
    }

    function test_addCandidateNotOwner() public {
        vm.prank(voter1);
        vm.expectRevert("You are not the owner.");
        mameVoter.addCandidate("dave");
    }

    function test_corruptVoteInsufficientFunds() public {
        vm.prank(voter1);
        vm.deal(voter1, 0.5 ether);
        vm.expectRevert("Insufficient funds to corrupt the contract.");
        mameVoter.corruptVote{value: 0.5 ether}(1);
    }
}
