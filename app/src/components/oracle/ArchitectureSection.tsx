'use client';

import { Database, Zap, Shield, ArrowRight } from 'lucide-react';

export default function ArchitectureSection() {
  return (
    <section id="architecture" className="py-20 px-6 relative">
      <div className="max-w-7xl mx-auto">
        {/* Section Header */}
        <div className="text-center mb-16">
          <h2 className="text-4xl md:text-5xl font-bold text-white mb-4">
            How It Works
          </h2>
          <p className="text-lg text-slate-400 max-w-2xl mx-auto">
            Three-layer architecture powered by Reactive Contracts for autonomous cross-chain price relay
          </p>
        </div>

        {/* Architecture Diagram */}
        <div className="relative max-w-5xl mx-auto">
          {/* Connection Lines */}
          <div className="absolute top-1/2 left-0 right-0 h-0.5 bg-gradient-to-r from-orange-500 via-green-500 to-blue-500 -translate-y-1/2 hidden md:block" />
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8 relative">
            {/* Origin Chain */}
            <div className="relative">
              <div className="bg-gradient-to-br from-orange-500/10 to-orange-600/10 border border-orange-500/30 rounded-2xl p-6 backdrop-blur-sm">
                <div className="flex items-center gap-3 mb-4">
                  <div className="w-12 h-12 bg-orange-500/20 rounded-lg flex items-center justify-center">
                    <Database className="w-6 h-6 text-orange-400" />
                  </div>
                  <div>
                    <h3 className="text-lg font-bold text-white">Origin Chain</h3>
                    <p className="text-sm text-slate-400">Ethereum Sepolia</p>
                  </div>
                </div>

                <div className="space-y-3 text-sm">
                  <div className="flex items-start gap-2">
                    <div className="w-1.5 h-1.5 bg-orange-400 rounded-full mt-1.5" />
                    <div>
                      <div className="text-white font-medium">Chainlink Feed</div>
                      <div className="text-slate-400 text-xs">ETH/USD Aggregator</div>
                    </div>
                  </div>
                  <div className="flex items-start gap-2">
                    <div className="w-1.5 h-1.5 bg-orange-400 rounded-full mt-1.5" />
                    <div>
                      <div className="text-white font-medium">Event Emission</div>
                      <div className="text-slate-400 text-xs">AnswerUpdated(price, round, timestamp)</div>
                    </div>
                  </div>
                </div>

                <div className="mt-4 pt-4 border-t border-white/10">
                  <div className="text-xs text-slate-400">Contract</div>
                  <div className="text-xs font-mono text-orange-400 truncate">
                    0x694A...325306
                  </div>
                </div>
              </div>
              
              {/* Arrow */}
              <div className="hidden md:flex absolute -right-4 top-1/2 -translate-y-1/2 z-10 items-center justify-center w-8 h-8 bg-slate-900 border border-green-500/50 rounded-full">
                <ArrowRight className="w-4 h-4 text-green-400" />
              </div>
            </div>

            {/* Reactive Network */}
            <div className="relative">
              <div className="bg-gradient-to-br from-green-500/10 to-green-600/10 border border-green-500/30 rounded-2xl p-6 backdrop-blur-sm">
                <div className="flex items-center gap-3 mb-4">
                  <div className="w-12 h-12 bg-green-500/20 rounded-lg flex items-center justify-center">
                    <Zap className="w-6 h-6 text-green-400 animate-pulse" />
                  </div>
                  <div>
                    <h3 className="text-lg font-bold text-white">Reactive Network</h3>
                    <p className="text-sm text-slate-400">Mainnet</p>
                  </div>
                </div>

                <div className="space-y-3 text-sm">
                  <div className="flex items-start gap-2">
                    <div className="w-1.5 h-1.5 bg-green-400 rounded-full mt-1.5" />
                    <div>
                      <div className="text-white font-medium">Event Subscription</div>
                      <div className="text-slate-400 text-xs">Monitors origin feed 24/7</div>
                    </div>
                  </div>
                  <div className="flex items-start gap-2">
                    <div className="w-1.5 h-1.5 bg-green-400 rounded-full mt-1.5" />
                    <div>
                      <div className="text-white font-medium">Deviation Check</div>
                      <div className="text-slate-400 text-xs">0.5% threshold filter</div>
                    </div>
                  </div>
                  <div className="flex items-start gap-2">
                    <div className="w-1.5 h-1.5 bg-green-400 rounded-full mt-1.5" />
                    <div>
                      <div className="text-white font-medium">EIP-712 Signing</div>
                      <div className="text-slate-400 text-xs">Cryptographic proof</div>
                    </div>
                  </div>
                  <div className="flex items-start gap-2">
                    <div className="w-1.5 h-1.5 bg-green-400 rounded-full mt-1.5" />
                    <div>
                      <div className="text-white font-medium">Cron Fallback</div>
                      <div className="text-slate-400 text-xs">Every 5 minutes</div>
                    </div>
                  </div>
                </div>

                <div className="mt-4 pt-4 border-t border-white/10">
                  <div className="text-xs text-slate-400">OracleReactive</div>
                  <div className="text-xs font-mono text-green-400">
                    Deploy to view
                  </div>
                </div>
              </div>
              
              {/* Arrow */}
              <div className="hidden md:flex absolute -right-4 top-1/2 -translate-y-1/2 z-10 items-center justify-center w-8 h-8 bg-slate-900 border border-blue-500/50 rounded-full">
                <ArrowRight className="w-4 h-4 text-blue-400" />
              </div>
            </div>

            {/* Destination Chain */}
            <div className="relative">
              <div className="bg-gradient-to-br from-blue-500/10 to-blue-600/10 border border-blue-500/30 rounded-2xl p-6 backdrop-blur-sm">
                <div className="flex items-center gap-3 mb-4">
                  <div className="w-12 h-12 bg-blue-500/20 rounded-lg flex items-center justify-center">
                    <Shield className="w-6 h-6 text-blue-400" />
                  </div>
                  <div>
                    <h3 className="text-lg font-bold text-white">Destination Chain</h3>
                    <p className="text-sm text-slate-400">Base Sepolia</p>
                  </div>
                </div>

                <div className="space-y-3 text-sm">
                  <div className="flex items-start gap-2">
                    <div className="w-1.5 h-1.5 bg-blue-400 rounded-full mt-1.5" />
                    <div>
                      <div className="text-white font-medium">Signature Verification</div>
                      <div className="text-slate-400 text-xs">EIP-712 validation</div>
                    </div>
                  </div>
                  <div className="flex items-start gap-2">
                    <div className="w-1.5 h-1.5 bg-blue-400 rounded-full mt-1.5" />
                    <div>
                      <div className="text-white font-medium">Circuit Breaker</div>
                      <div className="text-slate-400 text-xs">20% deviation limit</div>
                    </div>
                  </div>
                  <div className="flex items-start gap-2">
                    <div className="w-1.5 h-1.5 bg-blue-400 rounded-full mt-1.5" />
                    <div>
                      <div className="text-white font-medium">FeedProxy Storage</div>
                      <div className="text-slate-400 text-xs">AggregatorV3 compatible</div>
                    </div>
                  </div>
                  <div className="flex items-start gap-2">
                    <div className="w-1.5 h-1.5 bg-blue-400 rounded-full mt-1.5" />
                    <div>
                      <div className="text-white font-medium">dApp Consumption</div>
                      <div className="text-slate-400 text-xs">latestRoundData()</div>
                    </div>
                  </div>
                </div>

                <div className="mt-4 pt-4 border-t border-white/10">
                  <div className="text-xs text-slate-400">FeedProxy</div>
                  <div className="text-xs font-mono text-blue-400">
                    Deploy to view
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Why Reactive Section */}
        <div className="mt-16 max-w-4xl mx-auto">
          <div className="bg-gradient-to-br from-purple-500/10 to-pink-500/10 border border-purple-500/30 rounded-2xl p-8">
            <h3 className="text-2xl font-bold text-white mb-4 flex items-center gap-3">
              <Zap className="w-6 h-6 text-purple-400" />
              Why Reactive Contracts Are Essential
            </h3>
            
            <div className="grid md:grid-cols-2 gap-6">
              <div>
                <h4 className="text-sm font-semibold text-red-400 mb-2">❌ Without Reactive</h4>
                <ul className="space-y-2 text-sm text-slate-300">
                  <li>• Requires centralized bot infrastructure</li>
                  <li>• Single point of failure (uptime risk)</li>
                  <li>• Trust assumptions (bot operator)</li>
                  <li>• Censorship vulnerable</li>
                  <li>• MEV exploitation possible</li>
                  <li>• 24/7 operational overhead</li>
                </ul>
              </div>

              <div>
                <h4 className="text-sm font-semibold text-green-400 mb-2">✅ With Reactive</h4>
                <ul className="space-y-2 text-sm text-slate-300">
                  <li>• Fully autonomous (no infrastructure)</li>
                  <li>• Decentralized (network consensus)</li>
                  <li>• Trustless (cryptographic proofs)</li>
                  <li>• Censorship resistant</li>
                  <li>• No MEV surface</li>
                  <li>• Zero operational overhead</li>
                </ul>
              </div>
            </div>

            <div className="mt-6 p-4 bg-white/5 rounded-lg border border-white/10">
              <p className="text-sm text-slate-300 leading-relaxed">
                <span className="text-purple-400 font-semibold">Key Insight:</span> Standard smart contracts cannot listen to events from other chains or trigger cross-chain actions autonomously. This oracle is <span className="text-white font-semibold">fundamentally impossible</span> to build without Reactive Contracts.
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
