// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/vault/VaultFactory.sol";
import "../src/vault/adapters/AaveV3Adapter.sol";
import "../src/vault/adapters/MockLendingPool.sol";

contract DeployVaultSepolia is Script {
    
    // Sepolia contract addresses
    address constant AAVE_POOL = 0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951;
    address constant USDC = 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8;
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("===========================================");
        console.log("Deploying YieldGuard Vault to Sepolia");
        console.log("===========================================");
        console.log("Deployer:", deployer);
        console.log("Balance:", deployer.balance / 1e18, "ETH");
        console.log("");
        console.log("Network Configuration:");
        console.log("- Chain: Ethereum Sepolia (11155111)");
        console.log("- Aave V3 Pool:", AAVE_POOL);
        console.log("- USDC:", USDC);
        console.log("===========================================");
        console.log("");
        
        vm.startBroadcast(deployerPrivateKey);
        
        // 1. Deploy VaultFactory
        console.log("1. Deploying VaultFactory...");
        VaultFactory factory = new VaultFactory();
        console.log("   VaultFactory:", address(factory));
        console.log("");
        
        // 2. Deploy Aave V3 Adapter
        console.log("2. Deploying AaveV3Adapter...");
        AaveV3Adapter aaveAdapter = new AaveV3Adapter(AAVE_POOL);
        console.log("   AaveV3Adapter:", address(aaveAdapter));
        console.log("");
        
        // 3. Deploy Mock Lending Pools for testing
        console.log("3. Deploying Mock Lending Pools...");
        MockLendingPool mockPool1 = new MockLendingPool(500, 7000); // 5% APY, 70% utilization
        console.log("   MockPool1 (5% APY):", address(mockPool1));
        
        MockLendingPool mockPool2 = new MockLendingPool(700, 6000); // 7% APY, 60% utilization
        console.log("   MockPool2 (7% APY):", address(mockPool2));
        
        MockLendingPool mockPool3 = new MockLendingPool(400, 8500); // 4% APY, 85% utilization (risky)
        console.log("   MockPool3 (4% APY - risky):", address(mockPool3));
        console.log("");
        
        vm.stopBroadcast();
        
        console.log("===========================================");
        console.log("Deployment Complete!");
        console.log("===========================================");
        console.log("");
        console.log("Sepolia Addresses:");
        console.log("- VaultFactory:", address(factory));
        console.log("- AaveV3Adapter:", address(aaveAdapter));
        console.log("- MockPool1:", address(mockPool1));
        console.log("- MockPool2:", address(mockPool2));
        console.log("- MockPool3:", address(mockPool3));
        console.log("");
        console.log("Pool Configurations:");
        console.log("- MockPool1: 5%% APY, 70%% utilization (balanced)");
        console.log("- MockPool2: 7%% APY, 60%% utilization (best yield)");
        console.log("- MockPool3: 4%% APY, 85%% utilization (high risk)");
        console.log("");
        console.log("Next Steps:");
        console.log("1. Create a vault via factory:");
        console.log("   factory.createVault(USDC, \"YieldGuard USDC\", \"ygUSDC\", [pool1, pool2, pool3], REACTIVE_CHAIN_ID)");
        console.log("2. Deploy ReactiveRebalancer to Reactive Network");
        console.log("3. Activate subscriptions on Reactive Network");
        console.log("===========================================");
    }
}
