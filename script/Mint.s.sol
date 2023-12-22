// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "@solady/src/utils/LibZip.sol";

interface RightToTransact {
    function mint(
        address _to,
        uint256 _amount
    ) external payable returns (uint256[] memory);
}

contract Mint is Script {
    function run() external {
        // update as needed
        uint256 privateKey = vm.envUint("MALLORY_PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        RightToTransact rightToTransact = RightToTransact(
            // (un)comment as needed
            vm.envAddress("DEPLOYED_ADDRESS_SEPOLIA")
            // vm.envAddress("DEPLOYED_ADDRESS_MAINNET")
        );

        // update as needed
        rightToTransact.mint{value: 25e15}(address(0x6CE36aF4159b0437e85EDEA0b29a1861EfeCc76A), 1);

        vm.stopBroadcast();
    }
}
