// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "@solady/src/utils/LibZip.sol";

interface RightToTransact {
    function withdrawToken(address tokenAddress) external;
}

contract WithdrawToken is Script {
    function run() external {
        // update as needed
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        RightToTransact rightToTransact = RightToTransact(
            // (un)comment as needed
            vm.envAddress("DEPLOYED_ADDRESS_SEPOLIA")
        );
        // vm.envAddress("DEPLOYED_ADDRESS_MAINNET")

        // update as needed
        rightToTransact.withdrawToken(address(0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14));

        vm.stopBroadcast();
    }
}
