'use client';

import { ArrowRight, Zap, Shield, TrendingUp } from 'lucide-react';
import Link from 'next/link';

export default function OracleHeroSection() {
  return (
    <section className="relative pt-32 pb-20 px-6">
      {/* Background Effects */}
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-green-500/10 rounded-full blur-3xl animate-pulse" />
        <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-blue-500/10 rounded-full blur-3xl animate-pulse delay-1000" />
      </div>

      <div className="max-w-7xl mx-auto relative">
        {/* Badge */}
        <div className="flex justify-center mb-8">
          <div className="inline-flex items-center gap-2 px-4 py-2 bg-green-500/10 border border-green-500/20 rounded-full">
            <Zap className="w-4 h-4 text-green-400" />
            <span className="text-sm font-medium text-green-400">
              Reactive Bounties 2.0 - Bounty #1 Submission
            </span>
          </div>
        </div>

        {/* Main Content */}
        <div className="text-center max-w-4xl mx-auto">
          <h1 className="text-5xl md:text-7xl font-bold mb-6 bg-gradient-to-r from-white via-blue-200 to-green-200 bg-clip-text text-transparent">
            Autonomous Cross-Chain
            <br />
            Price Feed Oracle
          </h1>

          <p className="text-xl md:text-2xl text-slate-400 mb-8 leading-relaxed">
            Mirror Chainlink price feeds from <span className="text-white font-semibold">Ethereum Sepolia</span> to{' '}
            <span className="text-white font-semibold">Base Sepolia</span> with zero trust assumptions,
            powered by <span className="text-green-400 font-semibold">Reactive Contracts</span>.
          </p>

          <div className="flex flex-col sm:flex-row gap-4 justify-center mb-12">
            <Link
              href="#live-feed"
              className="inline-flex items-center gap-2 px-8 py-4 bg-gradient-to-r from-green-500 to-blue-500 hover:from-green-600 hover:to-blue-600 text-white font-semibold rounded-lg transition-all transform hover:scale-105 shadow-lg shadow-green-500/25"
            >
              <TrendingUp className="w-5 h-5" />
              View Live Feed
              <ArrowRight className="w-5 h-5" />
            </Link>
            <Link
              href="#architecture"
              className="inline-flex items-center gap-2 px-8 py-4 bg-white/5 hover:bg-white/10 text-white font-semibold rounded-lg border border-white/10 transition-all"
            >
              <Shield className="w-5 h-5" />
              How It Works
            </Link>
          </div>

          {/* Key Features */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-16">
            <div className="p-6 bg-white/5 backdrop-blur-sm border border-white/10 rounded-xl">
              <div className="w-12 h-12 bg-green-500/10 rounded-lg flex items-center justify-center mb-4 mx-auto">
                <Zap className="w-6 h-6 text-green-400" />
              </div>
              <h3 className="text-lg font-semibold text-white mb-2">Fully Autonomous</h3>
              <p className="text-slate-400 text-sm">
                No bots, no servers. Reactive Contracts autonomously monitor and relay price updates 24/7.
              </p>
            </div>

            <div className="p-6 bg-white/5 backdrop-blur-sm border border-white/10 rounded-xl">
              <div className="w-12 h-12 bg-blue-500/10 rounded-lg flex items-center justify-center mb-4 mx-auto">
                <Shield className="w-6 h-6 text-blue-400" />
              </div>
              <h3 className="text-lg font-semibold text-white mb-2">Production Security</h3>
              <p className="text-slate-400 text-sm">
                EIP-712 signatures, circuit breakers, and staleness checks protect against manipulation.
              </p>
            </div>

            <div className="p-6 bg-white/5 backdrop-blur-sm border border-white/10 rounded-xl">
              <div className="w-12 h-12 bg-purple-500/10 rounded-lg flex items-center justify-center mb-4 mx-auto">
                <TrendingUp className="w-6 h-6 text-purple-400" />
              </div>
              <h3 className="text-lg font-semibold text-white mb-2">Gas Optimized</h3>
              <p className="text-slate-400 text-sm">
                Smart deviation thresholds reduce costs by 82% while maintaining price freshness.
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
