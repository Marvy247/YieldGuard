// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/vault/ReactiveRebalancer.sol";

contract DeployVaultReactive is Script {
    
    // Update these after deploying to Sepolia
    address VAULT_ADDRESS;
    address USDC_ADDRESS;
    address STRATEGY_ADDRESS;
    address[] POOL_ADDRESSES;
    uint256 constant SEPOLIA_CHAIN_ID = 11155111;
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        // Read addresses from environment or use defaults
        VAULT_ADDRESS = vm.envOr("VAULT_ADDRESS", address(0));
        USDC_ADDRESS = vm.envOr("USDC_ADDRESS", 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8);
        STRATEGY_ADDRESS = vm.envOr("STRATEGY_ADDRESS", address(0));
        
        require(VAULT_ADDRESS != address(0), "VAULT_ADDRESS not set");
        require(STRATEGY_ADDRESS != address(0), "STRATEGY_ADDRESS not set");
        
        // Read pool addresses from environment
        address pool1 = vm.envOr("POOL1_ADDRESS", address(0));
        address pool2 = vm.envOr("POOL2_ADDRESS", address(0));
        address pool3 = vm.envOr("POOL3_ADDRESS", address(0));
        
        require(pool1 != address(0), "POOL1_ADDRESS not set");
        require(pool2 != address(0), "POOL2_ADDRESS not set");
        
        POOL_ADDRESSES.push(pool1);
        POOL_ADDRESSES.push(pool2);
        if (pool3 != address(0)) {
            POOL_ADDRESSES.push(pool3);
        }
        
        console.log("===========================================");
        console.log("Deploying ReactiveRebalancer to Reactive Network");
        console.log("===========================================");
        console.log("Deployer:", deployer);
        console.log("Balance:", deployer.balance / 1e18, "REACT");
        console.log("");
        console.log("Configuration:");
        console.log("- Vault:", VAULT_ADDRESS);
        console.log("- Asset:", USDC_ADDRESS);
        console.log("- Strategy:", STRATEGY_ADDRESS);
        console.log("- Pool count:", POOL_ADDRESSES.length);
        console.log("- Origin Chain ID:", SEPOLIA_CHAIN_ID);
        console.log("===========================================");
        console.log("");
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy ReactiveRebalancer with funding for subscriptions
        console.log("Deploying ReactiveRebalancer...");
        uint256 fundingAmount = 0.1 ether; // Fund for subscriptions
        ReactiveRebalancer rebalancer = new ReactiveRebalancer{value: fundingAmount}(
            VAULT_ADDRESS,
            USDC_ADDRESS,
            STRATEGY_ADDRESS,
            POOL_ADDRESSES,
            SEPOLIA_CHAIN_ID
        );
        console.log("ReactiveRebalancer:", address(rebalancer));
        console.log("");
        
        // Activate subscriptions
        console.log("Activating subscriptions...");
        rebalancer.activateSubscriptions();
        console.log("Subscriptions activated!");
        console.log("");
        
        vm.stopBroadcast();
        
        console.log("===========================================");
        console.log("Deployment Complete!");
        console.log("===========================================");
        console.log("");
        console.log("Reactive Network Address:");
        console.log("- ReactiveRebalancer:", address(rebalancer));
        console.log("");
        console.log("Monitoring Configuration:");
        console.log("- Pools monitored:", POOL_ADDRESSES.length);
        for (uint256 i = 0; i < POOL_ADDRESSES.length; i++) {
            console.log("  Pool", i + 1, ":", POOL_ADDRESSES[i]);
        }
        console.log("- Origin chain:", SEPOLIA_CHAIN_ID);
        console.log("- Vault on Sepolia:", VAULT_ADDRESS);
        console.log("");
        console.log("Next Steps:");
        console.log("1. Update vault's rebalancer address:");
        console.log("   vault.setRebalancer(", address(rebalancer), ")");
        console.log("2. Deposit funds into vault");
        console.log("3. Wait for rate changes to trigger automatic rebalancing");
        console.log("===========================================");
    }
}
