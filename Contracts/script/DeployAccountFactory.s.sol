// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/account/accountFactory.sol";

contract DeployAccountFactory is Script {
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        console.log("Deploying AccountFactory on Sepolia...");
        AccountFactory accountFactory = new AccountFactory{value: 0}();
        console.log("AccountFactory deployed at:", address(accountFactory));
        
        vm.stopBroadcast();
        
        console.log("\n=== Deployment Summary ===");
        console.log("AccountFactory:", address(accountFactory));
    }
}
