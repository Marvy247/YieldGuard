// Looping Protocol Configuration
// Deployed: December 12, 2024
// Network: Base Sepolia (L2 Testnet)
// Factory: 0x67442eB9835688E59f886a884f4E915De5ce93E8
// Why Base Sepolia: 99% cheaper gas fees than Ethereum Sepolia

export const LOOPING_ADDRESSES = {
  // Base Sepolia Testnet (L2) - 99% cheaper gas!
  84532: {
    factory: '0x67442eB9835688E59f886a884f4E915De5ce93E8' as `0x${string}`, // ✅ DEPLOYED
    flashHelper: '0xc898e8fc8D051cFA2B756438F751086451de1688' as `0x${string}`, // ✅ DEPLOYED
    aavePool: '0x8bAB6d1b75f19e9eD9fCe8b9BD338844fF79aE27' as `0x${string}`,
    uniswapRouter: '0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD' as `0x${string}`,
  },
} as const;

export const SUPPORTED_ASSETS = {
  84532: {
    WETH: {
      address: '0x4200000000000000000000000000000000000006' as `0x${string}`,
      symbol: 'WETH',
      decimals: 18,
      icon: '⟠',
    },
    USDC: {
      address: '0xba50Cd2A20f6DA35D788639E581bca8d0B5d4D5f' as `0x${string}`,
      symbol: 'USDC',
      decimals: 6,
      icon: '💵',
    },
    USDT: {
      address: '0x0a215D8ba66387DCA84B284D18c3B4ec3de6E54a' as `0x${string}`,
      symbol: 'USDT',
      decimals: 6,
      icon: '💚',
    },
  },
} as const;

export const LOOPING_CONSTANTS = {
  MIN_HEALTH_FACTOR: 1.1,
  SAFE_HEALTH_FACTOR: 3.0,
  WARNING_HEALTH_FACTOR: 2.0,
  DANGER_HEALTH_FACTOR: 1.5,
  MAX_LTV: 8000, // 80%
  DEFAULT_LTV: 7000, // 70%
  DEFAULT_SLIPPAGE: 300, // 3%
  MAX_SLIPPAGE: 1000, // 10%
  MAX_LOOPS: 5,
};

export const HEALTH_FACTOR_ZONES = {
  SAFE: { min: 3.0, color: 'green', label: '🟢 Safe', description: 'Your position is healthy' },
  WARNING: { min: 1.5, max: 3.0, color: 'yellow', label: '🟡 Warning', description: 'Monitor your position' },
  DANGER: { min: 1.1, max: 1.5, color: 'red', label: '🔴 Danger', description: 'Risk of liquidation' },
  CRITICAL: { max: 1.1, color: 'red', label: '⚠️ Critical', description: 'Immediate action required' },
};

export function getHealthFactorZone(healthFactor: number) {
  if (healthFactor >= HEALTH_FACTOR_ZONES.SAFE.min) return HEALTH_FACTOR_ZONES.SAFE;
  if (healthFactor >= HEALTH_FACTOR_ZONES.WARNING.min) return HEALTH_FACTOR_ZONES.WARNING;
  if (healthFactor >= HEALTH_FACTOR_ZONES.DANGER.min) return HEALTH_FACTOR_ZONES.DANGER;
  return HEALTH_FACTOR_ZONES.CRITICAL;
}

export function formatHealthFactor(hf: bigint): string {
  const hfNumber = Number(hf) / 1e18;
  if (hfNumber > 10) return '>10.0';
  return hfNumber.toFixed(2);
}

export function formatLTV(ltv: bigint): string {
  const ltvNumber = Number(ltv) / 100;
  return ltvNumber.toFixed(2) + '%';
}

export function calculateLeverage(collateral: bigint, debt: bigint): number {
  if (collateral === BigInt(0)) return 1;
  const leverage = Number(collateral) / Number(collateral - debt);
  return Math.max(1, leverage);
}
