// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Router} from "../src/Router.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

contract RouterTest is Test {
    Router public router;
    
    IERC20 public constant USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 public constant pyUSD = IERC20(0x6c3ea9036406852006290770BEdFcAbA0e23A0e8);
    
    address public user = makeAddr("user");
    uint256 public constant INITIAL_USDC = 1000e6; // 1000 USDC
    
    function setUp() public {
        vm.createSelectFork(vm.envString("MAINNET_ARCHIVE")); // Fork mainnet at latest block
        router = new Router();
        // console2.logBytes(address(USDC).code);
        
        // Give user some USDC
        deal(address(USDC), user, INITIAL_USDC);
    }
    
    function testSwapToPyUSD() public {
        uint256 amountIn = 100e6; // 100 USDC
        uint256 minAmountOut = 99e6; // Expect at least 99 pyUSD


        vm.startPrank(user);
        
        // Approve router to spend USDC
        USDC.approve(address(router), amountIn);

        
        uint256 initialUSDCBalance = USDC.balanceOf(user);
        uint256 initialPyUSDBalance = pyUSD.balanceOf(user);

        console2.log('initialUSDCBalance', initialUSDCBalance);
        console2.log('initialPyUSDBalance', initialPyUSDBalance);
        
        // Perform swap
        uint256 amountOut = router.swapToPyUSD(amountIn, minAmountOut);

        console2.log('amountOut', amountOut);
        
        uint256 finalUSDCBalance = USDC.balanceOf(user);
        uint256 finalPyUSDBalance = pyUSD.balanceOf(user);
        
        // Assertions
        assertEq(finalUSDCBalance, initialUSDCBalance - amountIn, "USDC not deducted correctly");
        assertEq(finalPyUSDBalance, initialPyUSDBalance + amountOut, "pyUSD not received correctly");
        assertGe(amountOut, minAmountOut, "Output less than minimum");
        
        vm.stopPrank();
    }
    
    function testSwapToPyUSDInsufficientOutput() public {
        uint256 amountIn = 100e6;
        uint256 minAmountOut = 1000e18; // Unrealistic minimum
        
        vm.startPrank(user);
        USDC.approve(address(router), amountIn);
        
        vm.expectRevert(Router.InsufficientOutput.selector);
        router.swapToPyUSD(amountIn, minAmountOut);
        
        vm.stopPrank();
    }
    
    function testSwapToPyUSDWithoutApproval() public {
        uint256 amountIn = 100e6;
        uint256 minAmountOut = 99e18;
        
        vm.startPrank(user);
        
        vm.expectRevert(Router.TransferFailed.selector);
        router.swapToPyUSD(amountIn, minAmountOut);
        
        vm.stopPrank();
    }
}