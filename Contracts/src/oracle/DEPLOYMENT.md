# Deployment Runbook

This guide walks through deploying the Cross-Chain Price Feed Oracle from scratch.

## Prerequisites

### 1. Install Foundry

```bash
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc
foundryup
```

### 2. Clone Repository

```bash
git clone https://github.com/YourRepo/reactive-oracle
cd reactive-oracle/Contracts
```

### 3. Install Dependencies

```bash
forge install
```

### 4. Setup Environment

Copy the example environment file:
```bash
cp .env.example .env
```

Fill in the following values in `.env`:

#### Required Values to Update:

```bash
# Your private keys (KEEP SECURE!)
PRIVATE_KEY=0xYOUR_DESTINATION_CHAIN_PRIVATE_KEY
REACTIVE_PRIVATE_KEY=0xYOUR_REACTIVE_NETWORK_PRIVATE_KEY

# RPC endpoints (use your own or public)
ORIGIN_RPC=https://sepolia.infura.io/v3/YOUR_INFURA_KEY
DESTINATION_RPC=https://sepolia.base.org
REACTIVE_RPC=https://mainnet-rpc.rnk.dev/

# Get this from Reactive docs
CALLBACK_PROXY_ADDR=0xYOUR_CALLBACK_PROXY_ADDRESS
```

#### Pre-configured Values (can be customized):

```bash
ORIGIN_CHAIN_ID=11155111                                    # Sepolia
DESTINATION_CHAIN_ID=84532                                  # Base Sepolia
ORIGIN_FEED_ADDRESS=0x694AA1769357215DE4FAC081bf1f309aDC325306  # ETH/USD Sepolia
FEED_DECIMALS=8
FEED_DESCRIPTION="ETH / USD"
STALENESS_THRESHOLD=3600                                    # 1 hour
DEVIATION_THRESHOLD_BPS=50                                  # 0.5%
CRON_INTERVAL=300                                           # 5 minutes
INITIAL_FUNDING=2000000000000000000                         # 2 REACT
```

## Deployment Steps

### Phase 1: Destination Chain Deployment

Deploy FeedProxy and OracleCallback on the destination chain (e.g., Base Sepolia).

```bash
forge script script/DeployOracle.s.sol:DeployOracle \
  --rpc-url $DESTINATION_RPC \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  -vvvv
```

**Expected Output:**
```
== Logs ==
Deploying FeedProxy on destination chain...
FeedProxy deployed at: 0xABC123...
Deploying OracleCallback on destination chain...
OracleCallback deployed at: 0xDEF456...
FeedProxy callback proxy updated

=== Deployment Summary ===
FeedProxy: 0xABC123...
OracleCallback: 0xDEF456...

Now deploy OracleReactive on Reactive Network with callback address: 0xDEF456...
```

**Action**: Copy the `OracleCallback` address (0xDEF456...).

### Phase 2: Update Environment

Add the callback address to your `.env`:

```bash
echo "CALLBACK_CONTRACT_ADDRESS=0xDEF456..." >> .env
```

Reload environment:
```bash
source .env
```

### Phase 3: Reactive Network Deployment

Deploy OracleReactive on Reactive Network.

**Important**: Make sure your Reactive wallet has at least 2 REACT tokens.

```bash
forge script script/DeployOracle.s.sol:DeployReactive \
  --rpc-url $REACTIVE_RPC \
  --private-key $REACTIVE_PRIVATE_KEY \
  --broadcast \
  -vvvv
```

**Expected Output:**
```
== Logs ==
Deploying OracleReactive on Reactive Network...
OracleReactive deployed at: 0xGHI789...
Initial funding: 2000000000000000000
Monitoring origin feed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
Sending updates to callback: 0xDEF456...

=== Reactive Deployment Summary ===
OracleReactive: 0xGHI789...
```

**Action**: Copy the `OracleReactive` address (0xGHI789...).

### Phase 4: Verify Deployment

#### 1. Check Subscriptions

Verify that OracleReactive subscribed to events:

```bash
# Check if contract has balance
cast balance 0xGHI789... --rpc-url $REACTIVE_RPC

# Verify subscription status (if Reactive provides a method)
cast call 0xGHI789... "service()" --rpc-url $REACTIVE_RPC
```

#### 2. Check FeedProxy

Verify FeedProxy configuration:

```bash
cast call 0xABC123... "decimals()" --rpc-url $DESTINATION_RPC
# Expected: 8

cast call 0xABC123... "description()" --rpc-url $DESTINATION_RPC
# Expected: "ETH / USD"

cast call 0xABC123... "callbackProxy()" --rpc-url $DESTINATION_RPC
# Expected: 0xDEF456...

cast call 0xABC123... "owner()" --rpc-url $DESTINATION_RPC
# Expected: Your address
```

#### 3. Check OracleCallback

Verify callback configuration:

```bash
cast call 0xDEF456... "feedProxy()" --rpc-url $DESTINATION_RPC
# Expected: 0xABC123...

cast call 0xDEF456... "ORIGIN_FEED_ADDRESS()" --rpc-url $DESTINATION_RPC
# Expected: 0x694AA1769357215DE4FAC081bf1f309aDC325306
```

### Phase 5: Test End-to-End Flow

#### Option A: Wait for Natural Update

Wait for the Chainlink feed on Sepolia to update (usually every few minutes during volatility).

Monitor the FeedProxy:
```bash
watch -n 10 'cast call 0xABC123... "latestRoundData()" --rpc-url $DESTINATION_RPC'
```

#### Option B: Trigger Manual Update (Advanced)

If you control a test Chainlink aggregator, trigger an update and watch the propagation.

### Phase 6: Monitor Events

#### Watch Origin Feed

```bash
cast logs \
  --address 0x694AA1769357215DE4FAC081bf1f309aDC325306 \
  --rpc-url $ORIGIN_RPC \
  --from-block latest
```

#### Watch Destination Proxy

```bash
cast logs \
  --address 0xABC123... \
  --rpc-url $DESTINATION_RPC \
  --from-block latest
```

Look for `RoundUpdated` events.

## Troubleshooting

### Issue: No updates appearing

**Checks**:
1. Verify Reactive contract has REACT balance:
   ```bash
   cast balance 0xGHI789... --rpc-url $REACTIVE_RPC
   ```
   If low, send more REACT.

2. Check if origin feed is updating:
   ```bash
   cast call 0x694AA1769357215DE4FAC081bf1f309aDC325306 \
     "latestRoundData()" \
     --rpc-url $ORIGIN_RPC
   ```

3. Verify price deviation exceeds threshold (0.5% by default).

### Issue: Circuit breaker triggered

**Check events**:
```bash
cast logs --address 0xABC123... \
  --rpc-url $DESTINATION_RPC | grep CircuitBreakerTriggered
```

**Resolution**:
1. Investigate price anomaly on origin chain
2. If legitimate, unpause:
   ```bash
   cast send 0xABC123... "setPaused(bool)" false \
     --private-key $PRIVATE_KEY \
     --rpc-url $DESTINATION_RPC
   ```

### Issue: Transaction reverts

**Debug**:
```bash
# Simulate the transaction
cast call <contract> <function> <args> \
  --from YOUR_ADDRESS \
  --rpc-url $RPC_URL
```

Check error messages for:
- `Unauthorized`: Wrong sender
- `StaleData`: Update too old
- `InvalidRoundId`: Non-monotonic round
- `PriceDeviationTooHigh`: Circuit breaker

## Maintenance

### Refill Reactive Contract

When balance drops below 0.5 REACT:

```bash
cast send 0xGHI789... \
  --value 1ether \
  --private-key $REACTIVE_PRIVATE_KEY \
  --rpc-url $REACTIVE_RPC
```

### Update Callback Proxy

If Reactive updates their callback proxy:

```bash
cast send 0xABC123... "updateCallbackProxy(address)" NEW_PROXY \
  --private-key $PRIVATE_KEY \
  --rpc-url $DESTINATION_RPC
```

### Emergency Pause

If issues detected:

```bash
cast send 0xABC123... "setPaused(bool)" true \
  --private-key $PRIVATE_KEY \
  --rpc-url $DESTINATION_RPC
```

## Integration for dApps

Your dApp can now read prices:

```solidity
import "./IAggregatorV3.sol";

contract MyDeFiApp {
    IAggregatorV3 priceFeed;
    
    constructor(address feedProxyAddress) {
        priceFeed = IAggregatorV3(feedProxyAddress);
    }
    
    function getLatestPrice() public view returns (int256) {
        (
            ,
            int256 answer,
            ,
            ,
            
        ) = priceFeed.latestRoundData();
        return answer; // Returns price with 8 decimals
    }
}
```

Deploy your dApp with:
```
FEED_PROXY_ADDRESS=0xABC123...  # From Phase 1
```

## Verification

### Contract Verification

If `--verify` fails during deployment, manually verify:

```bash
forge verify-contract \
  --chain-id $DESTINATION_CHAIN_ID \
  --compiler-version v0.8.13+commit.abaa5c0e \
  0xABC123... \
  src/oracle/FeedProxy.sol:FeedProxy \
  --constructor-args $(cast abi-encode "constructor(uint8,string,address,uint256)" 8 "ETH / USD" 0xCALLBACK... 3600)
```

## Cost Estimates

### Initial Deployment

- FeedProxy: ~1.2M gas (~$0.50 on Base Sepolia)
- OracleCallback: ~1.5M gas (~$0.60 on Base Sepolia)
- OracleReactive: ~2M gas + 2 REACT (~$4 equivalent)

**Total**: ~$6 one-time

### Ongoing Costs

- Per update (destination): ~165k gas (~$0.10 on Base Sepolia)
- Daily updates (50/day at 0.5% threshold): ~$5/day
- Reactive Network: Covered by initial 2 REACT (lasts ~1 week, then refill)

**Monthly estimate**: ~$200 (cheaper than running a centralized bot + infrastructure)

## Next Steps

1. Monitor for 24 hours to ensure stability
2. Integrate into your dApp
3. Set up monitoring alerts (optional: use The Graph)
4. Consider multi-sig for owner functions (production)
5. Submit for Reactive Bounty #1 prize! 🏆

---

**Questions?** Join Reactive Telegram: https://t.me/reactivedevs
