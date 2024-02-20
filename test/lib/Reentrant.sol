pragma solidity ^0.8.20;

import "../../src/RightToTransact.sol";

contract Reentrant {
    RightToTransact public rightToTransact;

    constructor() {
        // address you get from logging out the tests
        // seems stable but can't prove it
        rightToTransact = RightToTransact(0xE536720791A7DaDBeBdBCD8c8546fb0791a11901);
    }

    fallback() external payable {
        if (address(rightToTransact).balance > 0 ) {
            rightToTransact.withdrawEth();
        }
    }
}
