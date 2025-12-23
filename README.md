# YieldGuard Auto-Rebalancing Vault

**An intelligent, self-optimizing DeFi yield vault powered by Reactive Smart Contracts**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Solidity](https://img.shields.io/badge/Solidity-^0.8.0-blue)](https://soliditylang.org/)
[![ERC-4626](https://img.shields.io/badge/ERC--4626-Compliant-green)](https://eips.ethereum.org/EIPS/eip-4626)
[![Tests](https://img.shields.io/badge/Tests-13%2F13%20Passing-brightgreen)]()

---

##  What is YieldGuard?

YieldGuard is a tokenized vault that **autonomously optimizes yield** across multiple lending protocols. Unlike traditional yield aggregators that require manual rebalancing or centralized bots, YieldGuard uses **Reactive Smart Contracts** to monitor rates 24/7 and automatically move funds to maximize returns.

### The Problem

-  **Yields constantly change** across DeFi protocols
-  **Manual monitoring is tedious** and error-prone
-  **Bot services cost** $50-100/month per vault
- ️ **Centralized bots have** downtime and latency
-  **Simple APY comparison** ignores risks

### Our Solution

YieldGuard uses **Reactive Network** to:
-  **Monitor** lending pool rates in real-time
-  **Calculate** risk-adjusted, gas-aware profitability
-  **Execute** rebalancing automatically when profitable
-  **Protect** capital with concentration limits
-  **Optimize** 24/7 without user intervention

---

##  Quick Start

### For Users (Depositors)

```solidity
// 1. Approve vault to spend your USDC
IERC20(USDC).approve(vaultAddress, amount);

// 2. Deposit and receive vault shares
uint256 shares = vault.deposit(amount, msg.sender);

// 3. Your funds are automatically optimized 24/7! 

// 4. Withdraw anytime
vault.redeem(shares, msg.sender, msg.sender);
```

### For Developers

```bash
# Clone repository
git clone <repo-url>
cd LoopGuard/Contracts

# Install dependencies
forge install

# Run tests
forge test

# Deploy to Base Sepolia
forge script script/DeployVaultBaseSepolia.s.sol \
    --rpc-url base_sepolia --broadcast --legacy

# Deploy to Reactive Lasna
forge script script/DeployReactiveVault.s.sol \
    --rpc-url reactive --broadcast --legacy
```

---

## ️ Architecture

### System Overview

```
┌────────────────────────────────────────────────────────┐
│                   USER DEPOSITS                         │
│                         ↓                               │
│              ┌──────────────────┐                       │
│              │   YieldVault     │                       │
│              │   (ERC-4626)     │                       │
│              └────────┬─────────┘                       │
│                       │                                 │
│        ┌──────────────┼──────────────┐                 │
│        ↓              ↓              ↓                  │
│   ┌────────┐    ┌────────┐    ┌────────┐              │
│   │ Pool1  │    │ Pool2  │    │ Pool3  │              │
│   │ 5% APY │    │ 7% APY │    │ 4% APY │              │
│   └────────┘    └────────┘    └────────┘              │
│        ↓              ↓              ↓                  │
│   [Rate Events] [Rate Events] [Rate Events]           │
│                       ↓                                 │
│              ┌────────────────────┐                    │
│              │ ReactiveRebalancer │                    │
│              │ (Reactive Network) │                    │
│              │                    │                    │
│              │ • Monitors 24/7    │                    │
│              │ • Calculates best  │                    │
│              │ • Triggers actions │                    │
│              └────────────────────┘                    │
└────────────────────────────────────────────────────────┘
```

### Key Components

#### 1. **YieldVault** (Base Sepolia)
- **Standard**: ERC-4626 compliant
- **Features**: Deposit, withdraw, share-based accounting
- **Safety**: Max 50% per pool, emergency pause
- **Address**: `0x0768ae0974f29c9925E927a1f63d8C72937e3A6A`

#### 2. **RebalanceStrategy** (Base Sepolia)
- **Function**: Calculates optimal rebalancing decisions
- **Logic**: Gas-aware, risk-adjusted yield comparison
- **Safety**: Cooldown periods, minimum amounts
- **Address**: `0x3073FCebD03Da0a62CA15d3727D20B11849E20d1`

#### 3. **ReactiveRebalancer** (Reactive Lasna)
- **Function**: Monitors pools and triggers rebalancing
- **Subscriptions**: 6 event listeners across 3 pools
- **Automation**: Fully autonomous, no manual intervention
- **Address**: `0x313929901Ba9271F71aC38B6142f39BdcCC60921`

#### 4. **Lending Pool Adapters** (Base Sepolia)
- **Pool1** (Aave-like): 5% APY, 70% utilization
- **Pool2** (Compound-like): 7% APY, 60% utilization
- **Pool3** (High-risk): 4% APY, 85% utilization

---

##  Smart Rebalancing Logic

### 1. Risk-Adjusted Yield

```solidity
// Penalize high-utilization pools (liquidity risk)
if (utilization > 80%) {
    excessUtil = utilization - 80%;
    penalty = (baseRate × excessUtil × 20%) / 10000;
    adjustedRate = baseRate - penalty;
}

// Example:
// Pool3: 4% APY @ 85% utilization
// → 4% - (4% × 5% × 20%) = 3.2% effective APY
```

### 2. Gas-Aware Profitability

```solidity
// Only rebalance if profitable after gas
rateDiff = toPoolRate - fromPoolRate;
annualProfit = (amount × rateDiff) / 1e18;
dailyProfit = annualProfit / 365;

if (dailyProfit > estimatedGasCost) {
    executeRebalance(); //  Profitable!
} else {
    skip(); //  Would lose money
}
```

### 3. Optimal Amount Calculation

```solidity
// Conservative rebalancing
baseAmount = fromPoolBalance / 2; // Move 50%

// Reduce if destination has high utilization
if (toPoolUtil > 80%) {
    maxSafe = vaultTotal × 10%; // Cap at 10%
    amount = min(baseAmount, maxSafe);
}
```

---

##  How Rebalancing Works

### Automatic Trigger Flow

```
1. RATE CHANGE
   Pool2 APY: 7% → 9%
   ↓
2. EVENT EMITTED
   Pool2.RateUpdate event on Base Sepolia
   ↓
3. REACTIVE DETECTS
   ReactiveRebalancer.react() called on Lasna
   ↓
4. STRATEGY EVALUATES
   • Get all pool rates
   • Adjust for utilization risk
   • Calculate profit vs gas cost
   • Decision: Move Pool1 → Pool2 (profitable!)
   ↓
5. CALLBACK EMITTED
   ReactiveRebalancer emits Callback event
   ↓
6. VAULT EXECUTES
   • Withdraw from Pool1
   • Deposit to Pool2
   ↓
7. OPTIMIZATION COMPLETE
   Funds now earning 9% instead of 5%! 
```

### Example Scenario

**Initial State**:
- Pool1: 400 USDC @ 5% APY
- Pool2: 300 USDC @ 7% APY
- Pool3: 300 USDC @ 4% APY

**Pool2 rate increases to 9%**:

1. **Risk Adjustment**:
   - Pool1: 5% (safe, 70% util)
   - Pool2: 9% (safe, 60% util) ← BEST!
   - Pool3: 3.2% (risky, 85% util, penalty applied)

2. **Profit Calculation**:
   - Move 200 USDC from Pool1 → Pool2
   - Extra yield: (9% - 5%) × 200 = 8 USDC/year
   - Daily: 0.022 USDC
   - Gas cost: ~0.01 USDC
   - **Net profit: 0.012 USDC/day** 

3. **Execution**:
   - Withdraw 200 from Pool1
   - Deposit 200 to Pool2

4. **New State**:
   - Pool1: 200 USDC @ 5%
   - Pool2: 500 USDC @ 9% ← Optimized!
   - Pool3: 300 USDC @ 4%

---

## ️ Security Features

### Implemented Protections

| Feature | Description | Benefit |
|---------|-------------|---------|
| **Max Allocation** | 50% cap per pool | Prevents over-concentration |
| **Risk Adjustment** | Penalize high utilization | Avoids liquidity traps |
| **Cooldown Period** | 1 hour min between rebalances | Prevents excessive gas |
| **Minimum Amount** | 1 token threshold | No dust rebalancing |
| **Emergency Pause** | Owner can halt operations | Quick response to issues |
| **Authorized Rebalancer** | Only designated contract | Prevents unauthorized moves |
| **ERC-4626 Standard** | Battle-tested interface | User trust & composability |

### Attack Vector Mitigation

| Attack | Risk | Mitigation |
|--------|------|------------|
| Pool liquidity crisis | Medium | Diversification (3 pools), utilization monitoring |
| Oracle manipulation | Low | Use on-chain rates directly from pools |
| Callback gas griefing | Low | Gas limits, funded reactive contract |
| Vault drainage | Low | Allocation limits (50%), pause mechanism |
| Sandwich attacks | Medium | Single-pool operations, future MEV protection |

---

##  Testing

### Test Results

```bash
forge test --match-contract VaultTest -vv

Ran 13 tests for test/VaultTest.t.sol:VaultTest
 testAddLendingPool() (gas: 25330)
 testDeposit() (gas: 131953)
 testERC4626Compliance() (gas: 131024)
 testFactoryVaultCreation() (gas: 4810668)
 testMaxAllocationEnforced() (gas: 240248)
 testMultipleDeposits() (gas: 181322)
 testPauseUnpause() (gas: 114302)
 testRebalance() (gas: 342892)
 testRemoveLendingPool() (gas: 232552)
 testStrategyRiskAdjustment() (gas: 24342)
 testStrategyYieldCalculation() (gas: 16935)
 testVaultDeployment() (gas: 23982)
 testWithdraw() (gas: 148844)

Suite result: ok. 13 passed; 0 failed; 0 skipped
```

### Test Coverage

-  ERC-4626 standard compliance
-  Multi-pool allocation and withdrawal
-  Rebalancing execution
-  Risk adjustment calculations
-  Max allocation enforcement
-  Pause/unpause functionality
-  Factory vault creation
-  Strategy profit estimation
-  Edge cases (high util, insufficient liquidity)

---

##  Performance Metrics

### Gas Costs

| Operation | Gas Used | Cost (@ 10 gwei) |
|-----------|----------|------------------|
| Deposit | ~132k | ~$0.30 |
| Withdraw | ~149k | ~$0.33 |
| Rebalance | ~343k | ~$0.75 |
| Subscription setup | ~21k | ~$0.05 |

### Profitability Threshold

**Minimum yield differential for profitability**:
- Gas cost: 0.01 ETH (~$20 @ $2000/ETH)
- Break-even: 0.022 ETH/day profit
- Requires: ~1% APY difference on $800k+ position
- Or: ~4% APY difference on $200k position

**YieldGuard only rebalances when this threshold is exceeded.**

---

##  Technical Documentation

### Contract Interfaces

#### YieldVault.sol (ERC-4626)

```solidity
interface IYieldVault {
    // ERC-4626 Standard
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);
    
    // Vault Management
    function addLendingPool(address pool) external;
    function removeLendingPool(address pool) external;
    function setRebalancer(address rebalancer) external;
    function pause() external;
    function unpause() external;
    
    // Views
    function totalAssets() external view returns (uint256);
    function getPoolBalance(address pool) external view returns (uint256);
    function getPoolYield(address pool) external view returns (uint256);
}
```

#### ReactiveRebalancer.sol

```solidity
interface IReactiveRebalancer {
    // Reactive Interface
    function react(LogRecord calldata log) external;
    
    // Management
    function activateSubscriptions() external;
    function addPool(address pool) external;
    function removePool(address pool) external;
    function setCheckInterval(uint256 interval) external;
    
    // Views
    function getMonitoringStatus() external view returns (
        uint256 poolCount,
        uint256 lastCheck,
        uint256 rebalanceCount,
        bool isPaused
    );
}
```

### Deployment Guide

#### Prerequisites

```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Set environment variables
export PRIVATE_KEY=your_private_key
export INFURA_KEY=your_infura_key
```

#### Deploy to Base Sepolia

```bash
cd Contracts

# Deploy vault system
forge script script/DeployVaultBaseSepolia.s.sol:DeployVaultBaseSepolia \
    --rpc-url base_sepolia \
    --broadcast \
    --legacy

# Save returned addresses:
# - Vault: 0x...
# - Strategy: 0x...
# - Pools: 0x..., 0x..., 0x...
```

#### Deploy to Reactive Lasna

```bash
# Set addresses from previous deployment
export VAULT_ADDRESS=0x...
export STRATEGY_ADDRESS=0x...
export POOL1_ADDRESS=0x...
export POOL2_ADDRESS=0x...
export POOL3_ADDRESS=0x...

# Deploy reactive rebalancer
forge script script/DeployReactiveVault.s.sol:DeployReactiveVault \
    --rpc-url reactive \
    --broadcast \
    --legacy

# Save ReactiveRebalancer address
```

#### Link Contracts

```bash
# Link rebalancer to vault
cast send $VAULT_ADDRESS \
    "setRebalancer(address)" $REBALANCER_ADDRESS \
    --rpc-url base_sepolia \
    --private-key $PRIVATE_KEY

# Activate subscriptions
cast send $REBALANCER_ADDRESS \
    "activateSubscriptions()" \
    --value 0.1ether \
    --rpc-url reactive \
    --private-key $PRIVATE_KEY
```

---

##  Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

```bash
# Clone repo
git clone <repo-url>
cd LoopGuard/Contracts

# Install dependencies
forge install

# Run tests
forge test -vv

# Check coverage
forge coverage

# Format code
forge fmt
```

---

##  License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

##  Acknowledgments

- **Reactive Network** for the innovative event-driven architecture
- **OpenZeppelin** for secure contract standards
- **Foundry** for the excellent development toolkit
- **Aave & Compound** for DeFi lending protocols

---

**YieldGuard: Set it and forget it. Your yield, automatically optimized.** 

Built with ️ using Reactive Network
