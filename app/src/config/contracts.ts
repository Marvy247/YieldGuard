// Contract addresses - update after deployment
export const CONTRACTS = {
  feedProxy: (process.env.NEXT_PUBLIC_FEED_PROXY_ADDRESS || '0x0000000000000000000000000000000000000000') as `0x${string}`,
  oracleCallback: (process.env.NEXT_PUBLIC_ORACLE_CALLBACK_ADDRESS || '0x0000000000000000000000000000000000000000') as `0x${string}`,
  oracleReactive: (process.env.NEXT_PUBLIC_ORACLE_REACTIVE_ADDRESS || '0x0000000000000000000000000000000000000000') as `0x${string}`,
  originFeed: (process.env.NEXT_PUBLIC_ORIGIN_FEED_ADDRESS || '0x694AA1769357215DE4FAC081bf1f309aDC325306') as `0x${string}`,
} as const;

export const CHAIN_IDS = {
  origin: Number(process.env.NEXT_PUBLIC_ORIGIN_CHAIN_ID) || 11155111, // Sepolia
  destination: Number(process.env.NEXT_PUBLIC_DESTINATION_CHAIN_ID) || 84532, // Base Sepolia
  reactive: Number(process.env.NEXT_PUBLIC_REACTIVE_CHAIN_ID) || 5318007, // Reactive Lasna
} as const;

export const EXPLORERS = {
  sepolia: process.env.NEXT_PUBLIC_SEPOLIA_EXPLORER || 'https://sepolia.etherscan.io',
  baseSepolia: process.env.NEXT_PUBLIC_BASE_SEPOLIA_EXPLORER || 'https://sepolia.basescan.org',
  reactive: process.env.NEXT_PUBLIC_REACTIVE_EXPLORER || 'https://kopli.reactscan.net',
} as const;

// AggregatorV3Interface ABI
export const AGGREGATOR_V3_ABI = [
  {
    inputs: [],
    name: 'decimals',
    outputs: [{ internalType: 'uint8', name: '', type: 'uint8' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'description',
    outputs: [{ internalType: 'string', name: '', type: 'string' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'version',
    outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'latestRoundData',
    outputs: [
      { internalType: 'uint80', name: 'roundId', type: 'uint80' },
      { internalType: 'int256', name: 'answer', type: 'int256' },
      { internalType: 'uint256', name: 'startedAt', type: 'uint256' },
      { internalType: 'uint256', name: 'updatedAt', type: 'uint256' },
      { internalType: 'uint80', name: 'answeredInRound', type: 'uint80' },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [{ internalType: 'uint80', name: '_roundId', type: 'uint80' }],
    name: 'getRoundData',
    outputs: [
      { internalType: 'uint80', name: 'roundId', type: 'uint80' },
      { internalType: 'int256', name: 'answer', type: 'int256' },
      { internalType: 'uint256', name: 'startedAt', type: 'uint256' },
      { internalType: 'uint256', name: 'updatedAt', type: 'uint256' },
      { internalType: 'uint80', name: 'answeredInRound', type: 'uint80' },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    anonymous: false,
    inputs: [
      { indexed: true, internalType: 'uint80', name: 'roundId', type: 'uint80' },
      { indexed: false, internalType: 'int256', name: 'answer', type: 'int256' },
      { indexed: false, internalType: 'uint256', name: 'updatedAt', type: 'uint256' },
      { indexed: true, internalType: 'address', name: 'updater', type: 'address' },
    ],
    name: 'RoundUpdated',
    type: 'event',
  },
] as const;

export const FEED_PROXY_ABI = [
  ...AGGREGATOR_V3_ABI,
  {
    inputs: [],
    name: 'latestRound',
    outputs: [{ internalType: 'uint80', name: '', type: 'uint80' }],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'paused',
    outputs: [{ internalType: 'bool', name: '', type: 'bool' }],
    stateMutability: 'view',
    type: 'function',
  },
] as const;
