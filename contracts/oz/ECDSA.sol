// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ECDSA {
    using ECDSALib for bytes32;

    function verifySignature(bytes32 hash, bytes memory signature) public pure returns (address signer) {
        (signer , ,) = ECDSALib.recover(hash, signature);
        return signer;
    }
}

library ECDSALib {

    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS
    }

    error ECDSAInvalidSignature();
    error ECDSAInvalidSignatureLength(uint256 length);
    error InvalidSignatureS(bytes32 s);

    // Elliptic curve:
    //  uses secp256k1 standard
    //  plotted as y² = x³ + 7 over a prime field

    // Auxiliary values not in final signature:
    //  k: random value
    //  G: base point that generates all other curve points
    //  R: random point on curve (k * G) 
    //  n: curve order (total of valid points)

    // Values in final signature:
    // r: x-coordinate of point R
    // s: proof value
    //    k^-1 * (txHash + r * privKey) mod n
    // v: recovery value:
    //    recoveryId (binary for even or odd y-coordinate of R) + 27 + chainId * 2 + 35


    function recover(bytes32 hash, bytes memory signature) internal pure returns (address recovered, RecoverError error, bytes32 errorArg) {
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
            return tryRecover(hash, v, r, s);
        }
        return (address(0), RecoverError.InvalidSignatureLength, bytes32(signature.length));
    }

    function tryRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address recovered, RecoverError error, bytes32 errorArg) {
        // TODO: remove malleable signatures

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            revert ECDSAInvalidSignature();
        }
        return (signer, RecoverError.NoError, bytes32(0));
    }

}