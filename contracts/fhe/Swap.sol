// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {FHE, euint16, ebool} from "@fhenixprotocol/contracts/FHE.sol";
import {FHERC20} from "./FHERC20.sol";

contract Swap {

    FHERC20 public token0;
    FHERC20 public token1;
    euint16 private reserve0;
    euint16 private reserve1;

    /// @notice not checking balances before and after swap
    function swap(euint16 amountIn, address to, bool isToken0In) external returns (euint16 amountOut) {
        (euint16 _reserve0, euint16 _reserve1) = getReserves();

        // calculate the output amount based on the input amount and reserves
        if (isToken0In) {
            amountOut = getAmountOut(amountIn, _reserve0, _reserve1);
        } else {
            amountOut = getAmountOut(amountIn, _reserve1, _reserve0);
        }

        // transfer the input tokens from the sender to the contract
        if (isToken0In) {
            token0.transferFromEncrypted(msg.sender, address(this), amountIn);
        } else {
            token1.transferFromEncrypted(msg.sender, address(this), amountIn);
        }

        // transfer the output tokens from the contract to the recipient
        if (isToken0In) {
            token1.transferEncrypted(to, amountOut);
        } else {
            token0.transferEncrypted(to, amountOut);
        }

        // update the reserves
        euint16 newReserve0 = FHE.select(
            isToken0In,
            _reserve0 + amountIn,
            _reserve0 - amountOut
        );
        euint16 newReserve1 = FHE.select(
            isToken0In,
            _reserve1 - amountOut,
            _reserve1 + amountIn
        );
        reserve0 = newReserve0;
        reserve1 = newReserve1;

        // enforce the invariant (x * y = k)
        euint16 productBefore = _reserve0 * _reserve1;
        euint16 productAfter = newReserve0 * newReserve1;
        ebool isValid = productAfter >= productBefore;
        amountOut = FHE.select(isValid, amountOut, FHE.asEuint16(0));
    }

    function getReserves() public view returns (euint16, euint16) {
        return (reserve0, reserve1);
    }

}