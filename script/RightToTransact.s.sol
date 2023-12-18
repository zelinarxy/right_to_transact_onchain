// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/RightToTransact.sol";

contract RightToTransactScript is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        RightToTransact rightToTransact = new RightToTransact(
            "Right to Transact",
            "RTT",
            10000,
            25e15,
            // (un)comment as needed
            payable(vm.envAddress("FREN_ADDRESS_TESTNET"))
            // payable(vm.envAddress("FREN_ADDRESS_MAINNET"))
        );

        vm.stopBroadcast();
    }
}
