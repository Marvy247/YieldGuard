// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/ILendingPool.sol";

contract RebalanceStrategy {
    uint256 public constant BASIS_POINTS = 10000;
    uint256 public constant HIGH_UTILIZATION_THRESHOLD = 8000; // 80%
    uint256 public constant RISK_PENALTY = 2000; // 20% penalty for high utilization
    
    uint256 public yieldDifferenceThreshold; // Minimum yield difference to trigger rebalance (in bps)
    uint256 public minRebalanceAmount; // Minimum amount worth rebalancing
    uint256 public cooldownPeriod; // Minimum time between rebalances
    uint256 public estimatedGasCost; // Estimated gas cost per rebalance in wei
    
    address public owner;
    mapping(address => uint256) public lastRebalanceTime;
    
    event ThresholdsUpdated(
        uint256 yieldDifference,
        uint256 minAmount,
        uint256 cooldown,
        uint256 gasCost
    );
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    constructor(
        uint256 _yieldThreshold,
        uint256 _minAmount,
        uint256 _cooldown,
        uint256 _gasCost
    ) {
        owner = msg.sender;
        yieldDifferenceThreshold = _yieldThreshold;
        minRebalanceAmount = _minAmount;
        cooldownPeriod = _cooldown;
        estimatedGasCost = _gasCost;
    }
    
    function updateThresholds(
        uint256 _yieldThreshold,
        uint256 _minAmount,
        uint256 _cooldown,
        uint256 _gasCost
    ) external onlyOwner {
        yieldDifferenceThreshold = _yieldThreshold;
        minRebalanceAmount = _minAmount;
        cooldownPeriod = _cooldown;
        estimatedGasCost = _gasCost;
        
        emit ThresholdsUpdated(_yieldThreshold, _minAmount, _cooldown, _gasCost);
    }
    
    function shouldRebalance(
        address fromPool,
        address toPool,
        address asset,
        uint256 vaultTotalAssets
    ) external view returns (bool shouldRebal, uint256 amount, int256 expectedProfit) {
        if (block.timestamp < lastRebalanceTime[fromPool] + cooldownPeriod) {
            return (false, 0, 0);
        }
        
        ILendingPool from = ILendingPool(fromPool);
        ILendingPool to = ILendingPool(toPool);
        
        uint256 fromRate = from.getSupplyRate(asset);
        uint256 toRate = to.getSupplyRate(asset);
        
        if (toRate <= fromRate) {
            return (false, 0, 0);
        }
        
        uint256 fromUtilization = from.getUtilizationRate(asset);
        uint256 toUtilization = to.getUtilizationRate(asset);
        
        uint256 adjustedFromRate = _calculateRiskAdjustedRate(fromRate, fromUtilization);
        uint256 adjustedToRate = _calculateRiskAdjustedRate(toRate, toUtilization);
        
        if (adjustedToRate <= adjustedFromRate) {
            return (false, 0, 0);
        }
        
        uint256 rateDifference = ((adjustedToRate - adjustedFromRate) * BASIS_POINTS) / adjustedFromRate;
        
        if (rateDifference < yieldDifferenceThreshold) {
            return (false, 0, 0);
        }
        
        uint256 fromBalance = from.getUserBalance(asset, msg.sender);
        if (fromBalance < minRebalanceAmount) {
            return (false, 0, 0);
        }
        
        uint256 rebalanceAmount = _calculateOptimalAmount(
            fromBalance,
            vaultTotalAssets,
            fromUtilization,
            toUtilization
        );
        
        if (rebalanceAmount < minRebalanceAmount) {
            return (false, 0, 0);
        }
        
        int256 profit = _estimateProfit(
            rebalanceAmount,
            adjustedFromRate,
            adjustedToRate,
            estimatedGasCost
        );
        
        if (profit <= 0) {
            return (false, 0, 0);
        }
        
        return (true, rebalanceAmount, profit);
    }
    
    function findBestRebalance(
        address[] calldata pools,
        address asset,
        uint256 vaultTotalAssets
    ) external view returns (
        bool shouldRebal,
        address fromPool,
        address toPool,
        uint256 amount,
        int256 expectedProfit
    ) {
        int256 bestProfit = 0;
        address bestFrom;
        address bestTo;
        uint256 bestAmount;
        
        for (uint256 i = 0; i < pools.length; i++) {
            for (uint256 j = 0; j < pools.length; j++) {
                if (i == j) continue;
                
                (bool should, uint256 amt, int256 profit) = this.shouldRebalance(
                    pools[i],
                    pools[j],
                    asset,
                    vaultTotalAssets
                );
                
                if (should && profit > bestProfit) {
                    bestProfit = profit;
                    bestFrom = pools[i];
                    bestTo = pools[j];
                    bestAmount = amt;
                }
            }
        }
        
        return (bestProfit > 0, bestFrom, bestTo, bestAmount, bestProfit);
    }
    
    function recordRebalance(address pool) external {
        lastRebalanceTime[pool] = block.timestamp;
    }
    
    function _calculateRiskAdjustedRate(uint256 rate, uint256 utilization) 
        internal 
        pure 
        returns (uint256) 
    {
        if (utilization <= HIGH_UTILIZATION_THRESHOLD) {
            return rate;
        }
        
        uint256 excessUtilization = utilization - HIGH_UTILIZATION_THRESHOLD;
        uint256 penalty = (rate * excessUtilization * RISK_PENALTY) / (BASIS_POINTS * BASIS_POINTS);
        
        return rate > penalty ? rate - penalty : 0;
    }
    
    function _calculateOptimalAmount(
        uint256 fromBalance,
        uint256 vaultTotalAssets,
        uint256 fromUtilization,
        uint256 toUtilization
    ) internal pure returns (uint256) {
        uint256 baseAmount = fromBalance / 2;
        
        if (toUtilization > HIGH_UTILIZATION_THRESHOLD) {
            uint256 maxSafeAmount = (vaultTotalAssets * 1000) / BASIS_POINTS; // 10% max
            if (baseAmount > maxSafeAmount) {
                baseAmount = maxSafeAmount;
            }
        }
        
        if (fromUtilization < 5000) {
            baseAmount = (fromBalance * 7000) / BASIS_POINTS;
        }
        
        return baseAmount < fromBalance ? baseAmount : fromBalance;
    }
    
    function _estimateProfit(
        uint256 amount,
        uint256 fromRate,
        uint256 toRate,
        uint256 gasCost
    ) internal pure returns (int256) {
        uint256 rateDiff = toRate > fromRate ? toRate - fromRate : 0;
        
        uint256 annualProfit = (amount * rateDiff) / 1e18;
        
        uint256 dailyProfit = annualProfit / 365;
        
        return int256(dailyProfit) - int256(gasCost);
    }
    
    function getRiskScore(address pool, address asset) external view returns (uint256) {
        ILendingPool lendingPool = ILendingPool(pool);
        uint256 utilization = lendingPool.getUtilizationRate(asset);
        
        if (utilization <= 5000) {
            return 0; // Low risk
        } else if (utilization <= HIGH_UTILIZATION_THRESHOLD) {
            return ((utilization - 5000) * 50) / 3000; // Medium risk (0-50)
        } else {
            return 50 + ((utilization - HIGH_UTILIZATION_THRESHOLD) * 50) / 2000; // High risk (50-100)
        }
    }
}
