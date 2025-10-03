// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {MameVoter} from "../src/MameVoter.sol";

contract MameVoterScript is Script {
    MameVoter public mameVoter;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        string[] memory candidateList = new string[](3);
        candidateList[0] = "alice";
        candidateList[1] = "bob";
        candidateList[2] = "carol";

        mameVoter = new MameVoter(candidateList);

        vm.stopBroadcast();
    }
}
