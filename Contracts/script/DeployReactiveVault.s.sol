// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/vault/ReactiveRebalancer.sol";

contract DeployReactiveVault is Script {
    
    // Deployed addresses from Base Sepolia
    address constant VAULT_ADDRESS = 0x0768ae0974f29c9925E927a1f63d8C72937e3A6A;
    address constant USDC_ADDRESS = 0x596CED0b7c9C4426bebcb9ce22d9A32B90a272de;
    address constant STRATEGY_ADDRESS = 0x3073FCebD03Da0a62CA15d3727D20B11849E20d1;
    address constant POOL1_ADDRESS = 0xEAE3663d11D3124366Bd983697d87a69f5fB520E;
    address constant POOL2_ADDRESS = 0xe0247506e93610f93e5283BeB0DF5c8A389cF3b3;
    address constant POOL3_ADDRESS = 0xFe75CD7dd712716EB1f81B3D0cBE01b783463cf9;
    
    uint256 constant BASE_SEPOLIA_CHAIN_ID = 84532;
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("===========================================");
        console.log("Deploying ReactiveRebalancer to Reactive Lasna");
        console.log("===========================================");
        console.log("Deployer:", deployer);
        console.log("Balance:", deployer.balance / 1e18, "REACT");
        console.log("");
        console.log("Configuration:");
        console.log("- Vault (Base Sepolia):", VAULT_ADDRESS);
        console.log("- Asset (USDC):", USDC_ADDRESS);
        console.log("- Strategy:", STRATEGY_ADDRESS);
        console.log("- Pool count: 3");
        console.log("  Pool1:", POOL1_ADDRESS);
        console.log("  Pool2:", POOL2_ADDRESS);
        console.log("  Pool3:", POOL3_ADDRESS);
        console.log("- Origin Chain ID:", BASE_SEPOLIA_CHAIN_ID);
        console.log("===========================================");
        console.log("");
        
        address[] memory pools = new address[](3);
        pools[0] = POOL1_ADDRESS;
        pools[1] = POOL2_ADDRESS;
        pools[2] = POOL3_ADDRESS;
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy ReactiveRebalancer with funding for subscriptions
        console.log("Deploying ReactiveRebalancer...");
        uint256 fundingAmount = 0.5 ether; // Fund for subscriptions and callbacks
        ReactiveRebalancer rebalancer = new ReactiveRebalancer{value: fundingAmount}(
            VAULT_ADDRESS,
            USDC_ADDRESS,
            STRATEGY_ADDRESS,
            pools,
            BASE_SEPOLIA_CHAIN_ID
        );
        console.log("ReactiveRebalancer:", address(rebalancer));
        console.log("Funded with:", fundingAmount / 1e18, "REACT");
        console.log("");
        
        // Activate subscriptions
        console.log("Activating subscriptions...");
        try rebalancer.activateSubscriptions() {
            console.log("Subscriptions activated successfully!");
        } catch Error(string memory reason) {
            console.log("Subscription activation failed:", reason);
        } catch {
            console.log("Subscription activation failed (unknown reason)");
        }
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
        console.log("- Pools monitored: 3");
        console.log("  Pool1 (5%% APY):", POOL1_ADDRESS);
        console.log("  Pool2 (7%% APY):", POOL2_ADDRESS);
        console.log("  Pool3 (4%% APY, risky):", POOL3_ADDRESS);
        console.log("- Origin chain: Base Sepolia (", BASE_SEPOLIA_CHAIN_ID, ")");
        console.log("- Vault on Base Sepolia:", VAULT_ADDRESS);
        console.log("");
        console.log("Next Steps:");
        console.log("1. Update vault's rebalancer address on Base Sepolia:");
        console.log("   cast send", VAULT_ADDRESS);
        console.log("     'setRebalancer(address)'", address(rebalancer));
        console.log("     --rpc-url base_sepolia --private-key $PRIVATE_KEY");
        console.log("");
        console.log("2. Deposit funds into vault:");
        console.log("   cast send", USDC_ADDRESS);
        console.log("     'approve(address,uint256)'", VAULT_ADDRESS, "1000000000");
        console.log("     --rpc-url base_sepolia --private-key $PRIVATE_KEY");
        console.log("   cast send", VAULT_ADDRESS);
        console.log("     'deposit(uint256,address)' 1000000000", deployer);
        console.log("     --rpc-url base_sepolia --private-key $PRIVATE_KEY");
        console.log("");
        console.log("3. Trigger rebalancing by changing pool rates:");
        console.log("   cast send", POOL2_ADDRESS);
        console.log("     'setRates(uint256,uint256)' 900 6000");
        console.log("     --rpc-url base_sepolia --private-key $PRIVATE_KEY");
        console.log("===========================================");
    }
}
