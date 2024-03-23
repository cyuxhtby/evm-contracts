// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


import {FHE, euint16, ebool} from "@fhenixprotocol/contracts/FHE.sol";
import {Permissioned} from "@fhenixprotocol/contracts/access/Permissioned.sol";
import {FHERC20} from "./FHERC20.sol";

contract DualReserveSwap is FHERC20, Permissioned {
    FHERC20 public token0;
    FHERC20 public token1;

    euint16 public mainReserve0;
    euint16 public mainReserve1;
    euint16 public auxiliaryReserve0;
    euint16 public auxiliaryReserve1;

    constructor(FHERC20 _token0, FHERC20 _token1) FHERC20("Donut Liquidity Provider", "LP") {
        token0 = _token0;
        token1 = _token1;
    }
 
    event Swap(address indexed user, euint16 userInput, euint16 totalSwapAmount);


    function processSwap(euint16 userInput, address to, bool isToken0In) internal returns (euint16) {

        // calculate what the end user will receive
        euint16 swapOutput = calculateSwapOutput(userInput, isToken0In);

        // add noise to the swap that will be processed
        euint16 randomAmount = getRandomAmountFromAuxiliaryReserve();
        euint16 totalSwapAmount = userInput + randomAmount;

        // get token balances before the swap
        euint16 balance0Before = token0.balanceOfMe();
        euint16 balance1Before = token1.balanceOfMe();

        // transfer user input to the contract
        if (isToken0In) {
            token0.transferFromEncrypted(msg.sender, address(this), userInput);
        } else {
            token1.transferFromEncrypted(msg.sender, address(this), userInput);
        }

        // get token balances after swap
        euint16 balance0After = token0.balanceOfMe();
        euint16 balance1After = token1.balanceOfMe();

        // calculate the actual amounts transferred
        euint16 amount0In = balance0After - balance0Before;
        euint16 amount1In = balance1After - balance1Before;

        // update reserves based on amounts transferred
        if (isToken0In) {
            mainReserve0 = mainReserve0 + amount0In;
            auxiliaryReserve0 = auxiliaryReserve0 - randomAmount;
            mainReserve1 = mainReserve1 - swapOutput;
            auxiliaryReserve1 = auxiliaryReserve1 + randomAmount;
        } else {
            mainReserve1 = mainReserve1 + amount1In;
            auxiliaryReserve1 = auxiliaryReserve1 - randomAmount;
            mainReserve0 = mainReserve0 - swapOutput;
            auxiliaryReserve0 = auxiliaryReserve0 + randomAmount;
        }

        // transfer the swap output tokens to the recipient
        if (isToken0In) {
            token1.transferEncrypted(to, totalSwapAmount);
        } else {
            token0.transferEncrypted(to, totalSwapAmount);
        }

        // move funds back to main reserve to maintain the reserve ratio
        if (isToken0In) {
            mainReserve0 = mainReserve0 + randomAmount;
            auxiliaryReserve0 = auxiliaryReserve0 - randomAmount;
        } else {
            mainReserve1 = mainReserve1 + randomAmount;
            auxiliaryReserve1 = auxiliaryReserve1 - randomAmount;
        }   

        emit Swap(msg.sender, userInput, totalSwapAmount);
        return swapOutput;
    }

    /// @dev  calculates the swap output based on the user input and current reserves
    function calculateSwapOutput(euint16 userInput, bool isToken0In) internal view returns (euint16) {
        (euint16 reserve0, euint16 reserve1) = getMainReserves();

        // calculate the swap output based on the constant product formula
        euint16 swapOutput;
        if (isToken0In) {
            // swapping token0 for token1
            euint16 numerator = FHE.mul(userInput, reserve1);
            euint16 denominator = FHE.add(reserve0, userInput);
            swapOutput = FHE.div(numerator, denominator);
        } else {
            euint16 numerator = FHE.mul(userInput, reserve0);
            euint16 denominator = FHE.add(reserve1, userInput);
            swapOutput = FHE.div(numerator, denominator);
        }

        // ensure that the swap output is within the available liquidity
        euint16 availableLiquidity = isToken0In ? reserve1 : reserve0;
        ebool isLiquidityInsufficient = FHE.lt(availableLiquidity, swapOutput);
        swapOutput = FHE.select(isLiquidityInsufficient, FHE.asEuint16(0), swapOutput);

        // check the invariant (x * y = k)
        euint16 invariant = FHE.mul(reserve0, reserve1);
        euint16 newReserve0 = isToken0In ? FHE.add(reserve0, userInput) : FHE.sub(reserve0, swapOutput);
        euint16 newReserve1 = isToken0In ? FHE.sub(reserve1, swapOutput) : FHE.add(reserve1, userInput);
        euint16 newInvariant = FHE.mul(newReserve0, newReserve1);

        // Ensure invariant
        ebool isValid = FHE.gte(newInvariant, invariant);
        swapOutput = FHE.select(isValid, swapOutput, FHE.asEuint16(0));

        return swapOutput;
    }

    function getMainReserves(){
        return (mainReserve0, mainReserve1);
    }

    function getRatios(euint16 amountADesired, euint16 amountBDesired) external view returns (euint16 amountBOptimal, euint16 amountAOptimal) {
        (euint16 reserve0, euint16 reserve1) = getMainReserves();
        ebool isNotZero = FHE.or(reserve0.ne(FHE.asEuint16(0)), reserve1.ne(FHE.asEuint16(0)));

        amountBOptimal = FHE.select(isNotZero, FHE.div(FHE.mul(reserve1, amountADesired), reserve0), FHE.asEuint16(0));
        amountAOptimal = FHE.select(isNotZero, FHE.div(FHE.mul(reserve0, amountBDesired), reserve1), FHE.asEuint16(0));
    }

    function getAmountOut(euint16 amountIn, address tokenIn) external view returns (euint16 amountOut) {
        (euint16 reserve0, euint16 reserve1) = getMainReserves();

        amountOut = tokenIn == address(token0)
            ? FHE.div(FHE.mul(amountIn, reserve1), reserve0.add(amountIn))
            : FHE.div(FHE.mul(amountIn, reserve0), reserve1.add(amountIn));
    }

    /// @dev receive random val from VRF (possibly this https://scrt.network/secret-vrf/)
    /// @dev transfer a random amount from the secondary reserve
    /// @notice ensure that the amount is within a reasonable range and doesn't exceed the available liquidity
    function getRandomAmountFromAuxiliaryReserve() internal view returns (euint16) {} 

    function swap(euint16 userInput, address to, bool isToken0In) external returns (euint16) {
        return processSwap(userInput, to, isToken0In);
    }
}