// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import "forge-std/console.sol";
import "forge-std/Test.sol";
import "solmate/test/utils/DSTestPlus.sol";
import "@solady/src/utils/LibString.sol";
import "./lib/DummyNFT.sol";
import "./lib/DummyToken.sol";
import "./lib/Reentrant.sol";
import "../src/RightToTransact.sol";

interface CheatCodes {
    function expectRevert(bytes calldata) external;

    function prank(address) external;
}

contract RightToTransactTest is Test {
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);

    RightToTransact public rightToTransact;
    DummyNFT public dummyNFT;
    DummyToken public dummyToken;
    Reentrant public reentrant;

    string NAME = "RightToTransact";
    string SYMBOL = "RTT";
    uint256 PRICE = 1e16;

    address payable OWNER_ADDRESS = payable(address(2));
    address payable MINTER_ONE_ADDRESS = payable(address(3));
    address payable MINTER_TWO_ADDRESS = payable(address(4));
    address payable NASTY_ADDRESS = payable(address(5));
    address payable RECEIVER_ADDRESS = payable(address(6));
    address payable TOKEN_NFT_SENDER_ADDRESS = payable(address(7));
    address payable FREN_ADDRESS;

    bytes html = LibZip.flzCompress(
        bytes(
            unicode"<!DOCTYPE html><html><head><meta charset=&quot;utf-8&quot;><title>The right to transact</title></head><body><h1>The right to transact</h1><p>© Zelinar XY 2023</p><p style=&quot;page-break-before:always&quot;><em>And he causeth all, both small and great, rich and poor, free and bond, to receive a mark in their right hand, or in their foreheads: And that no man might buy or sell, save he that had the mark, or the name of the beast, or the number of his name.</em><br><br>Revelation 13:16-17</p><h2>Tl;dr</h2><p>Until a few decades ago, we enjoyed a near-complete freedom to transact when, where and with whom we pleased. Centralized control over the ability to buy and sell was impossible, as was centralized surveillance of individual transactions.</p><p>This freedom was a good thing, and now, as a result of rapidly evolving technology, it&apos;s disappearing.</p><p>The Canadian government has invoked emergency powers to freeze protesters&apos; bank accounts without due process. PayPal has declared its intention to monitor users&apos; speech and fine them for expressing views the company considers objectionable.</p><p>Across the industrialized world, central banks are planning to replace national currencies with central bank digital currencies (CBDCs). These will enable states to track and, if they wish, block or reverse any monetary transaction, no matter how trivial.</p><p>We can&apos;t accept this outcome. The freedom to transact needs to be seen as a fundamental right, on par with the freedom of speech. To do otherwise risks forfeiting protections we once took for granted against potentially horrific abuse: the ability to earn money and spend it on daily necessities without seeking the approval of powerful, unaccountable institutions.</p></body></html>"
        )
    );

    function setUp() public {
        // assure fren can't rug with a malicious fallback()
        // not that they would :)
        reentrant = new Reentrant();
        address payable REENTRANT_ADDRESS = payable(address(reentrant));
        FREN_ADDRESS = REENTRANT_ADDRESS;

        cheats.prank(OWNER_ADDRESS);

        rightToTransact = new RightToTransact(NAME, SYMBOL, PRICE, REENTRANT_ADDRESS);

        dummyToken = new DummyToken(100e18);
        dummyToken.transfer(TOKEN_NFT_SENDER_ADDRESS, 100e18);

        dummyNFT = new DummyNFT();
        dummyNFT.mint(TOKEN_NFT_SENDER_ADDRESS);

        MINTER_ONE_ADDRESS.transfer(10e18);
        MINTER_TWO_ADDRESS.transfer(10e18);
    }

    function testWriteBook() public {
        bytes[] memory data = new bytes[](1);
        data[0] = html;

        cheats.prank(OWNER_ADDRESS);
        rightToTransact.write(data);

        cheats.prank(MINTER_ONE_ADDRESS);
        rightToTransact.mint{value: 1e16}(MINTER_ONE_ADDRESS, 1);

        cheats.prank(MINTER_ONE_ADDRESS);
        console.log(rightToTransact.read(0));
    }

    function testWrite() public {
        bytes[] memory data = new bytes[](1);

        data[0] = LibZip.flzCompress(bytes(unicode"🥝"));

        cheats.prank(OWNER_ADDRESS);
        rightToTransact.write(data);

        cheats.prank(MINTER_ONE_ADDRESS);
        rightToTransact.mint{value: 1e16}(MINTER_ONE_ADDRESS, 1);

        cheats.prank(MINTER_ONE_ADDRESS);
        assertEq(rightToTransact.read(0), unicode"🥝");
    }

    function testFailWriteUnauthorized() public {
        bytes[] memory data = new bytes[](1);

        data[0] = LibZip.flzCompress(bytes(unicode"🥝"));

        cheats.prank(NASTY_ADDRESS);
        rightToTransact.write(data);
    }

    function testOverwrite() public {
        bytes[] memory data = new bytes[](1);

        data[0] = LibZip.flzCompress(bytes(unicode"🥝"));

        cheats.prank(OWNER_ADDRESS);
        rightToTransact.write(data);

        cheats.prank(MINTER_ONE_ADDRESS);
        rightToTransact.mint{value: 1e16}(MINTER_ONE_ADDRESS, 1);

        cheats.prank(MINTER_ONE_ADDRESS);
        assertEq(rightToTransact.read(0), unicode"🥝");

        bytes memory newData = LibZip.flzCompress(bytes(unicode"🎩"));

        cheats.prank(OWNER_ADDRESS);
        rightToTransact.overwrite(0, newData);

        cheats.prank(MINTER_ONE_ADDRESS);
        assertEq(rightToTransact.read(0), unicode"🎩");
    }

    function testFailOverwriteUnauthorized() public {
        bytes memory data = LibZip.flzCompress(bytes(unicode"🎩"));

        cheats.prank(NASTY_ADDRESS);
        rightToTransact.overwrite(0, data);
    }

    function testMintTotalSupply() public {
        cheats.prank(MINTER_ONE_ADDRESS);
        rightToTransact.mint{value: 1e16 * 3}(MINTER_ONE_ADDRESS, 3);
        assertEq(rightToTransact.totalSupply(), 3);

        cheats.prank(MINTER_TWO_ADDRESS);
        rightToTransact.mint{value: 1e16 * 5}(MINTER_TWO_ADDRESS, 5);
        assertEq(rightToTransact.totalSupply(), 8);
    }

    function testMintUserBalance() public {
        cheats.prank(MINTER_ONE_ADDRESS);
        rightToTransact.mint{value: 1e16}(MINTER_ONE_ADDRESS, 1);

        cheats.prank(MINTER_TWO_ADDRESS);
        rightToTransact.mint{value: 1e16 * 4}(MINTER_TWO_ADDRESS, 4);

        assertEq(rightToTransact.balanceOf(MINTER_ONE_ADDRESS), 1);
        assertEq(rightToTransact.balanceOf(MINTER_TWO_ADDRESS), 4);
    }

    function testMintTokenOwner() public {
        cheats.prank(MINTER_ONE_ADDRESS);
        rightToTransact.mint{value: 1e16 * 2}(MINTER_ONE_ADDRESS, 2);

        cheats.prank(MINTER_TWO_ADDRESS);
        rightToTransact.mint{value: 1e16}(MINTER_TWO_ADDRESS, 1);

        assertEq(rightToTransact.ownerOf(1), MINTER_ONE_ADDRESS);
        assertEq(rightToTransact.ownerOf(2), MINTER_ONE_ADDRESS);
        assertEq(rightToTransact.ownerOf(3), MINTER_TWO_ADDRESS);
    }

    function testMintContractBalance() public {
        cheats.prank(MINTER_ONE_ADDRESS);
        rightToTransact.mint{value: 1e16 * 2}(MINTER_ONE_ADDRESS, 2);

        cheats.prank(MINTER_TWO_ADDRESS);
        rightToTransact.mint{value: 1e16}(MINTER_TWO_ADDRESS, 1);

        assertEq(address(rightToTransact).balance, 1e16 * 3);
    }

    function testMintExpectedRevertInsufficientPayment() public {
        cheats.prank(MINTER_ONE_ADDRESS);

        cheats.expectRevert(abi.encodeWithSelector(InsufficientPayment.selector));

        rightToTransact.mint{value: 1e16}(MINTER_ONE_ADDRESS, 2);
    }

    function testAdminMintTotalSupply() public {
        cheats.prank(OWNER_ADDRESS);
        rightToTransact.adminMint(MINTER_ONE_ADDRESS, 6);

        assertEq(rightToTransact.totalSupply(), 6);
    }

    function testAdminMintUserBalance() public {
        cheats.prank(OWNER_ADDRESS);
        rightToTransact.adminMint(MINTER_TWO_ADDRESS, 7);

        assertEq(rightToTransact.balanceOf(MINTER_TWO_ADDRESS), 7);
    }

    function testAdminMintTokenOwner() public {
        cheats.prank(OWNER_ADDRESS);
        rightToTransact.adminMint(MINTER_ONE_ADDRESS, 7);

        assertEq(rightToTransact.ownerOf(1), MINTER_ONE_ADDRESS);
        assertEq(rightToTransact.ownerOf(7), MINTER_ONE_ADDRESS);

        cheats.prank(OWNER_ADDRESS);
        rightToTransact.adminMint(MINTER_TWO_ADDRESS, 3);

        assertEq(rightToTransact.ownerOf(8), MINTER_TWO_ADDRESS);
        assertEq(rightToTransact.ownerOf(10), MINTER_TWO_ADDRESS);
    }

    function testFailAdminMintUnauthorized() public {
        cheats.prank(NASTY_ADDRESS);
        rightToTransact.adminMint(NASTY_ADDRESS, 1);
    }

    function testTransfer() public {
        cheats.prank(MINTER_ONE_ADDRESS);
        rightToTransact.mint{value: 1e16}(MINTER_ONE_ADDRESS, 1);

        assertEq(rightToTransact.ownerOf(1), MINTER_ONE_ADDRESS);

        cheats.prank(MINTER_ONE_ADDRESS);
        rightToTransact.safeTransferFrom(MINTER_ONE_ADDRESS, RECEIVER_ADDRESS, 1);

        assertEq(rightToTransact.ownerOf(1), RECEIVER_ADDRESS);
    }

    function testWithdrawEthByOwner() public {
        cheats.prank(MINTER_ONE_ADDRESS);
        rightToTransact.mint{value: 1e16 * 10}(MINTER_ONE_ADDRESS, 10);

        assertEq(OWNER_ADDRESS.balance, 0);
        assertEq(FREN_ADDRESS.balance, 0);

        cheats.prank(OWNER_ADDRESS);
        rightToTransact.withdrawEth();

        assertEq(OWNER_ADDRESS.balance, 1e16 * 8);
        assertEq(FREN_ADDRESS.balance, 1e16 * 2);
    }

    function testWithdrawEthByFren() public {
        cheats.prank(MINTER_ONE_ADDRESS);
        rightToTransact.mint{value: 1e16 * 20}(MINTER_ONE_ADDRESS, 20);

        assertEq(OWNER_ADDRESS.balance, 0);
        assertEq(FREN_ADDRESS.balance, 0);

        cheats.prank(FREN_ADDRESS);
        rightToTransact.withdrawEth();

        assertEq(OWNER_ADDRESS.balance, 1e16 * 16);
        assertEq(FREN_ADDRESS.balance, 1e16 * 4);
    }

    function testFailWithdrawEthUnauthorized() public {
        cheats.prank(MINTER_ONE_ADDRESS);
        rightToTransact.mint{value: 1e16 * 5}(MINTER_ONE_ADDRESS, 5);

        cheats.prank(NASTY_ADDRESS);
        rightToTransact.withdrawEth();
    }

    function testWithdrawTokenByOwner() public {
        cheats.prank(TOKEN_NFT_SENDER_ADDRESS);
        dummyToken.transfer(address(rightToTransact), 100e18);

        assertEq(dummyToken.balanceOf(OWNER_ADDRESS), 0);

        cheats.prank(OWNER_ADDRESS);
        rightToTransact.withdrawToken(address(dummyToken));

        assertEq(dummyToken.balanceOf(OWNER_ADDRESS), 100e18);
    }

    function testFailWithdrawTokenByFren() public {
        cheats.prank(TOKEN_NFT_SENDER_ADDRESS);
        dummyToken.transfer(address(rightToTransact), 50e18);

        cheats.prank(FREN_ADDRESS);
        rightToTransact.withdrawToken(address(dummyToken));
    }

    function testWithdrawNFTByOwner() public {
        cheats.prank(TOKEN_NFT_SENDER_ADDRESS);
        dummyNFT.transferFrom(TOKEN_NFT_SENDER_ADDRESS, address(rightToTransact), 1);

        assertEq(dummyNFT.ownerOf(1), address(rightToTransact));

        cheats.prank(OWNER_ADDRESS);
        rightToTransact.withdrawNFT(address(dummyNFT), 1);

        assertEq(dummyNFT.ownerOf(1), OWNER_ADDRESS);
    }

    function testFailWithdrawNFTByFren() public {
        cheats.prank(TOKEN_NFT_SENDER_ADDRESS);
        dummyNFT.transferFrom(TOKEN_NFT_SENDER_ADDRESS, address(rightToTransact), 1);

        assertEq(dummyNFT.ownerOf(1), address(rightToTransact));

        cheats.prank(FREN_ADDRESS);
        rightToTransact.withdrawNFT(address(dummyNFT), 1);
    }

    function testRenounceContract() public {
        cheats.prank(OWNER_ADDRESS);
        rightToTransact.renounceOwnership();

        assertEq(rightToTransact.owner(), address(0));
    }

    function testRenounceContractWithdrawEth() public {
        cheats.prank(OWNER_ADDRESS);
        rightToTransact.renounceOwnership();

        cheats.prank(MINTER_ONE_ADDRESS);
        rightToTransact.mint{value: 1e16 * 10}(MINTER_ONE_ADDRESS, 10);

        cheats.prank(OWNER_ADDRESS);
        rightToTransact.withdrawEth();

        assertEq(OWNER_ADDRESS.balance, 1e16 * 8);
    }

    function testRenounceContractWithdrawToken() public {
        cheats.prank(TOKEN_NFT_SENDER_ADDRESS);
        dummyToken.transfer(address(rightToTransact), 69e18);

        assertEq(dummyToken.balanceOf(OWNER_ADDRESS), 0);

        cheats.prank(OWNER_ADDRESS);
        rightToTransact.renounceOwnership();

        cheats.prank(OWNER_ADDRESS);
        rightToTransact.withdrawToken(address(dummyToken));

        assertEq(dummyToken.balanceOf(OWNER_ADDRESS), 69e18);
    }

    function testRenounceContractWithdrawNFT() public {
        cheats.prank(OWNER_ADDRESS);
        rightToTransact.renounceOwnership();

        cheats.prank(TOKEN_NFT_SENDER_ADDRESS);
        dummyNFT.transferFrom(TOKEN_NFT_SENDER_ADDRESS, address(rightToTransact), 1);

        assertEq(dummyNFT.ownerOf(1), address(rightToTransact));

        cheats.prank(OWNER_ADDRESS);
        rightToTransact.withdrawNFT(address(dummyNFT), 1);

        assertEq(dummyNFT.ownerOf(1), OWNER_ADDRESS);
    }

    function testFailRenounceContractWrite() public {
        cheats.prank(MINTER_ONE_ADDRESS);
        rightToTransact.renounceOwnership();

        bytes[] memory data = new bytes[](1);

        data[0] = LibZip.flzCompress(bytes(unicode"🥝"));

        cheats.prank(OWNER_ADDRESS);
        rightToTransact.write(data);
    }

    function testFailRenounceContractOverwrite() public {
        bytes[] memory data = new bytes[](1);

        data[0] = LibZip.flzCompress(bytes(unicode"🥝"));

        cheats.prank(OWNER_ADDRESS);
        rightToTransact.write(data);

        cheats.prank(OWNER_ADDRESS);
        rightToTransact.renounceOwnership();

        cheats.prank(MINTER_ONE_ADDRESS);
        rightToTransact.mint{value: 1e16}(MINTER_ONE_ADDRESS, 1);

        bytes memory newData = LibZip.flzCompress(bytes(unicode"🎩"));

        cheats.prank(OWNER_ADDRESS);
        rightToTransact.overwrite(0, newData);
    }

    function testFailRenounceContractAdminMint() public {
        cheats.prank(OWNER_ADDRESS);
        rightToTransact.renounceOwnership();

        cheats.prank(OWNER_ADDRESS);
        rightToTransact.adminMint(MINTER_ONE_ADDRESS, 6);
    }

    function testSetBaseURI() public {
        cheats.prank(OWNER_ADDRESS);
        rightToTransact.setBaseURI("ipfs://super/");
        assertEq(rightToTransact.baseURI(), "ipfs://super/");
    }

    function testTokenURI() public {
        cheats.prank(OWNER_ADDRESS);
        rightToTransact.setBaseURI("ipfs://lmfao/");

        cheats.prank(MINTER_ONE_ADDRESS);
        rightToTransact.mint{value: 12 * 1e16}(MINTER_ONE_ADDRESS, 12);

        assertEq(rightToTransact.tokenURI(1), "ipfs://lmfao/1");
        assertEq(rightToTransact.tokenURI(12), "ipfs://lmfao/12");
    }

    function testFailTokenURIZero() public {
        cheats.prank(OWNER_ADDRESS);
        rightToTransact.setBaseURI("ipfs://lmfao/");

        cheats.prank(MINTER_ONE_ADDRESS);
        rightToTransact.mint{value: 1e16}(MINTER_ONE_ADDRESS, 1);

        rightToTransact.tokenURI(0);
    }

    function testFailTokenURINonexistent() public {
        cheats.prank(OWNER_ADDRESS);
        rightToTransact.setBaseURI("ipfs://lmfao/");

        cheats.prank(MINTER_ONE_ADDRESS);
        rightToTransact.mint{value: 1e16}(MINTER_ONE_ADDRESS, 1);

        rightToTransact.tokenURI(2);
    }

    function testFailTokenURI() public {
        cheats.prank(NASTY_ADDRESS);
        rightToTransact.setBaseURI("ipfs://badwrong/");
    }

    // removed token gating. anyone can read
    // function testReadExpectedRevertNoTokenMinted() public {
    //     cheats.expectRevert(abi.encodeWithSelector(NoTokenMinted.selector));

    //     cheats.prank(NASTY_ADDRESS);
    //     rightToTransact.read(0);
    // }
}
