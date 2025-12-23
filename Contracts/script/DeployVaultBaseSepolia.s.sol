// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/vault/VaultFactory.sol";
import "../src/vault/adapters/MockLendingPool.sol";

contract MockERC20 {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    string public name = "Mock USDC";
    string public symbol = "USDC";
    uint8 public decimals = 6;
    uint256 public totalSupply;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
        totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }
    
    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }
    
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(balanceOf[from] >= amount, "Insufficient balance");
        require(allowance[from][msg.sender] >= amount, "Insufficient allowance");
        
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        
        emit Transfer(from, to, amount);
        return true;
    }
}

contract DeployVaultBaseSepolia is Script {
    
    // Reactive Network chain ID
    uint256 constant REACTIVE_CHAIN_ID = 10045362; // Lasna testnet
    
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("===========================================");
        console.log("Deploying YieldGuard Vault to Base Sepolia");
        console.log("===========================================");
        console.log("Deployer:", deployer);
        console.log("Balance:", deployer.balance / 1e18, "ETH");
        console.log("");
        console.log("Network Configuration:");
        console.log("- Chain: Base Sepolia (84532)");
        console.log("- Reactive Chain ID:", REACTIVE_CHAIN_ID);
        console.log("===========================================");
        console.log("");
        
        vm.startBroadcast(deployerPrivateKey);
        
        // 1. Deploy Mock USDC for testing
        console.log("1. Deploying Mock USDC...");
        MockERC20 usdc = new MockERC20();
        console.log("   Mock USDC:", address(usdc));
        
        // Mint some USDC to deployer for testing
        usdc.mint(deployer, 10000 * 1e6); // 10,000 USDC
        console.log("   Minted 10,000 USDC to deployer");
        console.log("");
        
        // 2. Deploy VaultFactory
        console.log("2. Deploying VaultFactory...");
        VaultFactory factory = new VaultFactory();
        console.log("   VaultFactory:", address(factory));
        console.log("");
        
        // 3. Deploy Mock Lending Pools with different rates
        console.log("3. Deploying Mock Lending Pools...");
        
        MockLendingPool pool1 = new MockLendingPool(500, 7000); // 5% APY, 70% utilization
        console.log("   Pool1 (Aave-like):", address(pool1));
        console.log("     - APY: 5%");
        console.log("     - Utilization: 70%");
        
        // Mint liquidity to pool1
        usdc.mint(address(pool1), 100000 * 1e6);
        console.log("     - Liquidity: 100,000 USDC");
        
        MockLendingPool pool2 = new MockLendingPool(700, 6000); // 7% APY, 60% utilization  
        console.log("   Pool2 (Compound-like):", address(pool2));
        console.log("     - APY: 7% (BEST)");
        console.log("     - Utilization: 60%");
        
        // Mint liquidity to pool2
        usdc.mint(address(pool2), 100000 * 1e6);
        console.log("     - Liquidity: 100,000 USDC");
        
        MockLendingPool pool3 = new MockLendingPool(400, 8500); // 4% APY, 85% utilization (risky)
        console.log("   Pool3 (High-risk):", address(pool3));
        console.log("     - APY: 4%");
        console.log("     - Utilization: 85% (HIGH RISK)");
        
        // Mint liquidity to pool3
        usdc.mint(address(pool3), 100000 * 1e6);
        console.log("     - Liquidity: 100,000 USDC");
        console.log("");
        
        // 4. Create a vault via factory
        console.log("4. Creating YieldGuard Vault via Factory...");
        address[] memory pools = new address[](3);
        pools[0] = address(pool1);
        pools[1] = address(pool2);
        pools[2] = address(pool3);
        
        (address vaultAddr, address strategyAddr, address rebalancerPlaceholder) = 
            factory.createVault(
                address(usdc),
                "YieldGuard USDC Vault",
                "ygUSDC",
                pools,
                REACTIVE_CHAIN_ID
            );
        
        console.log("   Vault:", vaultAddr);
        console.log("   Strategy:", strategyAddr);
        console.log("   Rebalancer (placeholder):", rebalancerPlaceholder);
        console.log("");
        
        vm.stopBroadcast();
        
        console.log("===========================================");
        console.log("Deployment Complete!");
        console.log("===========================================");
        console.log("");
        console.log("Base Sepolia Addresses:");
        console.log("- Mock USDC:", address(usdc));
        console.log("- VaultFactory:", address(factory));
        console.log("- Pool1 (5% APY):", address(pool1));
        console.log("- Pool2 (7% APY):", address(pool2));
        console.log("- Pool3 (4% APY, risky):", address(pool3));
        console.log("- Vault:", vaultAddr);
        console.log("- Strategy:", strategyAddr);
        console.log("");
        console.log("Pool Configurations:");
        console.log("- Pool1: 5%% APY, 70%% utilization (balanced)");
        console.log("- Pool2: 7%% APY, 60%% utilization (BEST YIELD)");
        console.log("- Pool3: 4%% APY, 85%% utilization (HIGH RISK)");
        console.log("");
        console.log("Next Steps:");
        console.log("1. Deploy ReactiveRebalancer to Reactive Lasna:");
        console.log("   export VAULT_ADDRESS=", vaultAddr);
        console.log("   export USDC_ADDRESS=", address(usdc));
        console.log("   export STRATEGY_ADDRESS=", strategyAddr);
        console.log("   export POOL1_ADDRESS=", address(pool1));
        console.log("   export POOL2_ADDRESS=", address(pool2));
        console.log("   export POOL3_ADDRESS=", address(pool3));
        console.log("   forge script script/DeployReactiveVault.s.sol --rpc-url reactive --broadcast");
        console.log("");
        console.log("2. Test the vault:");
        console.log("   - Approve USDC to vault");
        console.log("   - Deposit USDC to vault");
        console.log("   - Change pool rates to trigger rebalance");
        console.log("===========================================");
    }
}
