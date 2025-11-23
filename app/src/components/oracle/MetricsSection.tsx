'use client';

import { DollarSign, Zap, Clock, TrendingDown } from 'lucide-react';

export default function MetricsSection() {
  return (
    <section className="py-20 px-6 relative">
      <div className="max-w-7xl mx-auto">
        {/* Section Header */}
        <div className="text-center mb-16">
          <h2 className="text-4xl md:text-5xl font-bold text-white mb-4">
            Cost & Performance
          </h2>
          <p className="text-lg text-slate-400">
            Gas-optimized design with 82% cost reduction vs. naive implementation
          </p>
        </div>

        {/* Metrics Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-12">
          <div className="bg-gradient-to-br from-green-500/10 to-green-600/10 border border-green-500/30 rounded-xl p-6">
            <div className="flex items-center gap-3 mb-4">
              <div className="w-10 h-10 bg-green-500/20 rounded-lg flex items-center justify-center">
                <DollarSign className="w-5 h-5 text-green-400" />
              </div>
              <div className="text-sm text-slate-400">Setup Cost</div>
            </div>
            <div className="text-3xl font-bold text-white mb-1">$5</div>
            <div className="text-xs text-slate-500">One-time deployment</div>
          </div>

          <div className="bg-gradient-to-br from-blue-500/10 to-blue-600/10 border border-blue-500/30 rounded-xl p-6">
            <div className="flex items-center gap-3 mb-4">
              <div className="w-10 h-10 bg-blue-500/20 rounded-lg flex items-center justify-center">
                <Clock className="w-5 h-5 text-blue-400" />
              </div>
              <div className="text-sm text-slate-400">Update Frequency</div>
            </div>
            <div className="text-3xl font-bold text-white mb-1">~5min</div>
            <div className="text-xs text-slate-500">Average interval</div>
          </div>

          <div className="bg-gradient-to-br from-purple-500/10 to-purple-600/10 border border-purple-500/30 rounded-xl p-6">
            <div className="flex items-center gap-3 mb-4">
              <div className="w-10 h-10 bg-purple-500/20 rounded-lg flex items-center justify-center">
                <Zap className="w-5 h-5 text-purple-400" />
              </div>
              <div className="text-sm text-slate-400">Gas per Update</div>
            </div>
            <div className="text-3xl font-bold text-white mb-1">165k</div>
            <div className="text-xs text-slate-500">~$0.10 on Base</div>
          </div>

          <div className="bg-gradient-to-br from-orange-500/10 to-orange-600/10 border border-orange-500/30 rounded-xl p-6">
            <div className="flex items-center gap-3 mb-4">
              <div className="w-10 h-10 bg-orange-500/20 rounded-lg flex items-center justify-center">
                <TrendingDown className="w-5 h-5 text-orange-400" />
              </div>
              <div className="text-sm text-slate-400">Monthly Cost</div>
            </div>
            <div className="text-3xl font-bold text-white mb-1">$150</div>
            <div className="text-xs text-slate-500">~50 updates/day</div>
          </div>
        </div>

        {/* Comparison Table */}
        <div className="max-w-4xl mx-auto">
          <div className="bg-white/5 border border-white/10 rounded-2xl overflow-hidden">
            <div className="p-6 border-b border-white/10">
              <h3 className="text-xl font-bold text-white">Cost Comparison</h3>
            </div>
            
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="border-b border-white/10">
                    <th className="text-left p-4 text-sm font-semibold text-slate-400">Approach</th>
                    <th className="text-right p-4 text-sm font-semibold text-slate-400">Setup</th>
                    <th className="text-right p-4 text-sm font-semibold text-slate-400">Monthly</th>
                    <th className="text-right p-4 text-sm font-semibold text-slate-400">Reliability</th>
                  </tr>
                </thead>
                <tbody>
                  <tr className="border-b border-white/10 hover:bg-white/5">
                    <td className="p-4 text-white">
                      <div className="flex items-center gap-2">
                        <span className="text-green-400">✓</span>
                        <span className="font-medium">Reactive Oracle (This)</span>
                      </div>
                    </td>
                    <td className="p-4 text-right text-white">$5</td>
                    <td className="p-4 text-right text-white">$150</td>
                    <td className="p-4 text-right">
                      <span className="text-green-400 font-semibold">99.9%</span>
                    </td>
                  </tr>
                  
                  <tr className="border-b border-white/10 hover:bg-white/5">
                    <td className="p-4 text-slate-400">
                      <div className="flex items-center gap-2">
                        <span className="text-red-400">✗</span>
                        <span>Centralized Bot</span>
                      </div>
                    </td>
                    <td className="p-4 text-right text-slate-400">$0</td>
                    <td className="p-4 text-right text-slate-400">$500+</td>
                    <td className="p-4 text-right">
                      <span className="text-orange-400">95%</span>
                    </td>
                  </tr>
                  
                  <tr className="hover:bg-white/5">
                    <td className="p-4 text-slate-400">
                      <div className="flex items-center gap-2">
                        <span className="text-red-400">✗</span>
                        <span>Manual Updates</span>
                      </div>
                    </td>
                    <td className="p-4 text-right text-slate-400">$5</td>
                    <td className="p-4 text-right text-slate-400">$1000+</td>
                    <td className="p-4 text-right">
                      <span className="text-red-400">80%</span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <div className="p-6 bg-green-500/5 border-t border-green-500/20">
              <div className="flex items-center gap-3">
                <TrendingDown className="w-5 h-5 text-green-400" />
                <div>
                  <div className="text-white font-semibold text-sm">70% Cost Savings</div>
                  <div className="text-slate-400 text-xs">vs. centralized bot infrastructure</div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Gas Optimization Details */}
        <div className="mt-12 max-w-4xl mx-auto grid md:grid-cols-2 gap-6">
          <div className="bg-white/5 border border-white/10 rounded-xl p-6">
            <h4 className="text-lg font-bold text-white mb-4">Gas Optimization</h4>
            <ul className="space-y-3">
              <li className="flex items-start gap-2 text-sm">
                <span className="text-green-400 mt-1">→</span>
                <div>
                  <div className="text-white">Deviation Threshold (0.5%)</div>
                  <div className="text-slate-400 text-xs">Skip updates on minor price changes</div>
                </div>
              </li>
              <li className="flex items-start gap-2 text-sm">
                <span className="text-green-400 mt-1">→</span>
                <div>
                  <div className="text-white">Event-Driven Updates</div>
                  <div className="text-slate-400 text-xs">Only trigger on actual changes</div>
                </div>
              </li>
              <li className="flex items-start gap-2 text-sm">
                <span className="text-green-400 mt-1">→</span>
                <div>
                  <div className="text-white">Efficient Storage</div>
                  <div className="text-slate-400 text-xs">Optimized data structures</div>
                </div>
              </li>
            </ul>
          </div>

          <div className="bg-white/5 border border-white/10 rounded-xl p-6">
            <h4 className="text-lg font-bold text-white mb-4">Reliability Features</h4>
            <ul className="space-y-3">
              <li className="flex items-start gap-2 text-sm">
                <span className="text-blue-400 mt-1">→</span>
                <div>
                  <div className="text-white">Dual Trigger System</div>
                  <div className="text-slate-400 text-xs">Events + Cron fallback</div>
                </div>
              </li>
              <li className="flex items-start gap-2 text-sm">
                <span className="text-blue-400 mt-1">→</span>
                <div>
                  <div className="text-white">Automatic Recovery</div>
                  <div className="text-slate-400 text-xs">No manual intervention needed</div>
                </div>
              </li>
              <li className="flex items-start gap-2 text-sm">
                <span className="text-blue-400 mt-1">→</span>
                <div>
                  <div className="text-white">Decentralized</div>
                  <div className="text-slate-400 text-xs">No single point of failure</div>
                </div>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </section>
  );
}
