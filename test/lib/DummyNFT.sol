pragma solidity ^0.8.20;

import "@solady/src/tokens/ERC721.sol";
import "@solady/src/utils/LibString.sol";

contract DummyNFT is ERC721 {
    uint256 private _tokenIds;

    constructor() {}

    function name() public view virtual override returns (string memory) {
        return "DummyNFT";
    }

    function symbol() public view virtual override returns (string memory) {
        return "DNFT";
    }

    function tokenURI(uint256 id) public view virtual override returns (string memory) {
        return LibString.toString(id);
    }

    function mint(address to) public returns (uint256) {
        _tokenIds++;

        uint256 newTokenId = _tokenIds;
        _mint(to, newTokenId);

        return newTokenId;
    }
}
