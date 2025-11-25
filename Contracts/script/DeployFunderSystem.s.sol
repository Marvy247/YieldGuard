// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/funder/funderFactory.sol";
import "../src/funder/reactiveFactory.sol";

contract DeployFunderSystem is Script {
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        console.log("Deploying FunderFactory on Sepolia...");
        FunderFactory funderFactory = new FunderFactory{value: 0}();
        console.log("FunderFactory deployed at:", address(funderFactory));
        
        vm.stopBroadcast();
        
        console.log("\n=== Funder System Deployment Summary ===");
        console.log("FunderFactory:", address(funderFactory));
    }
}

contract DeployReactiveFactory is Script {
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("REACTIVE_PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        console.log("Deploying ReactiveFactory on Lasna...");
        ReactiveFactory reactiveFactory = new ReactiveFactory{value: 0}();
        console.log("ReactiveFactory deployed at:", address(reactiveFactory));
        
        vm.stopBroadcast();
        
        console.log("\n=== Reactive Factory Deployment Summary ===");
        console.log("ReactiveFactory:", address(reactiveFactory));
    }
}
