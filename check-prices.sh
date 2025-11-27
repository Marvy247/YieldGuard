#!/bin/bash

# Script to check ETH/USD prices from Chainlink Sepolia and Base Sepolia FeedProxy

echo "=== Chainlink ETH/USD Oracle Status ==="
echo ""

# Load environment variables
source Contracts/.env

# Function to convert wei to ether
wei_to_ether() {
    echo "scale=4; $1 / 1000000000000000000" | bc
}

# Function to format price with 8 decimals
format_price() {
    local raw_price=$1
    # Divide by 10^8 to get the actual price
    echo "scale=2; $raw_price / 100000000" | bc
}

# Function to format timestamp
format_time() {
    date -d "@$1" "+%Y-%m-%d %H:%M:%S UTC"
}

echo "1. ORIGIN CHAIN (Ethereum Sepolia)"
echo "   Address: $ORIGIN_FEED_ADDRESS"
echo "   Chain ID: $ORIGIN_CHAIN_ID"
echo ""

# Get origin feed data
ORIGIN_DATA=$(cd Contracts && cast call $ORIGIN_FEED_ADDRESS "latestRoundData()" --rpc-url $ORIGIN_RPC)
ORIGIN_DECIMALS=$(cd Contracts && cast call $ORIGIN_FEED_ADDRESS "decimals()" --rpc-url $ORIGIN_RPC)
ORIGIN_DESC=$(cd Contracts && cast call $ORIGIN_FEED_ADDRESS "description()" --rpc-url $ORIGIN_RPC)

# Parse the data (format: roundId, answer, startedAt, updatedAt, answeredInRound)
ORIGIN_ANSWER=$(echo $ORIGIN_DATA | cut -d' ' -f2)
ORIGIN_UPDATED=$(echo $ORIGIN_DATA | cut -d' ' -f4)

# Convert hex to decimal
ORIGIN_ANSWER_DEC=$(cd Contracts && cast --to-dec $ORIGIN_ANSWER)
ORIGIN_UPDATED_DEC=$(cd Contracts && cast --to-dec $ORIGIN_UPDATED)
ORIGIN_DECIMALS_DEC=$(cd Contracts && cast --to-dec $ORIGIN_DECIMALS)

# Format price
ORIGIN_PRICE=$(format_price $ORIGIN_ANSWER_DEC)

echo "   Description: ETH / USD"
echo "   Decimals: $ORIGIN_DECIMALS_DEC"
echo "   Current Price: \$$ORIGIN_PRICE"
echo "   Raw Answer: $ORIGIN_ANSWER_DEC"
echo "   Last Updated: $(format_time $ORIGIN_UPDATED_DEC)"
echo ""

echo "2. DESTINATION CHAIN (Base Sepolia)"
echo "   Address: $FEED_PROXY_ADDRESS"
echo "   Chain ID: $DESTINATION_CHAIN_ID"
echo ""

# Get destination feed data
DEST_DATA=$(cd Contracts && cast call $FEED_PROXY_ADDRESS "latestRoundData()" --rpc-url $DESTINATION_RPC)
DEST_DECIMALS=$(cd Contracts && cast call $FEED_PROXY_ADDRESS "decimals()" --rpc-url $DESTINATION_RPC)

# Parse the data
DEST_ANSWER=$(echo $DEST_DATA | cut -d' ' -f2)
DEST_UPDATED=$(echo $DEST_DATA | cut -d' ' -f4)

# Convert hex to decimal
DEST_ANSWER_DEC=$(cd Contracts && cast --to-dec $DEST_ANSWER)
DEST_UPDATED_DEC=$(cd Contracts && cast --to-dec $DEST_UPDATED)
DEST_DECIMALS_DEC=$(cd Contracts && cast --to-dec $DEST_DECIMALS)

# Format price
DEST_PRICE=$(format_price $DEST_ANSWER_DEC)

echo "   Description: ETH / USD (Relayed)"
echo "   Decimals: $DEST_DECIMALS_DEC"
echo "   Current Price: \$$DEST_PRICE"
echo "   Raw Answer: $DEST_ANSWER_DEC"
echo "   Last Updated: $(format_time $DEST_UPDATED_DEC)"
echo ""

# Calculate price difference
PRICE_DIFF=$(echo "scale=2; $ORIGIN_PRICE - $DEST_PRICE" | bc)
PRICE_DIFF_PCT=$(echo "scale=2; ($PRICE_DIFF / $ORIGIN_PRICE) * 100" | bc)

echo "3. PRICE COMPARISON"
echo "   Origin Price: \$$ORIGIN_PRICE"
echo "   Destination Price: \$$DEST_PRICE"
echo "   Difference: \$$PRICE_DIFF ($PRICE_DIFF_PCT%)"

if (( $(echo "$PRICE_DIFF_PCT > 0.5" | bc -l) )) || (( $(echo "$PRICE_DIFF_PCT < -0.5" | bc -l) )); then
    echo "   Status: ⚠️  SIGNIFICANT DEVIATION (>0.5%) - Update may be triggered soon"
else
    echo "   Status: ✓ In sync (within 0.5% threshold)"
fi
echo ""

echo "4. REACTIVE CONTRACT (Reactive Lasna)"
echo "   Address: $REACTIVE_CONTRACT_ADDRESS"
echo "   Chain ID: $REACTIVE_CHAIN_ID"
echo ""

# Check reactive contract balance
REACTIVE_BALANCE=$(cd Contracts && cast balance $REACTIVE_CONTRACT_ADDRESS --rpc-url $REACTIVE_RPC)
REACTIVE_BALANCE_ETHER=$(wei_to_ether $REACTIVE_BALANCE)

echo "   Balance: $REACTIVE_BALANCE_ETHER REACT"

if (( $(echo "$REACTIVE_BALANCE_ETHER < 0.1" | bc -l) )); then
    echo "   Status: ⚠️  LOW BALANCE - Consider refilling"
else
    echo "   Status: ✓ Operational"
fi

echo ""
echo "===========================================
"
