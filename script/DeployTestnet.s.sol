// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/RightToTransact.sol";

contract DeployTestnet is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        new RightToTransact("Right to Transact", "RTT", 8e15, payable(vm.envAddress("FREN_ADDRESS_TESTNET")));

        vm.stopBroadcast();
    }
}
