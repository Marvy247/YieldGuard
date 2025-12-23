# YieldGuard Demo Video Script
**Target Duration: 4-5 minutes**

---

##Video Structure

### Scene 1: Opening Hook (0:00 - 0:30)
**Screen**: Title slide or code editor showing the main contracts

**Script**:
> "Hi! I'm presenting YieldGuard - an autonomous yield optimization vault built for the Reactive Network Bounty #3. Unlike traditional yield aggregators that rely on expensive bots, YieldGuard uses Reactive Smart Contracts to maximize returns 24/7 with ZERO infrastructure costs. Let me show you how it works."

**Visuals**: 
- Show quick animation or diagram of the system
- Or just your IDE with the main contracts visible

---

### Scene 2: The Problem (0:30 - 1:00)
**Screen**: Diagram or slides showing the problem

**Script**:
> "Here's the problem we're solving: DeFi yields constantly change across protocols. Users either monitor manually - which is tedious - or pay $50-100 per month for bot services. These bots have downtime, latency, and are centralized. Plus, they don't account for gas costs or pool risks."
>
> "YieldGuard solves this by leveraging Reactive Network's event-driven architecture to create truly autonomous, gas-aware optimization."

**Visuals to Show**:
1. Screenshot of different lending protocols with changing APYs
2. Diagram showing centralized bot architecture vs YieldGuard
3. Quick comparison table (Traditional vs YieldGuard)

---

### Scene 3: Architecture Overview (1:00 - 2:00)
**Screen**: Architecture diagram + deployed contracts

**Script**:
> "Let's look at the architecture. YieldGuard consists of three main components:"
>
> "First, the YieldVault on Base Sepolia - an ERC-4626 compliant tokenized vault. Users deposit once and get vault shares. The vault manages funds across THREE lending pools - that's one more than the requirement. We have Pool 1 at 5% APY, Pool 2 at 7%, and Pool 3 at 4% but with high risk."
>
> [Show contract address on BaseScan]
>
> "Second, the RebalanceStrategy - this is the brain. It calculates risk-adjusted yields, factors in gas costs, and only triggers rebalancing when it's profitable. For example, Pool 3 has 85% utilization, so we apply a 20% risk penalty, reducing its effective yield from 4% to 3.2%."
>
> [Show strategy contract code]
>
> "Third, the ReactiveRebalancer on Reactive Lasna - this is the guardian. It monitors all three pools 24/7 through six event subscriptions. When rates change, it automatically evaluates and triggers rebalancing."
>
> [Show ReactiveRebalancer on ReactScan]

**Visuals to Show**:
1. Architecture diagram (from the docs)
2. BaseScan showing YieldVault: `0x0768ae0974f29c9925E927a1f63d8C72937e3A6A`
3. ReactScan showing ReactiveRebalancer: `0x313929901Ba9271F71aC38B6142f39BdcCC60921`
4. Code snippet of risk adjustment calculation

---

### Scene 4: Live Demonstration (2:00 - 3:30)
**Screen**: Block explorers showing actual transactions

**Script**:
> "Now let's walk through the actual deployed system. Here are the transaction hashes proving the complete workflow:"
>
> "Step 1: We deployed the vault system on Base Sepolia. Here's the vault contract."
> [Show vault on BaseScan]
>
> "Step 2: We deployed ReactiveRebalancer to Reactive Lasna. You can see it's actively monitoring."
> [Show on ReactScan: https://lasna.reactscan.net/address/0x313929901Ba9271F71aC38B6142f39BdcCC60921]
>
> "Step 3: We linked them together. Here's the transaction setting the rebalancer address."
> [Show tx: 0xe389e7507763ed751ad465307956e96a405f093fc4605bfc394b8041b3ea6dc9]
>
> "Step 4: We activated subscriptions. This transaction created 6 event listeners - 2 per pool. The ReactiveRebalancer is now listening to every rate change."
> [Show tx: 0x7ce80aae73fdbabc3e6ba5921ec5bdc42061d6d8065d02f178c04f9f83947222]
>
> "Step 5: User deposits 1,000 USDC. Here's the deposit transaction."
> [Show tx: 0x1b61ee45b288f97f0b5f73b3f2e2304d19bf8788b49536f3e65ee2f1bd5e001a]
>
> "Now the system is live. When Pool 2's rate increases from 7% to 9%, the ReactiveRebalancer automatically detects it, calculates that moving funds is profitable after gas costs, and triggers the rebalancing - all without any user intervention."

**Visuals to Show**:
1. BaseScan with vault contract open
2. ReactScan with ReactiveRebalancer contract
3. Each transaction hash on the respective explorer
4. Zoom in on important fields (status: success, gas used, etc.)

---

### Scene 5: Key Innovations (3:30 - 4:15)
**Screen**: Code editor showing key functions

**Script**:
> "What makes YieldGuard special? Three innovations:"
>
> "First, Gas-Aware Decisions. We calculate: daily profit minus gas cost. Only if positive do we rebalance. Here's the code."
> [Show RebalanceStrategy.sol profit calculation function]
>
> "Second, Risk-Adjusted Yield. High utilization pools get penalized. Pool 3 at 85% utilization? We reduce its yield by 20% to avoid liquidity traps."
> [Show risk adjustment code]
>
> "Third, Safety Limits. Maximum 50% allocation per pool, one-hour cooldown between rebalances, and emergency pause mechanism."
> [Show relevant code or mention in vault]

**Visuals to Show**:
1. Code snippet: `_estimateProfit()` function in RebalanceStrategy.sol
2. Code snippet: `_calculateRiskAdjustedRate()` function
3. Code snippet: MAX_ALLOCATION_PER_POOL constant

---

### Scene 6: Testing & Quality (4:15 - 4:45)
**Screen**: Terminal showing test results

**Script**:
> "Quality matters. All 13 tests are passing, covering ERC-4626 compliance, multi-pool management, risk adjustment, and edge cases."
>
> [Show test output]
>
> "The code is production-ready with security features like concentration limits, risk penalties, and emergency controls. It's also ERC-4626 compliant, meaning it's composable with the entire DeFi ecosystem."

**Visuals to Show**:
1. Terminal with `forge test` output showing 13/13 passing
2. Quick scroll through test file showing test names
3. Coverage report if available

---

### Scene 7: Closing & Call to Action (4:45 - 5:00)
**Screen**: Summary slide or back to title

**Script**:
> "YieldGuard demonstrates the true power of Reactive Network - autonomous, decentralized optimization that was impossible before. It's production-ready, thoroughly tested, and solves a real problem in DeFi."
>
> "All code, documentation, and deployment details are in the repository. Thank you for watching!"

**Visuals to Show**:
- Final slide with:
  - Project name: YieldGuard
  - Your name/team: ReactFeed
  - GitHub repo link
  - Key stats: 3 pools, 13/13 tests, 6 event subscriptions

---

##Production Tips

### Recording Setup

1. **Tool**: Use OBS Studio (free) or Loom
2. **Resolution**: 1920x1080 (1080p)
3. **Frame Rate**: 30fps minimum
4. **Audio**: Clear microphone, no background noise
5. **Screen**: Close unnecessary tabs/apps

### Visual Preparation

**Have These Open Before Recording**:
1. **Tab 1**: Architecture diagram (create in draw.io or similar)
2. **Tab 2**: BaseScan with vault contract
3. **Tab 3**: ReactScan with ReactiveRebalancer
4. **Tab 4**: Transaction 1 on BaseScan (link tx)
5. **Tab 5**: Transaction 2 on ReactScan (activate subscriptions)
6. **Tab 6**: Transaction 3 on BaseScan (deposit)
7. **Tab 7**: VS Code with RebalanceStrategy.sol open
8. **Tab 8**: Terminal with test results
9. **Tab 9**: README.md or summary slide

**Optional Slides to Create**:
1. Title slide: "YieldGuard - Autonomous Yield Optimization"
2. Problem statement (bullet points)
3. Architecture diagram
4. Key innovations (3 points)
5. Results summary
6. Closing slide with links

### Recording Flow

```
1. Start with title slide (5 sec)
2. Introduce yourself and project (25 sec)
3. Explain problem (30 sec)
4. Show architecture diagram (20 sec)
5. Switch to BaseScan, show vault (15 sec)
6. Switch to ReactScan, show rebalancer (15 sec)
7. Show each transaction hash briefly (30 sec)
8. Switch to VS Code, show code (45 sec)
9. Show terminal with tests (30 sec)
10. Back to closing slide (15 sec)
```

### Voice Over Tips

- **Pace**: Speak clearly, not too fast
- **Energy**: Be enthusiastic but professional
- **Pauses**: Brief pause between major points
- **Practice**: Do 2-3 dry runs before final recording
- **Editing**: Cut out "umm", long pauses, mistakes

### Visual Enhancements

**Use Simple Animations**:
- Circle or highlight important addresses
- Zoom in on key code sections
- Arrow annotations pointing to important fields
- Text overlays for emphasis

**Color Coding**:
- Green checkmarksfor successful transactions
- Red for problems being solved
- Blue for key innovations

---

##Alternative: Slide-Heavy Approach

If you're not comfortable with live screen recording, you can do a slide-based presentation:

### Slide 1: Title
- Project name
- Your name
- Bounty #3

### Slide 2: Problem
- Bullets: Manual monitoring, Expensive bots, Centralized, Delayed

### Slide 3: Solution
- YieldGuard overview
- "Autonomous, Decentralized, Gas-Aware"

### Slide 4: Architecture
- Diagram showing vault, pools, reactive contract

### Slide 5: Deployed Contracts
- Table with contract names, addresses, explorers

### Slide 6: Workflow
- 6 steps with transaction hashes

### Slide 7: Innovation 1 - Gas Aware
- Code snippet or formula

### Slide 8: Innovation 2 - Risk Adjusted
- Code snippet or formula

### Slide 9: Innovation 3 - Safety
- Bullet points of safety features

### Slide 10: Testing
- Screenshot of passing tests

### Slide 11: Impact
- What this enables for users

### Slide 12: Thank You
- Links to code, docs, contacts

---

##What Judges Want to See

According to the bounty requirements, judges evaluate:

1.**Meaningful use of Reactive Contracts** 
   - Show the ReactiveRebalancer actively monitoring
   - Emphasize 6 event subscriptions

2.**Code quality**
   - Show the clean architecture
   - Mention ERC-4626 compliance
   - Show passing tests

3.**Correctness & edge cases**
   - Mention risk adjustment for high utilization
   - Show gas profitability checks

4.**Security**
   - Highlight max allocation limits
   - Mention emergency pause
   - Show cooldown periods

5.**Operational maturity**
   - Show deployment scripts exist
   - Mention comprehensive tests
   - Show actual deployed contracts working

**Make sure to hit all these points in your video!**

---

##Quick Script Template

If you want a minimal version:

```
[0:00-0:15] 
"Hi, I'm [name] presenting YieldGuard for Bounty #3. 
It's an autonomous yield vault using Reactive Contracts."

[0:15-0:45]
"The problem: DeFi yields constantly change. Users need 
expensive bots. YieldGuard automates this with Reactive Network."

[0:45-1:30]
"Architecture: ERC-4626 vault on Base Sepolia, 3 lending pools,
ReactiveRebalancer on Lasna monitoring 24/7. Here's the vault..."
[show BaseScan]

[1:30-2:30]
"Live deployment: Vault at 0x076..., Rebalancer at 0x313...
Here are the transaction hashes proving the complete workflow..."
[show each tx]

[2:30-3:30]
"Key innovations: Gas-aware rebalancing, risk-adjusted yields,
and safety limits. Here's the code..."
[show code snippets]

[3:30-4:15]
"All 13 tests passing. Production-ready. ERC-4626 compliant."
[show tests]

[4:15-4:30]
"YieldGuard shows the power of Reactive Network. Thanks!"
```

---

##Quick Links for Video

**Explorers to Show**:
- Vault: https://sepolia.basescan.org/address/0x0768ae0974f29c9925E927a1f63d8C72937e3A6A
- ReactiveRebalancer: https://lasna.reactscan.net/address/0x313929901Ba9271F71aC38B6142f39BdcCC60921
- Link Tx: https://sepolia.basescan.org/tx/0xe389e7507763ed751ad465307956e96a405f093fc4605bfc394b8041b3ea6dc9
- Activate Tx: https://lasna.reactscan.net/tx/0x7ce80aae73fdbabc3e6ba5921ec5bdc42061d6d8065d02f178c04f9f83947222
- Deposit Tx: https://sepolia.basescan.org/tx/0x1b61ee45b288f97f0b5f73b3f2e2304d19bf8788b49536f3e65ee2f1bd5e001a

**Code to Show**:
- `src/vault/YieldVault.sol` (lines 269-293: rebalance function)
- `src/vault/RebalanceStrategy.sol` (lines 91-147: shouldRebalance function)
- `src/vault/ReactiveRebalancer.sol` (lines 144-149: react function)

---

##Final Tips

1. **Keep it under 5 minutes** - judges are busy
2. **Show, don't just tell** - actual contracts, not just slides
3. **Highlight Reactive Network usage** - that's what they care about
4. **Be confident** - you built something impressive!
5. **Edit out mistakes** - doesn't need to be one take
6. **Add captions** - helps if audio isn't perfect

**Good luck with your video!**
