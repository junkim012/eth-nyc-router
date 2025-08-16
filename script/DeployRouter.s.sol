// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Script, console2} from "forge-std/Script.sol";
import {Router} from "../src/Router.sol";

contract DeployRouter is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        Router router = new Router();
        
        console2.log("Router deployed at:", address(router));
        console2.log("USDC address:", address(router.USDC()));
        console2.log("pyUSD address:", address(router.pyUSD()));
        console2.log("Curve Pool address:", address(router.CURVE_POOL()));
        
        vm.stopBroadcast();
    }
}