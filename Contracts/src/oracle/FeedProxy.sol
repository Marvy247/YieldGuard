// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import './IAggregatorV3.sol';

contract FeedProxy is IAggregatorV3 {
    
    struct RoundData {
        uint80 roundId;
        int256 answer;
        uint256 startedAt;
        uint256 updatedAt;
        uint80 answeredInRound;
    }
    
    uint8 private _decimals;
    string private _description;
    uint256 private constant VERSION = 1;
    
    address public owner;
    address public callbackProxy;
    
    uint80 public latestRound;
    mapping(uint80 => RoundData) public rounds;
    
    uint256 public immutable STALENESS_THRESHOLD;
    uint256 public immutable MAX_PRICE_DEVIATION_BPS = 2000; // 20%
    bool public paused;
    
    event RoundUpdated(
        uint80 indexed roundId,
        int256 answer,
        uint256 updatedAt,
        address indexed updater
    );
    
    event CircuitBreakerTriggered(
        uint80 roundId,
        int256 oldAnswer,
        int256 newAnswer,
        uint256 deviationBps
    );
    
    event PausedStateChanged(bool isPaused);
    
    error Unauthorized();
    error StaleData(uint256 age);
    error InvalidRoundId(uint80 provided, uint80 expected);
    error ContractPaused();
    error PriceDeviationTooHigh(uint256 deviationBps);
    
    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }
    
    modifier onlyCallbackProxy() {
        if (msg.sender != callbackProxy) revert Unauthorized();
        _;
    }
    
    modifier whenNotPaused() {
        if (paused) revert ContractPaused();
        _;
    }
    
    constructor(
        uint8 decimals_,
        string memory description_,
        address callbackProxy_,
        uint256 stalenessThreshold_
    ) {
        _decimals = decimals_;
        _description = description_;
        owner = msg.sender;
        callbackProxy = callbackProxy_;
        STALENESS_THRESHOLD = stalenessThreshold_;
    }
    
    function updateRoundData(
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) external onlyCallbackProxy whenNotPaused {
        // Validate round monotonicity
        if (roundId <= latestRound) {
            revert InvalidRoundId(roundId, latestRound + 1);
        }
        
        // Validate staleness
        if (block.timestamp > updatedAt + STALENESS_THRESHOLD) {
            revert StaleData(block.timestamp - updatedAt);
        }
        
        // Circuit breaker: check price deviation
        if (latestRound > 0) {
            int256 lastAnswer = rounds[latestRound].answer;
            if (lastAnswer > 0) {
                uint256 deviationBps = _calculateDeviationBps(lastAnswer, answer);
                if (deviationBps > MAX_PRICE_DEVIATION_BPS) {
                    emit CircuitBreakerTriggered(roundId, lastAnswer, answer, deviationBps);
                    revert PriceDeviationTooHigh(deviationBps);
                }
            }
        }
        
        rounds[roundId] = RoundData({
            roundId: roundId,
            answer: answer,
            startedAt: startedAt,
            updatedAt: updatedAt,
            answeredInRound: answeredInRound
        });
        
        latestRound = roundId;
        
        emit RoundUpdated(roundId, answer, updatedAt, tx.origin);
    }
    
    function decimals() external view override returns (uint8) {
        return _decimals;
    }
    
    function description() external view override returns (string memory) {
        return _description;
    }
    
    function version() external pure override returns (uint256) {
        return VERSION;
    }
    
    function getRoundData(uint80 _roundId)
        external
        view
        override
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        RoundData memory round = rounds[_roundId];
        return (
            round.roundId,
            round.answer,
            round.startedAt,
            round.updatedAt,
            round.answeredInRound
        );
    }
    
    function latestRoundData()
        external
        view
        override
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        RoundData memory round = rounds[latestRound];
        return (
            round.roundId,
            round.answer,
            round.startedAt,
            round.updatedAt,
            round.answeredInRound
        );
    }
    
    function setPaused(bool _paused) external onlyOwner {
        paused = _paused;
        emit PausedStateChanged(_paused);
    }
    
    function updateCallbackProxy(address newCallbackProxy) external onlyOwner {
        callbackProxy = newCallbackProxy;
    }
    
    function _calculateDeviationBps(int256 oldPrice, int256 newPrice) private pure returns (uint256) {
        if (oldPrice == 0) return 0;
        
        int256 diff = newPrice > oldPrice ? newPrice - oldPrice : oldPrice - newPrice;
        uint256 absDiff = uint256(diff);
        uint256 absOldPrice = uint256(oldPrice > 0 ? oldPrice : -oldPrice);
        
        return (absDiff * 10000) / absOldPrice;
    }
}
