'use client';

import { ExternalLink, Copy, CheckCircle } from 'lucide-react';
import { useState } from 'react';
import { CONTRACTS, EXPLORERS } from '@/config/contracts';

export default function ContractsSection() {
  const [copiedAddress, setCopiedAddress] = useState<string | null>(null);

  const handleCopy = async (address: string, label: string) => {
    await navigator.clipboard.writeText(address);
    setCopiedAddress(label);
    setTimeout(() => setCopiedAddress(null), 2000);
  };

  const contracts = [
    {
      name: 'FeedProxy',
      description: 'Stores price data, exposes AggregatorV3Interface for dApps',
      address: CONTRACTS.feedProxy,
      explorer: `${EXPLORERS.baseSepolia}/address/${CONTRACTS.feedProxy}`,
      chain: 'Base Sepolia',
      color: 'blue',
    },
    {
      name: 'OracleCallback',
      description: 'Verifies EIP-712 signatures, updates FeedProxy on destination',
      address: CONTRACTS.oracleCallback,
      explorer: `${EXPLORERS.baseSepolia}/address/${CONTRACTS.oracleCallback}`,
      chain: 'Base Sepolia',
      color: 'blue',
    },
    {
      name: 'OracleReactive',
      description: 'Monitors origin feed, triggers cross-chain callbacks',
      address: CONTRACTS.oracleReactive,
      explorer: `${EXPLORERS.reactive}/address/${CONTRACTS.oracleReactive}`,
      chain: 'Reactive Mainnet',
      color: 'green',
    },
    {
      name: 'Origin Feed',
      description: 'Chainlink ETH/USD aggregator on origin chain',
      address: CONTRACTS.originFeed,
      explorer: `${EXPLORERS.sepolia}/address/${CONTRACTS.originFeed}`,
      chain: 'Ethereum Sepolia',
      color: 'orange',
    },
  ];

  const isDeployed = CONTRACTS.feedProxy !== '0x0000000000000000000000000000000000000000';

  return (
    <section className="py-20 px-6 relative">
      <div className="max-w-7xl mx-auto">
        {/* Section Header */}
        <div className="text-center mb-16">
          <h2 className="text-4xl md:text-5xl font-bold text-white mb-4">
            Contract Addresses
          </h2>
          <p className="text-lg text-slate-400">
            {isDeployed 
              ? 'Verified and deployed on their respective networks'
              : 'Contracts will be displayed here after deployment'}
          </p>
        </div>

        {/* Contracts Grid */}
        <div className="max-w-5xl mx-auto grid grid-cols-1 md:grid-cols-2 gap-6">
          {contracts.map((contract) => {
            const isZeroAddress = contract.address === '0x0000000000000000000000000000000000000000';
            const colorClasses = {
              blue: 'from-blue-500/10 to-blue-600/10 border-blue-500/30',
              green: 'from-green-500/10 to-green-600/10 border-green-500/30',
              orange: 'from-orange-500/10 to-orange-600/10 border-orange-500/30',
            };

            return (
              <div
                key={contract.name}
                className={`bg-gradient-to-br ${colorClasses[contract.color as keyof typeof colorClasses]} border rounded-xl p-6 backdrop-blur-sm`}
              >
                {/* Header */}
                <div className="flex items-start justify-between mb-4">
                  <div>
                    <h3 className="text-xl font-bold text-white mb-1">{contract.name}</h3>
                    <p className="text-xs text-slate-400">{contract.chain}</p>
                  </div>
                  {!isZeroAddress && (
                    <a
                      href={contract.explorer}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="p-2 bg-white/5 hover:bg-white/10 rounded-lg border border-white/10 transition-colors"
                    >
                      <ExternalLink className="w-4 h-4 text-slate-400" />
                    </a>
                  )}
                </div>

                {/* Description */}
                <p className="text-sm text-slate-300 mb-4 leading-relaxed">
                  {contract.description}
                </p>

                {/* Address */}
                <div className="bg-slate-900/50 rounded-lg p-3 border border-white/10">
                  <div className="flex items-center justify-between gap-2">
                    <code className="text-xs font-mono text-slate-300 truncate flex-1">
                      {contract.address}
                    </code>
                    <button
                      onClick={() => handleCopy(contract.address, contract.name)}
                      className="p-1.5 hover:bg-white/10 rounded transition-colors flex-shrink-0"
                      title="Copy address"
                    >
                      {copiedAddress === contract.name ? (
                        <CheckCircle className="w-4 h-4 text-green-400" />
                      ) : (
                        <Copy className="w-4 h-4 text-slate-400" />
                      )}
                    </button>
                  </div>
                </div>

                {/* Status Badge */}
                <div className="mt-3">
                  {isZeroAddress ? (
                    <span className="inline-flex items-center gap-1.5 px-3 py-1 bg-yellow-500/10 border border-yellow-500/20 rounded-full text-xs text-yellow-400">
                      <div className="w-1.5 h-1.5 bg-yellow-400 rounded-full animate-pulse" />
                      Awaiting Deployment
                    </span>
                  ) : (
                    <span className="inline-flex items-center gap-1.5 px-3 py-1 bg-green-500/10 border border-green-500/20 rounded-full text-xs text-green-400">
                      <CheckCircle className="w-3 h-3" />
                      Deployed & Verified
                    </span>
                  )}
                </div>
              </div>
            );
          })}
        </div>

        {/* Integration Code */}
        {isDeployed && (
          <div className="mt-12 max-w-5xl mx-auto">
            <div className="bg-slate-900/50 border border-white/10 rounded-xl p-6">
              <h3 className="text-lg font-bold text-white mb-4">Integration Example</h3>
              <p className="text-sm text-slate-400 mb-4">
                Read price data from your dApp using the standard Chainlink interface:
              </p>
              
              <pre className="bg-slate-950 rounded-lg p-4 overflow-x-auto">
                <code className="text-sm text-green-400 font-mono">
{`import "./IAggregatorV3.sol";

contract MyDeFiApp {
    IAggregatorV3 priceFeed;
    
    constructor() {
        priceFeed = IAggregatorV3(${CONTRACTS.feedProxy});
    }
    
    function getLatestPrice() public view returns (int256) {
        (, int256 answer, , ,) = priceFeed.latestRoundData();
        return answer; // Returns price with 8 decimals
    }
}`}
                </code>
              </pre>
            </div>
          </div>
        )}

        {/* GitHub Link */}
        <div className="mt-12 text-center">
          <a
            href={process.env.NEXT_PUBLIC_GITHUB_URL || '#'}
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-2 px-6 py-3 bg-white/5 hover:bg-white/10 border border-white/10 rounded-lg text-white font-medium transition-all"
          >
            <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
              <path d="M12 2C6.477 2 2 6.477 2 12c0 4.42 2.865 8.17 6.839 9.49.5.092.682-.217.682-.482 0-.237-.008-.866-.013-1.7-2.782.603-3.369-1.34-3.369-1.34-.454-1.156-1.11-1.463-1.11-1.463-.908-.62.069-.608.069-.608 1.003.07 1.531 1.03 1.531 1.03.892 1.529 2.341 1.087 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.11-4.555-4.943 0-1.091.39-1.984 1.029-2.683-.103-.253-.446-1.27.098-2.647 0 0 .84-.269 2.75 1.025A9.578 9.578 0 0112 6.836c.85.004 1.705.114 2.504.336 1.909-1.294 2.747-1.025 2.747-1.025.546 1.377.203 2.394.1 2.647.64.699 1.028 1.592 1.028 2.683 0 3.842-2.339 4.687-4.566 4.935.359.309.678.919.678 1.852 0 1.336-.012 2.415-.012 2.743 0 .267.18.578.688.48C19.138 20.167 22 16.418 22 12c0-5.523-4.477-10-10-10z"/>
            </svg>
            View Source Code on GitHub
            <ExternalLink className="w-4 h-4" />
          </a>
        </div>
      </div>
    </section>
  );
}
