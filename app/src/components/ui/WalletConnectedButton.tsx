'use client';

import React, { useEffect, useRef } from "react";
import { useRouter } from "next/navigation";
import { useAccount } from "wagmi";
import { useAppKit } from "@reown/appkit/react";
import Button from "./Button";

const WalletConnectedButton: React.FC = () => {
  const router = useRouter();
  const { isConnected } = useAccount();
  const { open } = useAppKit();
  const pendingNavigation = useRef(false);

  const handleGetStarted = () => {
    if (isConnected) {
      // Wallet is connected, navigate to wallet page
      router.push("/dashboard");
    } else {
      // Wallet not connected, open connect modal and set flag for navigation
      pendingNavigation.current = true;
      open();
    }
  };

  // Navigate to wallet page after successful connection
  useEffect(() => {
    if (isConnected && pendingNavigation.current) {
      pendingNavigation.current = false;
      router.push("/dashboard");
    }
  }, [isConnected, router]);

  return (
    <Button
      variant="primary"
      size="lg"
      className="text-lg px-8 py-4"
      onClick={handleGetStarted}
    >
      Get Started
    </Button>
  );
};

export default WalletConnectedButton;