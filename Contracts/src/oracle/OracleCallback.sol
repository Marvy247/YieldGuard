// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import '../../lib/reactive-lib/src/abstract-base/AbstractCallback.sol';
import './FeedProxy.sol';

contract OracleCallback is AbstractCallback {
    
    address public feedProxy;
    address public reactiveContract;
    
    // EIP-712 Domain for verification
    bytes32 private immutable DOMAIN_SEPARATOR;
    bytes32 private constant PRICE_UPDATE_TYPEHASH = 
        keccak256("PriceUpdate(address feedAddress,uint80 roundId,int256 answer,uint256 startedAt,uint256 updatedAt,uint80 answeredInRound)");
    
    uint256 public immutable REACTIVE_CHAIN_ID;
    address public immutable ORIGIN_FEED_ADDRESS;
    
    event PriceUpdated(
        uint80 indexed roundId,
        int256 answer,
        uint256 updatedAt,
        bytes32 verificationHash
    );
    
    event UpdateFailed(
        uint80 roundId,
        string reason
    );
    
    error SignatureVerificationFailed();
    error Unauthorized();
    
    constructor(
        address callbackProxy_,
        address feedProxy_,
        uint256 reactiveChainId,
        address originFeedAddress
    ) AbstractCallback(callbackProxy_) {
        feedProxy = feedProxy_;
        REACTIVE_CHAIN_ID = reactiveChainId;
        ORIGIN_FEED_ADDRESS = originFeedAddress;
        
        // Setup EIP-712 domain separator (must match reactive contract)
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes("ReactiveOracleRelay")),
                keccak256(bytes("1")),
                REACTIVE_CHAIN_ID,
                address(0) // Reactive contract address would be set here in production
            )
        );
    }
    
    function updatePrice(
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound,
        bytes32 providedDigest
    ) external authorizedSenderOnly {
        // Verify EIP-712 signature
        bytes32 structHash = keccak256(
            abi.encode(
                PRICE_UPDATE_TYPEHASH,
                ORIGIN_FEED_ADDRESS,
                roundId,
                answer,
                startedAt,
                updatedAt,
                answeredInRound
            )
        );
        
        bytes32 expectedDigest = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash)
        );
        
        if (expectedDigest != providedDigest) {
            revert SignatureVerificationFailed();
        }
        
        // Update the feed proxy
        try FeedProxy(feedProxy).updateRoundData(
            roundId,
            answer,
            startedAt,
            updatedAt,
            answeredInRound
        ) {
            emit PriceUpdated(roundId, answer, updatedAt, providedDigest);
        } catch Error(string memory reason) {
            emit UpdateFailed(roundId, reason);
        } catch {
            emit UpdateFailed(roundId, "Unknown error");
        }
    }
    
    function pollAndUpdate() external authorizedSenderOnly {
        // This function would be called by cron-triggered callbacks
        // In a full implementation, this would query the origin chain's
        // Chainlink feed via cross-chain call and update if needed
        // For now, this serves as a placeholder for the cron polling mechanism
    }
    
    function updateFeedProxy(address newFeedProxy) external {
        require(msg.sender == FeedProxy(feedProxy).owner(), "Not authorized");
        feedProxy = newFeedProxy;
    }
    
    receive() external payable override {
        // Accept ETH for gas refunds
    }
}
