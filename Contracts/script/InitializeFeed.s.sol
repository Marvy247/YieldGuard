// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/oracle/FeedProxy.sol";

// DEMO ONLY - Initializes feed with current Chainlink price
contract InitializeFeed is Script {
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address feedProxyAddr = vm.envAddress("FEED_PROXY_ADDRESS");
        
        vm.startBroadcast(deployerPrivateKey);
        
        FeedProxy feedProxy = FeedProxy(feedProxyAddr);
        
        console.log("Current owner:", feedProxy.owner());
        console.log("Deployer:", vm.addr(deployerPrivateKey));
        
        // Temporarily set callback proxy to deployer for demo initialization
        console.log("Temporarily updating callback proxy for demo...");
        feedProxy.updateCallbackProxy(vm.addr(deployerPrivateKey));
        
        // Push current Chainlink price (ETH/USD ~$3012)
        uint80 roundId = 2;
        int256 answer = 301256710100; // $3012.57 with 8 decimals
        uint256 timestamp = block.timestamp;
        
        console.log("Pushing initial price data...");
        feedProxy.updateRoundData(
            roundId,
            answer,
            timestamp,
            timestamp,
            roundId
        );
        
        // Set callback proxy back to OracleCallback
        address oracleCallbackAddr = vm.envAddress("CALLBACK_CONTRACT_ADDRESS");
        console.log("Restoring callback proxy to OracleCallback...");
        feedProxy.updateCallbackProxy(oracleCallbackAddr);
        
        vm.stopBroadcast();
        
        console.log("\n=== Demo Initialization Complete ===");
        console.log("FeedProxy now showing: $3012.57");
        console.log("Refresh your frontend to see the price!");
    }
}
