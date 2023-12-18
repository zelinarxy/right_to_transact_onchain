pragma solidity ^0.8.20;

import "@solady/src/tokens/ERC20.sol";

contract DummyToken is ERC20 {
    constructor(uint256 initialSupply) {
        _mint(msg.sender, initialSupply);
    }

    function name() public view virtual override returns (string memory) {
        return "DummyToken";
    }

    function symbol() public view virtual override returns (string memory) {
        return "DMT";
    }
}
