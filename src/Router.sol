// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IERC20} from "forge-std/interfaces/IERC20.sol";

interface ICurvePool {
    function exchange(
        int128 i,
        int128 j,
        uint256 _dx,
        uint256 _min_dy,
        address _receiver
    ) external returns (uint256);
    
    function coins(uint256 i) external view returns (address);
}

contract Router {
    ICurvePool public constant CURVE_POOL = ICurvePool(0x383E6b4437b59fff47B619CBA855CA29342A8559);
    IERC20 public constant USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 public constant pyUSD = IERC20(0x6c3ea9036406852006290770BEdFcAbA0e23A0e8);
    
    int128 private constant pyUSD_INDEX = 0;
    int128 private constant USDC_INDEX = 1;
    
    error InsufficientOutput();
    error TransferFailed();
    
    function swapToPyUSD(uint256 amountIn, uint256 minAmountOut) external returns (uint256 amountOut) {
    
        if (!USDC.transferFrom(msg.sender, address(this), amountIn)) {
            revert TransferFailed();
        }
        
        if (!USDC.approve(address(CURVE_POOL), amountIn)) {
            revert TransferFailed();
        }

        amountOut = CURVE_POOL.exchange(
            USDC_INDEX,
            pyUSD_INDEX,
            amountIn,
            minAmountOut,
            msg.sender
        );
        
        if (amountOut < minAmountOut) {
            revert InsufficientOutput();
        }
        
        return amountOut;
    }
}