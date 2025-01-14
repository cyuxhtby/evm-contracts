// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ECDSA {
    using ECDSALib for bytes32;

    function verifySignature(bytes32 hash, bytes memory signature) public pure returns (bool isValid) {
        address signer = ECDSALib.recover(hash, signature);
        return signer != address(0); 
    }
}

/// @dev ECDSA signature verification library
/// @notice Only offers reverts for invalidations
library ECDSALib {
    error ECDSAInvalidSignature();
    error ECDSAInvalidSignatureLength(uint256 length);
    error ECDSAInvalidSignatureS(bytes32 s);

    // Elliptic curve:
    //  follows SEC secp256k1 standard
    //  defines the order size of the ec group as well as n
    //  plotted as y² = x³ + 7 over a prime field

    // Auxiliary values not in final signature:
    //  k: random value
    //  G: base point that generates all other curve points
    //  R: random point on curve (k * G) 
    //  n: curve order (total of valid points)

    // Values in final signature:
    //  r: x-coordinate of point R
    //  s: proof value
    //     k^-1 * (txHash + r * privKey) mod n
    //  v: recovery value:
    //     recoveryId (binary for even or odd y-coordinate of R) + 27 + chainId * 2 + 35

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                // signature encoding ordering follows DER standard
                // mload(location) 
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                // mload always reads 32 bytes, we only need the first
                // byte(offset, 32 byte word)
                v := byte(0, mload(add(signature, 0x60)))
            }
            return _recover(hash, v, r, s);
        }
        revert ECDSAInvalidSignatureLength(signature.length);
    }

    function _recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
       // there are two possible s values for each valid signature
       // for every valid s there exists a valid signature with secp256k1n - s, the inverse
       // EIP-2 enforces a single valid signature by requiring the s value to be in the lower half of the curve order
       // we enforce this by making sure the s value is less than half of the curve order (n/2)
       // the n value for secp256k1 is defined in SEC2 subsection 2.4.1 (https://www.secg.org/sec2-v2.pdf)
       // the resulting value of n/2 in hex is 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0

       if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            revert ECDSAInvalidSignatureS(s);
       }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            revert ECDSAInvalidSignature();
        }
        return signer;
    }

}