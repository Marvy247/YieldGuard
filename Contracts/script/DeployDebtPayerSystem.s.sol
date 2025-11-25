// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/debtPayer/debtPayerFactory.sol";
import "../src/debtPayer/debtReactiveFactory.sol";

contract DeployDebtPayerSystem is Script {
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        console.log("Deploying DebtPayerFactory on Sepolia...");
        DebtPayerFactory debtPayerFactory = new DebtPayerFactory{value: 0}();
        console.log("DebtPayerFactory deployed at:", address(debtPayerFactory));
        
        vm.stopBroadcast();
        
        console.log("\n=== Debt Payer System Deployment Summary ===");
        console.log("DebtPayerFactory:", address(debtPayerFactory));
    }
}

contract DeployDebtReactiveFactory is Script {
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("REACTIVE_PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        console.log("Deploying DebtReactiveFactory on Lasna...");
        DebtReactiveFactory debtReactiveFactory = new DebtReactiveFactory{value: 0}();
        console.log("DebtReactiveFactory deployed at:", address(debtReactiveFactory));
        
        vm.stopBroadcast();
        
        console.log("\n=== Debt Reactive Factory Deployment Summary ===");
        console.log("DebtReactiveFactory:", address(debtReactiveFactory));
    }
}
