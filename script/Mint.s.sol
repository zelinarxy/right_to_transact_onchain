// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "@solady/src/utils/LibZip.sol";

interface RightToTransact {
    function mint(address _to, uint256 _amount) external payable returns (uint256[] memory);
}

contract Mint is Script {
    function run() external {
        uint256 privateKey = vm.envUint("MALLORY_PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        RightToTransact rightToTransact = RightToTransact(
            vm.envAddress("DEPLOYED_ADDRESS_SEPOLIA")
        );

        // update as needed
        rightToTransact.mint{value: 1e16}(address(0x6CE36aF4159b0437e85EDEA0b29a1861EfeCc76A), 1);

        vm.stopBroadcast();
    }
}
