// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "@solady/src/utils/LibZip.sol";

interface RightToTransact {
    function withdrawEth() external;
}

contract WithdrawEth is Script {
    function run() external {
        // update as needed
        uint256 privateKey = vm.envUint("FREN_PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        RightToTransact rightToTransact = RightToTransact(
            // (un)comment as needed
            vm.envAddress("DEPLOYED_ADDRESS_SEPOLIA")
            // vm.envAddress("DEPLOYED_ADDRESS_MAINNET")
        );

        // update as needed
        rightToTransact.withdrawEth();

        vm.stopBroadcast();
    }
}
