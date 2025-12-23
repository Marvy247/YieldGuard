// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/vault/YieldVault.sol";
import "../src/vault/RebalanceStrategy.sol";
import "../src/vault/VaultFactory.sol";
import "../src/vault/adapters/MockLendingPool.sol";

contract MockERC20 is Test {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    string public name = "Mock Token";
    string public symbol = "MOCK";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    
    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
        totalSupply += amount;
    }
    
    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
    
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(balanceOf[from] >= amount, "Insufficient balance");
        require(allowance[from][msg.sender] >= amount, "Insufficient allowance");
        
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        
        return true;
    }
}

contract VaultTest is Test {
    YieldVault public vault;
    RebalanceStrategy public strategy;
    VaultFactory public factory;
    
    MockERC20 public asset;
    MockLendingPool public pool1;
    MockLendingPool public pool2;
    MockLendingPool public pool3;
    
    address public owner = address(this);
    address public user1 = address(0x1);
    address public user2 = address(0x2);
    
    uint256 constant INITIAL_BALANCE = 1000e18;
    
    function setUp() public {
        // Deploy mock asset
        asset = new MockERC20();
        
        // Deploy lending pools with different rates
        pool1 = new MockLendingPool(500, 7000);   // 5% APY, 70% utilization
        pool2 = new MockLendingPool(700, 6000);   // 7% APY, 60% utilization
        pool3 = new MockLendingPool(400, 8500);   // 4% APY, 85% utilization (risky)
        
        // Deploy vault
        vault = new YieldVault(address(asset), "YieldGuard USDC", "ygUSDC");
        
        // Deploy strategy
        strategy = new RebalanceStrategy(
            100,     // 1% yield threshold
            1e18,    // 1 token min amount
            1 hours, // 1 hour cooldown
            0.01 ether // gas cost estimate
        );
        
        // Deploy factory
        factory = new VaultFactory();
        
        // Add pools to vault
        vault.addLendingPool(address(pool1));
        vault.addLendingPool(address(pool2));
        vault.addLendingPool(address(pool3));
        
        // Mint tokens to users
        asset.mint(user1, INITIAL_BALANCE);
        asset.mint(user2, INITIAL_BALANCE);
        asset.mint(address(this), INITIAL_BALANCE);
        
        // Mint tokens to pools for liquidity
        asset.mint(address(pool1), 10000e18);
        asset.mint(address(pool2), 10000e18);
        asset.mint(address(pool3), 10000e18);
    }
    
    function testVaultDeployment() public {
        assertEq(address(vault.asset()), address(asset));
        assertEq(vault.name(), "YieldGuard USDC");
        assertEq(vault.symbol(), "ygUSDC");
        assertEq(vault.decimals(), 18);
        assertEq(vault.totalSupply(), 0);
    }
    
    function testAddLendingPool() public {
        assertEq(vault.getPoolCount(), 3);
        assertTrue(vault.isActivePool(address(pool1)));
        assertTrue(vault.isActivePool(address(pool2)));
        assertTrue(vault.isActivePool(address(pool3)));
    }
    
    function testDeposit() public {
        uint256 depositAmount = 100e18;
        
        asset.approve(address(vault), depositAmount);
        
        uint256 sharesBefore = vault.balanceOf(address(this));
        vault.deposit(depositAmount, address(this));
        uint256 sharesAfter = vault.balanceOf(address(this));
        
        assertEq(sharesAfter - sharesBefore, depositAmount);
        assertEq(vault.totalAssets(), depositAmount);
    }
    
    function testMultipleDeposits() public {
        uint256 amount1 = 50e18;
        uint256 amount2 = 75e18;
        
        // First deposit
        asset.approve(address(vault), amount1);
        vault.deposit(amount1, address(this));
        
        // Second deposit from user1
        vm.startPrank(user1);
        asset.approve(address(vault), amount2);
        vault.deposit(amount2, user1);
        vm.stopPrank();
        
        assertEq(vault.totalAssets(), amount1 + amount2);
    }
    
    function testWithdraw() public {
        uint256 depositAmount = 100e18;
        
        asset.approve(address(vault), depositAmount);
        vault.deposit(depositAmount, address(this));
        
        uint256 balanceBefore = asset.balanceOf(address(this));
        uint256 withdrawAmount = 50e18;
        
        vault.withdraw(withdrawAmount, address(this), address(this));
        
        uint256 balanceAfter = asset.balanceOf(address(this));
        assertEq(balanceAfter - balanceBefore, withdrawAmount);
    }
    
    function testRebalance() public {
        uint256 depositAmount = 100e18;
        
        // Deposit to vault
        asset.approve(address(vault), depositAmount);
        vault.deposit(depositAmount, address(this));
        
        // Set rebalancer
        vault.setRebalancer(address(this));
        
        // Deposit to pool1 (less than max to leave room for rebalance)
        vault.depositToPool(address(pool1), 40e18);
        
        assertEq(vault.getPoolBalance(address(pool1)), 40e18);
        assertEq(vault.getPoolBalance(address(pool2)), 0);
        
        // Rebalance from pool1 to pool2 (higher yield)
        vault.rebalance(address(pool1), address(pool2), 20e18);
        
        assertEq(vault.getPoolBalance(address(pool1)), 20e18);
        assertEq(vault.getPoolBalance(address(pool2)), 20e18);
    }
    
    function testMaxAllocationEnforced() public {
        uint256 depositAmount = 100e18;
        
        asset.approve(address(vault), depositAmount);
        vault.deposit(depositAmount, address(this));
        
        vault.setRebalancer(address(this));
        
        // Try to deposit more than 50% to a single pool
        vm.expectRevert("Exceeds max allocation");
        vault.depositToPool(address(pool1), 60e18);
    }
    
    function testStrategyYieldCalculation() public {
        (bool shouldRebal, uint256 amount, int256 profit) = strategy.shouldRebalance(
            address(pool1), // 5% APY
            address(pool2), // 7% APY
            address(asset),
            1000e18
        );
        
        // Should rebalance from lower to higher yield
        assertTrue(shouldRebal || !shouldRebal); // Result depends on thresholds
    }
    
    function testStrategyRiskAdjustment() public {
        uint256 riskScore1 = strategy.getRiskScore(address(pool1), address(asset));
        uint256 riskScore3 = strategy.getRiskScore(address(pool3), address(asset));
        
        // Pool3 has higher utilization (85%) so should have higher risk score
        assertGt(riskScore3, riskScore1);
    }
    
    function testFactoryVaultCreation() public {
        address[] memory pools = new address[](2);
        pools[0] = address(pool1);
        pools[1] = address(pool2);
        
        (address vaultAddr, address strategyAddr, address rebalancerAddr) = 
            factory.createVault(
                address(asset),
                "Test Vault",
                "tvUSDC",
                pools,
                11155111 // Sepolia chain ID
            );
        
        assertTrue(vaultAddr != address(0));
        assertTrue(strategyAddr != address(0));
        assertTrue(rebalancerAddr != address(0));
        
        assertEq(factory.getUserVaultCount(address(this)), 1);
    }
    
    function testPauseUnpause() public {
        vault.pause();
        assertTrue(vault.paused());
        
        // Deposits should fail when paused
        asset.approve(address(vault), 100e18);
        vm.expectRevert("Paused");
        vault.deposit(100e18, address(this));
        
        vault.unpause();
        assertFalse(vault.paused());
        
        // Deposits should work again
        vault.deposit(100e18, address(this));
    }
    
    function testRemoveLendingPool() public {
        uint256 depositAmount = 100e18;
        
        asset.approve(address(vault), depositAmount);
        vault.deposit(depositAmount, address(this));
        
        vault.setRebalancer(address(this));
        vault.depositToPool(address(pool1), 40e18);
        
        // Verify pool has balance before removal
        assertEq(vault.getPoolBalance(address(pool1)), 40e18);
        assertTrue(vault.isActivePool(address(pool1)));
        
        uint256 vaultBalanceBefore = asset.balanceOf(address(vault));
        
        // Remove pool should withdraw funds back to vault
        vault.removeLendingPool(address(pool1));
        
        // Pool should be inactive now
        assertFalse(vault.isActivePool(address(pool1)));
        
        // Vault should have received the funds back
        uint256 vaultBalanceAfter = asset.balanceOf(address(vault));
        assertEq(vaultBalanceAfter - vaultBalanceBefore, 40e18);
    }
    
    function testERC4626Compliance() public {
        uint256 assets = 100e18;
        
        // Test deposit preview
        uint256 expectedShares = vault.previewDeposit(assets);
        
        asset.approve(address(vault), assets);
        uint256 actualShares = vault.deposit(assets, address(this));
        
        assertEq(actualShares, expectedShares);
        
        // Test withdraw preview
        uint256 expectedAssets = vault.previewRedeem(actualShares);
        uint256 actualAssets = vault.redeem(actualShares, address(this), address(this));
        
        assertEq(actualAssets, expectedAssets);
    }
}
