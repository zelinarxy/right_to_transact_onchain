// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";

interface RightToTransact {
    function read(uint256 index) external returns (string memory text);
}

contract Read is Script {
    function run() external {
        vm.startBroadcast();

        RightToTransact rightToTransact = RightToTransact(vm.envAddress("DEPLOYED_ADDRESS_SEPOLIA"));

        for (uint256 i; i < 1;) {
            string memory text = rightToTransact.read(i);
            console.log(text);

            unchecked {
                ++i;
            }
        }

        vm.stopBroadcast();
    }
}
