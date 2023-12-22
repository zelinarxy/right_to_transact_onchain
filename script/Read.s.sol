// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";

interface RightToTransact {
    function tokenURI(uint256 _tokenId) external returns (string memory text);
}

contract Read is Script {
    function run() external {
        vm.startBroadcast();

        RightToTransact rightToTransact = RightToTransact(
            vm.envAddress("DEPLOYED_ADDRESS_MAINNET")
        );

        string memory text = rightToTransact.tokenURI(1);

        console.log(text);

        vm.stopBroadcast();
    }
}
