'use client';

import { useAppKit } from '@reown/appkit/react';
import { useAccount } from 'wagmi';
import Button from './Button';

export default function ConnectWalletButton() {
  const { open } = useAppKit();
  const { isConnected, address } = useAccount();

  if (isConnected && address) {
    return (
      <div className="flex items-center space-x-4">
        <Button 
          variant="outline" 
          size="sm"
          onClick={() => open()}
        >
          {address.slice(0, 6)}...{address.slice(-4)}
        </Button>

      </div>
    );
  }

  return (
    <div className="flex items-center space-x-4">
      <Button 
        variant="outline" 
        size="sm"
        onClick={() => open()}
      >
        Connect Wallet
      </Button>

    </div>
  );
}