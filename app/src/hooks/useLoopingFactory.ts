import { useReadContract, useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { LOOPING_ADDRESSES } from '../config/looping';
import { LOOPING_FACTORY_ABI } from '../config/loopingABI';
import { parseEther, decodeEventLog } from 'viem';
import { useEffect, useState } from 'react';

export function useLoopingFactory(chainId: number = 84532) { // Base Sepolia
  const factoryAddress = LOOPING_ADDRESSES[chainId as keyof typeof LOOPING_ADDRESSES]?.factory;

  // Read user positions
  const useUserPositions = (userAddress?: string) => {
    const result = useReadContract({
      address: factoryAddress as `0x${string}`,
      abi: LOOPING_FACTORY_ABI,
      functionName: 'getUserPositions',
      args: userAddress ? [userAddress as `0x${string}`] : undefined,
      query: {
        enabled: !!userAddress && !!factoryAddress,
        refetchInterval: 5000, // Auto-refetch every 5 seconds
      },
    });
    
    // Debug logging
    console.log('useUserPositions:', {
      factoryAddress,
      userAddress,
      data: result.data,
      error: result.error,
      isLoading: result.isLoading,
    });
    
    return result;
  };

  // Read position details
  const usePositionDetails = (positionAddress?: string) => {
    return useReadContract({
      address: factoryAddress as `0x${string}`,
      abi: LOOPING_FACTORY_ABI,
      functionName: 'getPositionDetails',
      args: positionAddress ? [positionAddress as `0x${string}`] : undefined,
      query: {
        enabled: !!positionAddress && !!factoryAddress,
      },
    });
  };

  // Read total positions
  const useTotalPositions = () => {
    return useReadContract({
      address: factoryAddress as `0x${string}`,
      abi: LOOPING_FACTORY_ABI,
      functionName: 'getTotalPositions',
      query: {
        enabled: !!factoryAddress,
      },
    });
  };

  // Write: Create position
  const { 
    writeContract: createPosition, 
    data: createTxHash,
    isPending: isCreating,
    error: createError,
  } = useWriteContract();

  const { 
    data: receipt,
    isLoading: isConfirming,
    isSuccess: isConfirmed,
  } = useWaitForTransactionReceipt({
    hash: createTxHash,
  });

  // State to store created positions
  const [createdPositions, setCreatedPositions] = useState<Array<{
    callback: string;
    reactive: string;
    owner: string;
    collateralAsset: string;
    borrowAsset: string;
  }>>([]);

  // Parse PositionCreated events from transaction receipt
  useEffect(() => {
    if (receipt && receipt.logs) {
      const positions: typeof createdPositions = [];
      
      for (const log of receipt.logs) {
        try {
          const decoded = decodeEventLog({
            abi: LOOPING_FACTORY_ABI,
            data: log.data,
            topics: log.topics,
          });

          if (decoded.eventName === 'PositionCreated') {
            const args = decoded.args as {
              owner: string;
              callbackContract: string;
              reactiveContract: string;
              collateralAsset: string;
              borrowAsset: string;
            };
            
            positions.push({
              callback: args.callbackContract,
              reactive: args.reactiveContract,
              owner: args.owner,
              collateralAsset: args.collateralAsset,
              borrowAsset: args.borrowAsset,
            });
          }
        } catch (error) {
          // Skip logs that don't match
          console.log('Skipping log:', error);
        }
      }
      
      if (positions.length > 0) {
        console.log('Found created positions:', positions);
        setCreatedPositions(positions);
      }
    }
  }, [receipt]);

  const handleCreatePosition = async (
    collateralAsset: string,
    borrowAsset: string,
    targetLTV: number,
    maxSlippage: number,
    fundingAmount: string = '0.1' // ETH to fund the position contracts
  ) => {
    if (!factoryAddress) throw new Error('Factory address not set');

    return createPosition({
      address: factoryAddress as `0x${string}`,
      abi: LOOPING_FACTORY_ABI,
      functionName: 'createPosition',
      args: [
        collateralAsset as `0x${string}`,
        borrowAsset as `0x${string}`,
        BigInt(targetLTV * 100), // Convert to basis points
        BigInt(maxSlippage * 100), // Convert to basis points
      ],
      value: parseEther(fundingAmount),
    });
  };

  return {
    factoryAddress,
    useUserPositions,
    usePositionDetails,
    useTotalPositions,
    createPosition: handleCreatePosition,
    isCreating,
    isConfirming,
    isConfirmed,
    createError,
    createdPositions,
  };
}
