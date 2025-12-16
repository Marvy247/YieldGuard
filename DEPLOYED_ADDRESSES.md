# 🛡️ LoopGuard - Deployed Contract Addresses

## Your Position's 24/7 Guardian
**Latest Deployment**: December 12, 2024  
**Network**: Base Sepolia (L2 Testnet)  
**Why Base Sepolia**: 50-100x cheaper gas fees than Ethereum Sepolia while maintaining full functionality

---

## Main Contracts (Base Sepolia - L2)

### LoopingFactory 🏭
**Address**: `0x67442eB9835688E59f886a884f4E915De5ce93E8`  
**Explorer**: https://sepolia.basescan.org/address/0x67442eB9835688E59f886a884f4E915De5ce93E8  
**Chain**: Base Sepolia (84532)

**Purpose**: Factory contract for deploying user-specific leveraged looping positions

**Key Functions**:
- `createPosition()` - Deploy new position (callback + reactive contracts)
- `getUserPositions()` - Get all positions for a user
- `getPositionDetails()` - Get detailed info about a position

---

### FlashLoanHelper ⚡
**Address**: `0xc898e8fc8D051cFA2B756438F751086451de1688`  
**Explorer**: https://sepolia.basescan.org/address/0xc898e8fc8D051cFA2B756438F751086451de1688  
**Chain**: Base Sepolia (84532)

**Purpose**: Enables one-transaction leverage using Aave flash loans

**Key Functions**:
- `executeFlashLeverage()` - Instant leverage in one transaction
- `executeFlashDeleverage()` - Instant position unwind

---

## Protocol Dependencies (Base Sepolia)

### Aave V3 Pool
**Address**: `0x8bAB6d1b75f19e9eD9fCe8b9BD338844fF79aE27`  
**Explorer**: https://sepolia.basescan.org/address/0x8bAB6d1b75f19e9eD9fCe8b9BD338844fF79aE27  
**Purpose**: Lending protocol for supply/borrow operations

### Uniswap Universal Router
**Address**: `0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD`  
**Explorer**: https://sepolia.basescan.org/address/0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD  
**Purpose**: DEX for token swaps during looping

### WETH (Wrapped Ether)
**Address**: `0x4200000000000000000000000000000000000006`  
**Explorer**: https://sepolia.basescan.org/address/0x4200000000000000000000000000000000000006  
**Purpose**: Wrapped ETH for trading and collateral

---

## Dynamic Contracts (User-Specific)

When you create a position via `factory.createPosition()`, two contracts are deployed:

### LoopingCallback
**Deployed to**: Origin chain (Sepolia)  
**Purpose**: Manages the leveraged position  
**Features**:
- Execute leverage loops
- Unwind positions
- Emergency protection

### LoopingReactive  
**Deployed to**: Reactive Network (Lasna)  
**Purpose**: 24/7 health factor monitoring  
**Features**:
- Subscribe to Aave events
- Monitor health factor continuously  
- Trigger automatic protection

---

## How to Use

### 1. Get Base Sepolia ETH
Visit: https://www.coinbase.com/faucets/base-ethereum-goerli-faucet  
(Provides testnet ETH for Base Sepolia)

### 2. Create a Position
```javascript
// Connect wallet to Base Sepolia (Chain ID: 84532)
// Call factory.createPosition() with:
createPosition(
  "0x4200000000000000000000000000000000000006",  // WETH collateral
  "0x4200000000000000000000000000000000000006",  // WETH borrow (same-asset)
  5000,             // 50% target LTV (conservative for testnet)
  300               // 3% max slippage
) { value: 0.1 ether }  // Fund the contracts
```

### 2. Your Contracts Get Deployed
- ✅ LoopingCallback deployed to Sepolia
- ✅ LoopingReactive deployed to Reactive Network
- ✅ Both contracts linked and ready

### 3. Execute Leverage
- Approve tokens
- Call `callback.executeLeverageLoop(amount)`
- Position created with automatic 24/7 protection!

---

## Frontend Integration

Update `/app/src/config/looping.ts`:

```typescript
export const LOOPING_ADDRESSES = {
  84532: {  // Base Sepolia
    factory: '0x67442eB9835688E59f886a884f4E915De5ce93E8',
    flashHelper: '0xc898e8fc8D051cFA2B756438F751086451de1688',
    aavePool: '0x8bAB6d1b75f19e9eD9fCe8b9BD338844fF79aE27',
    uniswapRouter: '0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD',
    weth: '0x4200000000000000000000000000000000000006',
  },
};
```

## Network Configuration

**Add Base Sepolia to MetaMask:**
- Network Name: Base Sepolia
- RPC URL: https://sepolia.base.org
- Chain ID: 84532
- Currency Symbol: ETH
- Block Explorer: https://sepolia.basescan.org

---

## Verification

All contracts compiled with:
- **Solidity**: 0.8.28
- **Optimizer**: Enabled (200 runs)
- **Via IR**: Enabled

Contract sizes (all within limits):
- LoopingFactory: 23,383 bytes ✅
- FlashLoanHelper: 5,622 bytes ✅
- LoopingCallback: 7,956 bytes ✅
- LoopingReactive: 6,277 bytes ✅

---

---

## Gas Comparison: Why Base Sepolia?

| Operation | Ethereum Sepolia | Base Sepolia | Savings |
|-----------|-----------------|--------------|---------|
| Create Position | ~1.5M gas (~$3) | ~1.5M gas (~$0.03) | **99% cheaper** |
| Leverage Loop | ~2M gas (~$4) | ~2M gas (~$0.04) | **99% cheaper** |
| Total Workflow | ~$10 | ~$0.10 | **99% savings** |

**Result**: Full workflow demonstration for under $0.20 instead of $10+

---

**Deployed by**: 0xFCA0157a303d2134854d9cF4718901B6515b0696  
**Network**: Base Sepolia (Chain ID: 84532)  
**Reactive Network**: Kopli Testnet (Chain ID: 5318007)  
**Deployment Date**: December 12, 2024
