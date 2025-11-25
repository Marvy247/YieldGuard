'use client';

import { createAppKit } from '@reown/appkit/react'
import { WagmiProvider } from 'wagmi'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { WagmiAdapter } from '@reown/appkit-adapter-wagmi'
import { sepolia, baseSepolia } from 'wagmi/chains'
import { lasna } from '../config/reactive'
import { cookieStorage, createStorage } from 'wagmi'

// Get projectId from environment
const projectId = process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID || 'cb44e6bd7a2139350e8c0fb2d0fea8cb'

// Configure chains - Using Reactive Lasna Testnet
const chains = [sepolia, baseSepolia, lasna] as const

// Set up metadata
const metadata = {
  name: 'ReactFeed',
  description: 'Reactive blockchain automation platform',
  url: 'https://reactfeed.xyz',
  icons: ['https://reactfeed.xyz/icon.png']
}

// Create Wagmi adapter
const wagmiAdapter = new WagmiAdapter({
  storage: createStorage({
    storage: cookieStorage
  }),
  ssr: true,
  projectId,
  networks: [...chains]
})

// Create the modal
createAppKit({
  adapters: [wagmiAdapter],
  projectId,
  networks: [...chains],
  defaultNetwork: sepolia,
  metadata,
  features: {
    analytics: true,
    email: false,
    socials: false
  },
  themeMode: 'dark',
  themeVariables: {
    '--w3m-accent': '#10b981',
    '--w3m-border-radius-master': '2px'
  }
})

const queryClient = new QueryClient()

export function Web3Provider({ children }: { children: React.ReactNode }) {
  return (
    <WagmiProvider config={wagmiAdapter.wagmiConfig}>
      <QueryClientProvider client={queryClient}>
        {children}
      </QueryClientProvider>
    </WagmiProvider>
  )
}