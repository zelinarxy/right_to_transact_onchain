// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "@solady/src/utils/LibZip.sol";

interface RightToTransact {
    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) external payable;
}

contract Transfer is Script {
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
        rightToTransact.safeTransferFrom(address(0xDb01268ABedF370b9c070Fb245c43A4b91B1c6D5), address(0x6CE36aF4159b0437e85EDEA0b29a1861EfeCc76A), 1);

        vm.stopBroadcast();
    }
}
