// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/looping/LoopingReactiveSimple.sol";

/**
 * @title DeployReactive
 * @notice Deployment script for LoopingReactive to Reactive Network
 * @dev Run this script on Reactive Network (Kopli testnet or mainnet)
 */
contract DeployReactive is Script {
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("REACTIVE_PRIVATE_KEY");
        
        // Base Sepolia configuration
        address loopingCallback = 0x67442eB9835688E59f886a884f4E915De5ce93E8; // Factory address
        address aavePool = 0x8bAB6d1b75f19e9eD9fCe8b9BD338844fF79aE27; // Base Sepolia Aave Pool
        address monitoredPosition = 0x67442eB9835688E59f886a884f4E915De5ce93E8; // Monitor factory for now
        uint256 originChainId = 84532; // Base Sepolia
        
        vm.startBroadcast(deployerPrivateKey);
        
        console.log("=== Deploying LoopingReactive to Reactive Network ===");
        console.log("Deployer:", vm.addr(deployerPrivateKey));
        console.log("Callback Address:", loopingCallback);
        console.log("Aave Pool:", aavePool);
        console.log("Monitored Position:", monitoredPosition);
        console.log("Origin Chain ID:", originChainId);
        
        // Deploy reactive contract with initial funding (0.1 REACT for subscriptions)
        LoopingReactiveSimple reactive = new LoopingReactiveSimple{value: 0.1 ether}(
            loopingCallback,
            aavePool,
            monitoredPosition,
            originChainId
        );
        
        console.log("\n=== DEPLOYMENT SUCCESSFUL ===");
        console.log("LoopingReactiveSimple deployed at:", address(reactive));
        console.log("\n=== Configuration ===");
        console.log("Warning Threshold:", reactive.warningThreshold() / 1e18, "HF");
        console.log("Danger Threshold:", reactive.dangerThreshold() / 1e17, "/ 10 HF");
        console.log("Safe Threshold:", reactive.safeThreshold() / 1e18, "HF");
        
        console.log("\n=== CRITICAL: MANUAL ACTIVATION REQUIRED ===");
        console.log("Run this command to activate subscriptions:");
        console.log("cast send", address(reactive), "\"activateSubscriptions()\" --value 0.03ether --rpc-url $REACTIVE_RPC --private-key $REACTIVE_PRIVATE_KEY");
        
        console.log("\n=== NEXT STEPS ===");
        console.log("1. Activate subscriptions with command above");
        console.log("2. Verify contract on ReactScan: https://lasna.reactscan.net/address/", address(reactive));
        console.log("3. Monitor transactions as events trigger");
        console.log("4. Update callback contract with reactive address");
        
        vm.stopBroadcast();
    }
}
