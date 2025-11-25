'use client';

import { useReadContract } from 'wagmi';
import { CONTRACTS, FEED_PROXY_ABI, CHAIN_IDS } from '@/config/contracts';

export default function DebugPriceFeed() {
  const { data, isLoading, isError, error } = useReadContract({
    address: CONTRACTS.feedProxy,
    abi: FEED_PROXY_ABI,
    functionName: 'latestRoundData',
    chainId: CHAIN_IDS.destination,
  });

  const [roundId, answer, startedAt, updatedAt, answeredInRound] = data || [];

  return (
    <div className="fixed bottom-4 right-4 bg-black/90 text-white p-4 rounded-lg max-w-md text-xs font-mono z-50">
      <div className="font-bold mb-2 text-green-400">✓ DEBUG INFO</div>
      <div>Feed Proxy: {CONTRACTS.feedProxy}</div>
      <div>Chain ID: {CHAIN_IDS.destination}</div>
      <div>Loading: {isLoading ? 'YES' : 'NO'}</div>
      <div>Error: {isError ? 'YES' : 'NO'}</div>
      {error && <div className="text-red-400">Error: {error.message}</div>}
      <div className="mt-2 border-t border-white/20 pt-2">
        {data ? (
          <>
            <div>Round ID: {roundId?.toString()}</div>
            <div>Answer: {answer?.toString()}</div>
            <div>Started: {startedAt?.toString()}</div>
            <div>Updated: {updatedAt?.toString()}</div>
            <div>Answered: {answeredInRound?.toString()}</div>
          </>
        ) : (
          <div>No data</div>
        )}
      </div>
    </div>
  );
}
