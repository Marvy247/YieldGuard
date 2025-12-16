// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/looping/LoopingFactory.sol";
import "../src/looping/FlashLoanHelper.sol";

/**
 * @title DeployBaseSepolia
 * @notice Deployment script for LoopGuard on Base Sepolia
 * @dev Gas optimized for L2 deployment
 */
contract DeployBaseSepolia is Script {
    
    // Base Sepolia contract addresses
    address constant AAVE_POOL = 0x8bAB6d1b75f19e9eD9fCe8b9BD338844fF79aE27;
    address constant UNISWAP_ROUTER = 0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD; // Universal Router
    address constant WETH = 0x4200000000000000000000000000000000000006; // Base Sepolia WETH
    
    // Reactive Network chain ID
    uint256 constant REACTIVE_CHAIN_ID = 5318007; // Kopli testnet
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("===========================================");
        console.log("Deploying LoopGuard to Base Sepolia");
        console.log("===========================================");
        console.log("Deployer:", deployer);
        console.log("Balance:", deployer.balance / 1e18, "ETH");
        console.log("");
        console.log("Network Configuration:");
        console.log("- Chain: Base Sepolia (84532)");
        console.log("- Aave V3 Pool:", AAVE_POOL);
        console.log("- Uniswap Router:", UNISWAP_ROUTER);
        console.log("- WETH:", WETH);
        console.log("- Reactive Chain ID:", REACTIVE_CHAIN_ID);
        console.log("===========================================");
        console.log("");
        
        vm.startBroadcast(deployerPrivateKey);
        
        // 1. Deploy FlashLoanHelper
        console.log("1. Deploying FlashLoanHelper...");
        FlashLoanHelper flashHelper = new FlashLoanHelper(AAVE_POOL, UNISWAP_ROUTER);
        console.log("   FlashLoanHelper:", address(flashHelper));
        console.log("");
        
        // 2. Deploy LoopingFactory
        console.log("2. Deploying LoopingFactory...");
        LoopingFactory factory = new LoopingFactory(
            AAVE_POOL,
            UNISWAP_ROUTER,
            REACTIVE_CHAIN_ID
        );
        console.log("   LoopingFactory:", address(factory));
        console.log("");
        
        vm.stopBroadcast();
        
        console.log("===========================================");
        console.log("Deployment Complete!");
        console.log("===========================================");
        console.log("");
        console.log("Base Sepolia Addresses:");
        console.log("- Factory:", address(factory));
        console.log("- FlashLoanHelper:", address(flashHelper));
        console.log("");
        console.log("Network Info:");
        console.log("- RPC: https://sepolia.base.org");
        console.log("- Explorer: https://sepolia.basescan.org");
        console.log("- Chain ID: 84532");
        console.log("");
        console.log("Next Steps:");
        console.log("1. Get Base Sepolia ETH:");
        console.log("   https://www.coinbase.com/faucets/base-ethereum-goerli-faucet");
        console.log("2. Wrap ETH to WETH:");
        console.log("   https://sepolia.basescan.org/address/", WETH);
        console.log("3. Create position via factory");
        console.log("===========================================");
    }
}
