'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useAccount } from 'wagmi';
import { useLoopingFactory } from '@/hooks/useLoopingFactory';
import { PositionCard } from '@/components/looping/PositionCard';
import { ExecuteLeverageModal } from '@/components/looping/ExecuteLeverageModal';
import { SUPPORTED_ASSETS, LOOPING_ADDRESSES } from '@/config/looping';
import { PositionsList } from '@/components/looping/PositionsList';

export default function Dashboard() {
  const { address, isConnected } = useAccount();
  const [activeTab, setActiveTab] = useState<'positions' | 'create'>('positions');

  if (!isConnected) {
    return (
      <div className="min-h-screen bg-black text-white flex items-center justify-center">
        <div className="text-center">
          <h1 className="text-4xl font-bold mb-4">🔐 Connect Your Wallet</h1>
          <p className="text-gray-400 mb-8">Please connect your wallet to access the dashboard</p>
          <Link href="/" className="bg-white text-black px-6 py-3 rounded-full hover:bg-gray-200 transition">
            Go Back Home
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-black text-white">
      {/* Header */}
      <div className="border-b border-white/10">
        <div className="container mx-auto px-4 py-6">
          <div className="flex justify-between items-center">
            <div>
              <Link href="/" className="text-2xl font-bold text-white hover:text-gray-300 transition">
                🛡️ LoopGuard
              </Link>
              <p className="text-sm text-gray-400 mt-1">Your Position&apos;s 24/7 Guardian</p>
            </div>
            <div className="flex items-center gap-4">
              <div className="border border-white/10 bg-white/[0.02] px-4 py-2 rounded-full">
                <p className="text-xs text-gray-500">Connected</p>
                <p className="font-mono text-sm text-white">{address?.slice(0, 6)}...{address?.slice(-4)}</p>
              </div>
              <w3m-button />
            </div>
          </div>
        </div>
      </div>

      <div className="container mx-auto px-4 py-8">
        {/* Tabs */}
        <div className="flex gap-4 mb-8">
          <button
            onClick={() => setActiveTab('positions')}
            className={`px-6 py-3 rounded-full font-bold transition ${
              activeTab === 'positions'
                ? 'bg-white text-black'
                : 'border border-white/10 text-gray-400 hover:bg-white/5'
            }`}
          >
            📊 My Positions
          </button>
          <button
            onClick={() => setActiveTab('create')}
            className={`px-6 py-3 rounded-full font-bold transition ${
              activeTab === 'create'
                ? 'bg-white text-black'
                : 'border border-white/10 text-gray-400 hover:bg-white/5'
            }`}
          >
            ➕ Create Position
          </button>
        </div>

        {/* Content */}
        {activeTab === 'positions' ? (
          <PositionsView address={address!} />
        ) : (
          <CreatePositionView address={address!} />
        )}
      </div>
    </div>
  );
}

function PositionsView({ address }: { address: string }) {
  const [selectedPosition, setSelectedPosition] = useState<string | null>(null);
  const [showExecuteModal, setShowExecuteModal] = useState(false);
  const { useUserPositions } = useLoopingFactory();
  const { data: positions, isLoading, refetch, error } = useUserPositions(address);

  // Debug logging
  console.log('PositionsView Debug:', {
    address,
    positions,
    isLoading,
    error,
    positionsLength: positions?.length
  });

  if (isLoading) {
    return (
      <div className="text-center py-16">
        <div className="text-4xl mb-4">⏳</div>
        <p className="text-gray-400">Loading your positions...</p>
        <p className="text-xs text-gray-600 mt-2">Fetching from: {address?.slice(0, 10)}...</p>
      </div>
    );
  }

  // Check if error is "no data" (0x) which means empty array (no positions)
  const isEmptyDataError = error?.message?.includes('returned no data ("0x")');
  
  if (error && !isEmptyDataError) {
    return (
      <div className="text-center py-16">
        <div className="text-4xl mb-4">⚠️</div>
        <h2 className="text-2xl font-bold mb-2 text-white">Error Loading Positions</h2>
        <p className="text-gray-400 mb-4 max-w-md mx-auto text-sm">{error.message}</p>
        <button
          onClick={() => refetch()}
          className="border border-white/20 text-white px-6 py-2 rounded-full hover:bg-white/5 transition"
        >
          ↻ Try Again
        </button>
        <div className="mt-6 text-xs text-gray-600">
          <p>Factory: {LOOPING_ADDRESSES[84532]?.factory}</p>
          <p>User: {address?.slice(0, 10)}...{address?.slice(-8)}</p>
        </div>
      </div>
    );
  }

  // Treat empty data error as no positions
  if (!positions || positions.length === 0 || isEmptyDataError) {
    return (
      <div className="py-16">
        <div className="text-center mb-8">
          <div className="text-6xl mb-4">📭</div>
          <h2 className="text-2xl font-bold mb-2">No Positions from getUserPositions</h2>
          <p className="text-gray-400 mb-6">Checking PositionCreated events instead...</p>
          <button
            onClick={() => {
              console.log('Manual refetch triggered');
              refetch();
            }}
            className="border border-white/20 text-white px-6 py-2 rounded-full hover:bg-white/5 transition"
          >
            ↻ Refresh Positions
          </button>
        </div>
        
        <div className="max-w-4xl mx-auto">
          <h3 className="text-xl font-bold mb-4 text-white">Positions from Events:</h3>
          <PositionsList userAddress={address} />
        </div>
        
        <div className="text-center mt-8">
          <div className="max-w-md mx-auto p-4 border border-white/10 rounded-xl bg-white/[0.02] text-left">
            <p className="text-sm text-gray-400 mb-2">To create your first position:</p>
            <ol className="text-sm text-gray-500 space-y-1 ml-4">
              <li>1. Switch to the &quot;Create Position&quot; tab</li>
              <li>2. Choose your assets and leverage</li>
              <li>3. Fund with ETH for gas</li>
              <li>4. Click &quot;Create Protected Position&quot;</li>
            </ol>
          </div>
          <p className="text-xs text-gray-600 mt-4">
            Connected: {address?.slice(0, 10)}...{address?.slice(-8)}
          </p>
        </div>
      </div>
    );
  }

  return (
    <>
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-2xl font-bold text-white">Your Positions ({positions.length})</h2>
        <button
          onClick={() => refetch()}
          className="border border-white/20 text-white px-4 py-2 rounded-full hover:bg-white/5 transition flex items-center gap-2"
        >
          ↻ Refresh
        </button>
      </div>
      <div className="grid md:grid-cols-2 gap-6">
        {positions.map((positionAddress: string) => (
          <PositionCard
            key={positionAddress}
            address={positionAddress}
            onExecute={() => {
              setSelectedPosition(positionAddress);
              setShowExecuteModal(true);
            }}
            onUnwind={() => {
              // Handle unwind
              alert('Unwind functionality coming soon!');
            }}
          />
        ))}
      </div>

      {/* Execute Leverage Modal */}
      {showExecuteModal && selectedPosition && (
        <ExecuteLeverageModal
          callbackAddress={selectedPosition}
          collateralAsset="0xC558DBdd856501FCd9aaF1E62eae57A9F0629a3c" // WETH
          onClose={() => {
            setShowExecuteModal(false);
            setSelectedPosition(null);
          }}
          onSuccess={() => {
            refetch();
          }}
        />
      )}
    </>
  );
}

function CreatePositionView({ address }: { address: string }) {
  const [collateralAsset, setCollateralAsset] = useState('WETH');
  const [borrowAsset, setBorrowAsset] = useState('USDC');
  const [initialAmount, setInitialAmount] = useState('');
  const [targetLTV, setTargetLTV] = useState(70);
  const [maxSlippage, setMaxSlippage] = useState(3);
  const [fundingAmount, setFundingAmount] = useState('0.1');
  const [createdCallbackAddress, setCreatedCallbackAddress] = useState<string | null>(null);
  const [showExecuteModal, setShowExecuteModal] = useState(false);
  
  const { createPosition, isCreating, isConfirming, isConfirmed, createError, createdPositions } = useLoopingFactory();
  
  const assets = SUPPORTED_ASSETS[84532]; // Base Sepolia

  const handleCreate = async () => {
    try {
      const collateralAddr = assets[collateralAsset as keyof typeof assets]?.address;
      const borrowAddr = assets[borrowAsset as keyof typeof assets]?.address;
      
      if (!collateralAddr || !borrowAddr) {
        alert('Invalid asset selection');
        return;
      }

      const result = await createPosition(
        collateralAddr,
        borrowAddr,
        targetLTV,
        maxSlippage,
        fundingAmount
      );
      
      console.log('Position creation result:', result);
      
      // Don't auto-reload, show next steps instead
    } catch (error) {
      console.error('Failed to create position:', error);
    }
  };

  return (
    <div className="max-w-2xl mx-auto">
      <div className="border border-white/10 bg-white/[0.02] p-8 rounded-2xl">
        <h2 className="text-3xl font-bold mb-6 text-white">Create Leveraged Position</h2>
        
        {/* Collateral Asset */}
        <div className="mb-6">
          <label className="block text-sm font-bold mb-2">Collateral Asset</label>
          <select
            value={collateralAsset}
            onChange={(e) => setCollateralAsset(e.target.value)}
            className="w-full bg-black border border-white/10 rounded-lg focus:border-white/30 focus:outline-none px-4 py-3 text-white"
          >
            <option value="WETH">⟠ WETH</option>
            <option value="DAI">◈ DAI</option>
          </select>
        </div>

        {/* Borrow Asset */}
        <div className="mb-6">
          <label className="block text-sm font-bold mb-2">Borrow Asset</label>
          <select
            value={borrowAsset}
            onChange={(e) => setBorrowAsset(e.target.value)}
            className="w-full bg-black border border-white/10 rounded-lg focus:border-white/30 focus:outline-none px-4 py-3 text-white"
          >
            <option value="USDC">💵 USDC</option>
            <option value="DAI">◈ DAI</option>
            <option value="WETH">⟠ WETH (Same-asset looping)</option>
          </select>
        </div>

        {/* Initial Amount */}
        <div className="mb-6">
          <label className="block text-sm font-bold mb-2">Initial Amount</label>
          <input
            type="number"
            value={initialAmount}
            onChange={(e) => setInitialAmount(e.target.value)}
            placeholder="0.0"
            className="w-full bg-black border border-white/10 rounded-lg focus:border-white/30 focus:outline-none px-4 py-3 text-white"
          />
          <p className="text-xs text-gray-400 mt-1">Amount of {collateralAsset} to supply</p>
        </div>

        {/* Target LTV */}
        <div className="mb-6">
          <label className="block text-sm font-bold mb-2">
            Target LTV: {targetLTV}%
          </label>
          <input
            type="range"
            min="50"
            max="80"
            value={targetLTV}
            onChange={(e) => setTargetLTV(Number(e.target.value))}
            className="w-full"
          />
          <div className="flex justify-between text-xs text-gray-400 mt-1">
            <span>50% (Conservative)</span>
            <span>80% (Aggressive)</span>
          </div>
        </div>

        {/* Max Slippage */}
        <div className="mb-6">
          <label className="block text-sm font-bold mb-2">
            Max Slippage: {maxSlippage}%
          </label>
          <input
            type="range"
            min="1"
            max="10"
            step="0.5"
            value={maxSlippage}
            onChange={(e) => setMaxSlippage(Number(e.target.value))}
            className="w-full"
          />
          <div className="flex justify-between text-xs text-gray-400 mt-1">
            <span>1% (Low tolerance)</span>
            <span>10% (High tolerance)</span>
          </div>
        </div>

        {/* Protection Info */}
        <div className="border border-white/20 rounded-xl bg-white/[0.02] p-4 mb-6">
          <h3 className="font-bold mb-3 flex items-center text-white">
            <span className="mr-2">🛡️</span> Automatic Protection Enabled
          </h3>
          <ul className="text-sm text-gray-400 space-y-2">
            <li className="flex items-start">
              <span className="mr-2 text-white">•</span>
              <span>24/7 health factor monitoring</span>
            </li>
            <li className="flex items-start">
              <span className="mr-2 text-white">•</span>
              <span>Three-tier automatic protection</span>
            </li>
            <li className="flex items-start">
              <span className="mr-2 text-white">•</span>
              <span>Emergency deleverage when HF &lt; 1.5</span>
            </li>
          </ul>
        </div>

        {/* Funding Amount */}
        <div className="mb-6">
          <label className="block text-sm font-bold mb-2">
            Funding Amount (ETH for gas)
          </label>
          <input
            type="number"
            value={fundingAmount}
            onChange={(e) => setFundingAmount(e.target.value)}
            placeholder="0.1"
            className="w-full bg-black border border-white/10 rounded-lg focus:border-white/30 focus:outline-none px-4 py-3 text-white"
          />
          <p className="text-xs text-gray-400 mt-1">ETH sent to fund callback and reactive contracts</p>
        </div>

        {/* Create Button */}
        <button
          onClick={handleCreate}
          disabled={!fundingAmount || isCreating || isConfirming}
          className="w-full bg-white text-black hover:bg-gray-200 disabled:bg-gray-800 disabled:text-gray-600 disabled:cursor-not-allowed font-bold py-4 rounded-full transition"
        >
          {isCreating || isConfirming ? '⏳ Creating Position...' : 'Create Protected Position'}
        </button>

        {/* Error Message */}
        {createError && (
          <div className="mt-4 border border-white/30 rounded-xl p-4 bg-white/[0.05]">
            <p className="text-white font-bold">❌ Error Creating Position</p>
            <p className="text-sm text-gray-400 mt-1">{createError.message}</p>
          </div>
        )}

        {/* Success Message with Next Steps */}
        {isConfirmed && createdPositions && createdPositions.length > 0 && (
          <div className="mt-4 border border-green-500/30 rounded-xl p-6 bg-green-900/10">
            <p className="text-white font-bold text-lg mb-4">✅ Position Created Successfully!</p>
            
            <div className="bg-black/30 rounded-lg p-4 mb-4 font-mono text-sm">
              <p className="text-gray-400 mb-1">Callback Contract:</p>
              <p className="text-white break-all">{createdPositions[0].callback}</p>
              <p className="text-gray-400 mt-3 mb-1">Reactive Contract:</p>
              <p className="text-white break-all">{createdPositions[0].reactive}</p>
            </div>

            <div className="space-y-3 mb-4">
              <div className="flex items-start gap-3 bg-white/5 p-3 rounded-lg">
                <span className="text-2xl">1️⃣</span>
                <div>
                  <p className="font-bold text-white">Approve Tokens</p>
                  <p className="text-sm text-gray-400">Allow your position contract to use your {collateralAsset}</p>
                </div>
              </div>
              <div className="flex items-start gap-3 bg-white/5 p-3 rounded-lg">
                <span className="text-2xl">2️⃣</span>
                <div>
                  <p className="font-bold text-white">Execute Leverage</p>
                  <p className="text-sm text-gray-400">Start the leverage loop with your desired amount</p>
                </div>
              </div>
            </div>

            <button
              onClick={() => {
                setCreatedCallbackAddress(createdPositions[0].callback);
                setShowExecuteModal(true);
              }}
              className="w-full bg-white text-black hover:bg-gray-200 font-bold py-3 rounded-full transition"
            >
              🚀 Approve & Execute Leverage
            </button>

            <button
              onClick={() => window.location.reload()}
              className="w-full mt-3 border border-white/20 text-white hover:bg-white/5 font-bold py-3 rounded-full transition"
            >
              ↻ Refresh Dashboard
            </button>
          </div>
        )}

        {/* Estimated Stats */}
        {fundingAmount && (
          <div className="mt-6 pt-6 border-t border-gray-700">
            <h3 className="font-bold mb-3">Estimated Position</h3>
            <div className="grid grid-cols-2 gap-4 text-sm">
              <div className="border border-white/10 bg-white/[0.02] p-3 rounded">
                <p className="text-gray-400">Leverage</p>
                <p className="font-bold">~{(1 / (1 - targetLTV / 100)).toFixed(2)}x</p>
              </div>
              <div className="border border-white/10 bg-white/[0.02] p-3 rounded">
                <p className="text-gray-400">Initial HF</p>
                <p className="font-bold text-green-400">~3.5</p>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Execute Leverage Modal */}
      {showExecuteModal && createdCallbackAddress && (
        <ExecuteLeverageModal
          callbackAddress={createdCallbackAddress}
          collateralAsset={assets[collateralAsset as keyof typeof assets]?.address || '0x4200000000000000000000000000000000000006'}
          onClose={() => {
            setShowExecuteModal(false);
            setCreatedCallbackAddress(null);
          }}
          onSuccess={() => {
            window.location.reload();
          }}
        />
      )}
    </div>
  );
}
