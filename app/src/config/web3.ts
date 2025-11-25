import { cookieStorage, createStorage, http } from 'wagmi'
import { sepolia, baseSepolia } from 'wagmi/chains'
import { WagmiAdapter } from '@reown/appkit-adapter-wagmi'
import { lasna } from './reactive';

// Get projectId from environment
export const projectId = process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID || 'cb44e6bd7a2139350e8c0fb2d0fea8cb'

if (!projectId) {
  throw new Error('NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID is not set')
}

// Configure chains - Using Reactive Lasna Testnet
export const chains = [sepolia, baseSepolia, lasna] as const

// Create Wagmi adapter for Reown AppKit
export const wagmiAdapter = new WagmiAdapter({
  storage: createStorage({
    storage: cookieStorage
  }),
  ssr: true,
  projectId,
  networks: [...chains]
})

export const config = wagmiAdapter.wagmiConfig