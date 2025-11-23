'use client';

import { Shield, Lock, AlertTriangle, Clock, CheckCircle } from 'lucide-react';

export default function SecuritySection() {
  const securityFeatures = [
    {
      icon: Lock,
      title: 'EIP-712 Signatures',
      description: 'Structured data hashing with domain separation prevents replay attacks across chains',
      color: 'blue',
    },
    {
      icon: AlertTriangle,
      title: 'Circuit Breaker',
      description: '20% deviation limit automatically halts updates on suspicious price jumps',
      color: 'orange',
    },
    {
      icon: Clock,
      title: 'Staleness Checks',
      description: '1-hour threshold rejects outdated prices, preventing time-shifted manipulation',
      color: 'green',
    },
    {
      icon: CheckCircle,
      title: 'Round Monotonicity',
      description: 'Strictly increasing round IDs prevent replay of historical price data',
      color: 'purple',
    },
  ];

  return (
    <section className="py-20 px-6 relative">
      <div className="max-w-7xl mx-auto">
        {/* Section Header */}
        <div className="text-center mb-16">
          <div className="inline-flex items-center gap-2 px-4 py-2 bg-green-500/10 border border-green-500/20 rounded-full mb-4">
            <Shield className="w-4 h-4 text-green-400" />
            <span className="text-sm font-medium text-green-400">Production-Grade Security</span>
          </div>
          <h2 className="text-4xl md:text-5xl font-bold text-white mb-4">
            Battle-Tested Protection
          </h2>
          <p className="text-lg text-slate-400 max-w-2xl mx-auto">
            Multi-layered security architecture designed to prevent manipulation and ensure data integrity
          </p>
        </div>

        {/* Security Features Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-16">
          {securityFeatures.map((feature, index) => {
            const Icon = feature.icon;
            const colorClasses = {
              blue: 'from-blue-500/10 to-blue-600/10 border-blue-500/30 text-blue-400 bg-blue-500/20',
              orange: 'from-orange-500/10 to-orange-600/10 border-orange-500/30 text-orange-400 bg-orange-500/20',
              green: 'from-green-500/10 to-green-600/10 border-green-500/30 text-green-400 bg-green-500/20',
              purple: 'from-purple-500/10 to-purple-600/10 border-purple-500/30 text-purple-400 bg-purple-500/20',
            };
            
            return (
              <div
                key={index}
                className={`bg-gradient-to-br ${colorClasses[feature.color as keyof typeof colorClasses].split(' ')[0]} ${colorClasses[feature.color as keyof typeof colorClasses].split(' ')[1]} border ${colorClasses[feature.color as keyof typeof colorClasses].split(' ')[2]} rounded-xl p-6 backdrop-blur-sm hover:scale-105 transition-transform`}
              >
                <div className={`w-12 h-12 ${colorClasses[feature.color as keyof typeof colorClasses].split(' ')[4]} rounded-lg flex items-center justify-center mb-4`}>
                  <Icon className={`w-6 h-6 ${colorClasses[feature.color as keyof typeof colorClasses].split(' ')[3]}`} />
                </div>
                <h3 className="text-xl font-bold text-white mb-2">{feature.title}</h3>
                <p className="text-slate-400 text-sm leading-relaxed">{feature.description}</p>
              </div>
            );
          })}
        </div>

        {/* Test Results */}
        <div className="max-w-4xl mx-auto bg-white/5 border border-white/10 rounded-2xl p-8">
          <h3 className="text-2xl font-bold text-white mb-6 flex items-center gap-3">
            <CheckCircle className="w-6 h-6 text-green-400" />
            Test Coverage: 10/10 Passing ✅
          </h3>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="flex items-start gap-3 p-4 bg-white/5 rounded-lg">
              <CheckCircle className="w-5 h-5 text-green-400 flex-shrink-0 mt-0.5" />
              <div>
                <div className="text-white font-medium text-sm">Unit Tests</div>
                <div className="text-slate-400 text-xs">Deployment, updates, getters</div>
              </div>
            </div>
            
            <div className="flex items-start gap-3 p-4 bg-white/5 rounded-lg">
              <CheckCircle className="w-5 h-5 text-green-400 flex-shrink-0 mt-0.5" />
              <div>
                <div className="text-white font-medium text-sm">Security Tests</div>
                <div className="text-slate-400 text-xs">Unauthorized access, pause/unpause</div>
              </div>
            </div>
            
            <div className="flex items-start gap-3 p-4 bg-white/5 rounded-lg">
              <CheckCircle className="w-5 h-5 text-green-400 flex-shrink-0 mt-0.5" />
              <div>
                <div className="text-white font-medium text-sm">Adversarial Tests</div>
                <div className="text-slate-400 text-xs">Staleness, invalid rounds, circuit breaker</div>
              </div>
            </div>
            
            <div className="flex items-start gap-3 p-4 bg-white/5 rounded-lg">
              <CheckCircle className="w-5 h-5 text-green-400 flex-shrink-0 mt-0.5" />
              <div>
                <div className="text-white font-medium text-sm">Fuzz Tests</div>
                <div className="text-slate-400 text-xs">256 random scenarios validated</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
