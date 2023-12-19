// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import "@solady/src/utils/LibString.sol";
import "@solady/src/utils/SSTORE2.sol";
import "@solady/src/utils/LibZip.sol";
import "@solady/src/tokens/ERC721.sol";
import "@solady/src/auth/OwnableRoles.sol";

interface IERC20 {
    function balanceOf(address owner) external view returns (uint256 result);

    function transfer(address to, uint256 amount) external returns (bool);
}

interface IERC721 {
    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) external payable;
}

error MaxSupplyExceeded();
error InsufficientPayment();

/**
 * Based on Zodomo's Alexandria contract (see
 * https://github.com/Zodomo/alexandria).
 *
 */
contract RightToTransact is ERC721, OwnableRoles {
    string private _name;
    string private _symbol;

    address payable public ownerMaybeRenounced;
    address payable public fren;
    uint256 public maxSupply;
    uint256 public price;

    address[] public textStorage;
    uint256 public totalSupply;

    constructor(
        string memory __name,
        string memory __symbol,
        uint256 _maxSupply,
        uint256 _price,
        address payable _fren
    ) payable {
        _name = __name;
        _symbol = __symbol;

        fren = _fren;
        maxSupply = _maxSupply;
        price = _price;

        ownerMaybeRenounced = payable(msg.sender);
        _initializeOwner(msg.sender);

        // role 1 (deployer) enables `withdrawToken` and `withdrawNFT`
        // role 2 (deployer and fren) enables `withdrawEth`
        // deployer receives roles in addition to `owner` so that
        // they can renounce ownership and still withdraw funds, but lose
        // the ability to call `onlyOwner` functions (eg, `overwrite`)
        _grantRoles(msg.sender, 1);
        _grantRoles(msg.sender, 2);
        _grantRoles(_fren, 2);
    }

    function name() public view override returns (string memory) {
        return (_name);
    }

    function symbol() public view override returns (string memory) {
        return (_symbol);
    }

    function tokenURI(
        uint256 _tokenId
    ) public view override returns (string memory text) {
        text = LibString.concat("<!-- ", LibString.toString(_tokenId));
        text = LibString.concat(text, " -->");

        for (uint256 i; i < textStorage.length; ) {
            text = LibString.concat(
                text,
                string(LibZip.flzDecompress(SSTORE2.read(textStorage[i])))
            );

            unchecked {
                ++i;
            }
        }
    }

    function mint(
        address _to,
        uint256 _amount
    ) public payable returns (uint256[] memory) {
        if (_amount * price > msg.value) {
            revert InsufficientPayment();
        }

        if (totalSupply + _amount > maxSupply) {
            revert MaxSupplyExceeded();
        }

        uint256[] memory tokens = new uint256[](_amount);

        for (uint256 i; i < _amount; ) {
            _mint(_to, ++totalSupply);
            tokens[i] = totalSupply;

            unchecked {
                ++i;
            }
        }

        return (tokens);
    }

    function adminMint(
        address _to,
        uint256 _amount
    ) public payable onlyOwner returns (uint256[] memory) {
        if (totalSupply + _amount > maxSupply) {
            revert MaxSupplyExceeded();
        }

        uint256[] memory tokens = new uint256[](_amount);

        for (uint256 i; i < _amount; ) {
            _mint(_to, ++totalSupply);
            tokens[i] = totalSupply;

            unchecked {
                ++i;
            }
        }

        return (tokens);
    }

    function write(bytes[] memory _byteData) external onlyOwner {
        for (uint256 i; i < _byteData.length; ) {
            textStorage.push(SSTORE2.write(_byteData[i]));

            unchecked {
                ++i;
            }
        }
    }

    function overwrite(uint256 _index, bytes memory _data) external onlyOwner {
        textStorage[_index] = SSTORE2.write(_data);
    }

    function withdrawEth() public onlyRoles(2) {
        uint256 balance = address(this).balance;

        fren.call{ value: (balance * 20) / 100 }("");
        ownerMaybeRenounced.call{ value: (balance * 80) / 100 }("");
    }

    function withdrawToken(address tokenAddress) public onlyRoles(1) {
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));

        token.transfer(ownerMaybeRenounced, balance);
    }

    function withdrawNFT(address nftAddress, uint256 id) public onlyRoles(1) {
        IERC721 token = IERC721(nftAddress);

        token.safeTransferFrom(address(this), ownerMaybeRenounced, id);
    }
}
