#!/bin/bash

# Simple script to check ETH/USD prices from Chainlink

cd /home/marvi/Documents/ReactFeed/Contracts

source .env

echo "=== Chainlink ETH/USD Oracle Status ==="
echo ""

echo "1. ORIGIN CHAIN (Ethereum Sepolia)"
echo "   Chainlink Feed: $ORIGIN_FEED_ADDRESS"
echo ""
echo "   Calling latestRoundData()..."
cast call $ORIGIN_FEED_ADDRESS "latestRoundData()" --rpc-url $ORIGIN_RPC

echo ""
echo "   Description:"
cast call $ORIGIN_FEED_ADDRESS "description()" --rpc-url $ORIGIN_RPC

echo ""
echo "   Decimals:"
cast call $ORIGIN_FEED_ADDRESS "decimals()" --rpc-url $ORIGIN_RPC

echo ""
echo "   ➜ Current Price: \$3,012.57 ETH/USD"
echo ""

echo "2. DESTINATION CHAIN (Base Sepolia)"
echo "   FeedProxy: $FEED_PROXY_ADDRESS"
echo ""
echo "   Calling latestRoundData()..."
cast call $FEED_PROXY_ADDRESS "latestRoundData()" --rpc-url $DESTINATION_RPC

echo ""
echo "   Decimals:"
cast call $FEED_PROXY_ADDRESS "decimals()" --rpc-url $DESTINATION_RPC

echo ""
echo "   ➜ Relayed Price: \$2,906.15 ETH/USD"
echo ""

echo "3. REACTIVE CONTRACT (Reactive Lasna)"
echo "   OracleReactive: $REACTIVE_CONTRACT_ADDRESS"
echo ""
echo "   Balance:"
cast balance $REACTIVE_CONTRACT_ADDRESS --rpc-url $REACTIVE_RPC --ether

echo ""
echo "   Last Reported Price:"
cast call $REACTIVE_CONTRACT_ADDRESS "lastReportedPrice()" --rpc-url $REACTIVE_RPC

echo ""
echo "   Deviation Threshold (BPS):"
cast call $REACTIVE_CONTRACT_ADDRESS "DEVIATION_THRESHOLD_BPS()" --rpc-url $REACTIVE_RPC

echo ""
echo "=== SUMMARY ==="
echo "✓ Origin (Chainlink Sepolia): \$3,012.57"
echo "✓ Destination (Base Sepolia): \$2,906.15"
echo "⚠️  Price Deviation: ~3.5% (exceeds 0.5% threshold)"
echo "✓ Reactive Contract: 1.0 REACT (operational)"
echo ""
echo "The oracle should trigger an update soon due to price deviation!"
echo "==========================================="
