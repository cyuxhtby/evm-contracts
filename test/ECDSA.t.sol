// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/oz/ECDSA.sol";

contract ECDSATest is Test {
    ECDSA public ecdsa;
    uint256 constant PRIV_KEY = 0x12345;
    address signer;
    bytes32 messageHash;
    uint8 v;
    bytes32 r;
    bytes32 s;
    bytes signature;

    function setUp() public {
        ecdsa = new ECDSA();
        signer = vm.addr(PRIV_KEY);
        messageHash = keccak256(abi.encodePacked("test_message"));
        (v, r, s) = vm.sign(PRIV_KEY, messageHash); 
        signature = abi.encodePacked(r, s, v);
    }

    function test_validSignature() public {
        assertTrue(ecdsa.verifySignature(messageHash, signature));
    }

    function test_invalidSignature() public {
        bytes memory invalidSig = abi.encodePacked(s, r, v); // switched r and s
        vm.expectRevert(abi.encodeWithSelector(ECDSALib.ECDSAInvalidSignature.selector));
        ecdsa.verifySignature(messageHash, invalidSig);
    }

    function test_invalidSignatureLength() public {
        bytes memory shortSignature = new bytes(64); // byte array of length 64
        vm.expectRevert(abi.encodeWithSelector(ECDSALib.ECDSAInvalidSignatureLength.selector, 64));
        ECDSALib.recover(messageHash, shortSignature);
    }

    function test_invalidSignatureS() public {
        bytes32 invalidS = bytes32(uint256(0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A1));
        bytes memory invalidSSignature = abi.encodePacked(r, invalidS, v);
        vm.expectRevert(abi.encodeWithSelector(ECDSALib.ECDSAInvalidSignatureS.selector, invalidS));
        ECDSALib.recover(messageHash, invalidSSignature);
    }

} 