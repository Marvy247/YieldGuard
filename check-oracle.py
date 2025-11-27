#!/usr/bin/env python3
"""
Check Chainlink ETH/USD Oracle Status
Compares prices between Ethereum Sepolia and Base Sepolia
"""

import subprocess
import json
from datetime import datetime
from pathlib import Path

# Load environment variables from .env file
env_file = Path(__file__).parent / "Contracts" / ".env"
env_vars = {}

with open(env_file) as f:
    for line in f:
        line = line.strip()
        if line and not line.startswith('#') and '=' in line:
            key, value = line.split('=', 1)
            env_vars[key] = value

# Configuration
ORIGIN_RPC = env_vars.get('ORIGIN_RPC')
DESTINATION_RPC = env_vars.get('DESTINATION_RPC')
REACTIVE_RPC = env_vars.get('REACTIVE_RPC')
ORIGIN_FEED = env_vars.get('ORIGIN_FEED_ADDRESS')
FEED_PROXY = env_vars.get('FEED_PROXY_ADDRESS')
REACTIVE_CONTRACT = env_vars.get('REACTIVE_CONTRACT_ADDRESS')

def cast_call(contract, method, rpc):
    """Call a contract method using cast"""
    cmd = ['cast', 'call', contract, method, f'--rpc-url={rpc}']
    result = subprocess.run(cmd, capture_output=True, text=True, cwd='Contracts')
    return result.stdout.strip()

def cast_balance(address, rpc):
    """Get balance using cast"""
    cmd = ['cast', 'balance', address, f'--rpc-url={rpc}']
    result = subprocess.run(cmd, capture_output=True, text=True, cwd='Contracts')
    return int(result.stdout.strip())

def hex_to_int(hex_str):
    """Convert hex string to integer"""
    if hex_str.startswith('0x'):
        return int(hex_str, 16)
    return int(hex_str)

def decode_latest_round_data(hex_data):
    """Decode latestRoundData() response"""
    # Remove 0x prefix
    if hex_data.startswith('0x'):
        hex_data = hex_data[2:]
    
    # Each value is 32 bytes (64 hex chars)
    round_id = int(hex_data[0:64], 16)
    answer = int(hex_data[64:128], 16)
    started_at = int(hex_data[128:192], 16)
    updated_at = int(hex_data[192:256], 16)
    answered_in_round = int(hex_data[256:320], 16)
    
    return {
        'roundId': round_id,
        'answer': answer,
        'startedAt': started_at,
        'updatedAt': updated_at,
        'answeredInRound': answered_in_round
    }

def format_price(raw_price, decimals=8):
    """Format price with decimals"""
    price = raw_price / (10 ** decimals)
    return f"${price:,.2f}"

def format_timestamp(ts):
    """Format Unix timestamp"""
    if ts == 0:
        return "Never"
    return datetime.fromtimestamp(ts).strftime('%Y-%m-%d %H:%M:%S UTC')

def calculate_deviation(price1, price2):
    """Calculate percentage deviation"""
    if price1 == 0:
        return 0
    return abs(price1 - price2) / price1 * 100

print("=" * 70)
print("CHAINLINK ETH/USD ORACLE STATUS")
print("=" * 70)
print()

# 1. Check Origin Feed (Chainlink on Sepolia)
print("1. ORIGIN CHAIN - Ethereum Sepolia")
print(f"   Address: {ORIGIN_FEED}")
print("-" * 70)

try:
    origin_data = cast_call(ORIGIN_FEED, 'latestRoundData()', ORIGIN_RPC)
    origin_decimals = hex_to_int(cast_call(ORIGIN_FEED, 'decimals()', ORIGIN_RPC))
    
    origin = decode_latest_round_data(origin_data)
    origin_price = origin['answer'] / (10 ** origin_decimals)
    
    print(f"   Description: ETH / USD")
    print(f"   Decimals: {origin_decimals}")
    print(f"   Round ID: {origin['roundId']}")
    print(f"   Price: {format_price(origin['answer'], origin_decimals)}")
    print(f"   Raw Answer: {origin['answer']}")
    print(f"   Last Updated: {format_timestamp(origin['updatedAt'])}")
    
    time_since = int(datetime.now().timestamp()) - origin['updatedAt']
    print(f"   Age: {time_since} seconds ago")
    print()
except Exception as e:
    print(f"   Error: {e}")
    print()

# 2. Check Destination Feed (FeedProxy on Base Sepolia)
print("2. DESTINATION CHAIN - Base Sepolia")
print(f"   Address: {FEED_PROXY}")
print("-" * 70)

try:
    dest_data = cast_call(FEED_PROXY, 'latestRoundData()', DESTINATION_RPC)
    dest_decimals = hex_to_int(cast_call(FEED_PROXY, 'decimals()', DESTINATION_RPC))
    
    dest = decode_latest_round_data(dest_data)
    dest_price = dest['answer'] / (10 ** dest_decimals)
    
    print(f"   Description: ETH / USD (Relayed)")
    print(f"   Decimals: {dest_decimals}")
    print(f"   Round ID: {dest['roundId']}")
    print(f"   Price: {format_price(dest['answer'], dest_decimals)}")
    print(f"   Raw Answer: {dest['answer']}")
    print(f"   Last Updated: {format_timestamp(dest['updatedAt'])}")
    
    time_since = int(datetime.now().timestamp()) - dest['updatedAt']
    print(f"   Age: {time_since} seconds ago")
    print()
except Exception as e:
    print(f"   Error: {e}")
    print()

# 3. Check Reactive Contract
print("3. REACTIVE CONTRACT - Reactive Lasna")
print(f"   Address: {REACTIVE_CONTRACT}")
print("-" * 70)

try:
    balance = cast_balance(REACTIVE_CONTRACT, REACTIVE_RPC) / 1e18
    last_price_hex = cast_call(REACTIVE_CONTRACT, 'lastReportedPrice()', REACTIVE_RPC)
    last_price = hex_to_int(last_price_hex)
    deviation_threshold = hex_to_int(cast_call(REACTIVE_CONTRACT, 'DEVIATION_THRESHOLD_BPS()', REACTIVE_RPC))
    
    print(f"   Balance: {balance:.4f} REACT")
    print(f"   Last Reported Price: {last_price}")
    if last_price > 0:
        print(f"   Last Reported: {format_price(last_price, 8)}")
    else:
        print(f"   Last Reported: Not triggered yet")
    print(f"   Deviation Threshold: {deviation_threshold} BPS ({deviation_threshold/100:.2f}%)")
    
    if balance < 0.1:
        print(f"   Status: ⚠️  LOW BALANCE - Consider refilling")
    else:
        print(f"   Status: ✅ Operational")
    print()
except Exception as e:
    print(f"   Error: {e}")
    print()

# 4. Price Comparison
print("=" * 70)
print("PRICE COMPARISON & ANALYSIS")
print("=" * 70)

try:
    deviation = calculate_deviation(origin_price, dest_price)
    price_diff = origin_price - dest_price
    
    print(f"Origin Price:      {format_price(origin['answer'], origin_decimals)}")
    print(f"Destination Price: {format_price(dest['answer'], dest_decimals)}")
    print(f"Difference:        ${price_diff:,.2f} ({deviation:.2f}%)")
    print()
    
    threshold_pct = deviation_threshold / 100
    if deviation > threshold_pct:
        print(f"⚠️  SIGNIFICANT DEVIATION DETECTED!")
        print(f"   Current: {deviation:.2f}% | Threshold: {threshold_pct:.2f}%")
        print(f"   The oracle should trigger an update when Chainlink next updates.")
    else:
        print(f"✅ Prices are in sync (within {threshold_pct:.2f}% threshold)")
    
    print()
except Exception as e:
    print(f"Error in comparison: {e}")
    print()

print("=" * 70)
print("To trigger an update manually, wait for Chainlink to emit an AnswerUpdated")
print("event, or the cron interval (300 seconds) to elapse.")
print("=" * 70)
