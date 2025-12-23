// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../../lib/reactive-lib/src/interfaces/ISystemContract.sol';
import '../../lib/reactive-lib/src/abstract-base/AbstractPausableReactive.sol';
import '../../lib/reactive-lib/src/interfaces/IReactive.sol';
import './interfaces/ILendingPool.sol';
import './RebalanceStrategy.sol';

contract ReactiveRebalancer is IReactive, AbstractPausableReactive {
    
    uint64 private constant GAS_LIMIT = 3000000;
    address public constant SERVICE = 0x0000000000000000000000000000000000fffFfF;
    
    uint256 private immutable ORIGIN_CHAIN_ID;
    
    address public immutable vault;
    address public immutable asset;
    address public immutable strategy;
    
    address[] public monitoredPools;
    mapping(address => bool) public isMonitored;
    
    uint256 public lastRebalanceBlock;
    uint256 public totalRebalances;
    uint256 public checkInterval = 100;
    
    bytes32 private constant RESERVE_DATA_UPDATED_TOPIC = 
        0x804c9b842b2748a22bb64b345453a3de7ca54a6ca45ce00d415894979e22897a;
    
    bytes32 private constant RATE_UPDATE_TOPIC = 
        0x1d2b0bda21d56b8bd12d4f94ebacffdfb35f5e226f84b461103bb8beab6353be;
    
    event RebalanceTriggered(
        address indexed fromPool,
        address indexed toPool,
        uint256 amount,
        int256 expectedProfit
    );
    
    event PoolAdded(address indexed pool);
    event PoolRemoved(address indexed pool);
    event MonitoringActive(address indexed vault, uint256 poolCount);
    event PeriodicCheckTriggered(uint256 blockNumber);
    
    modifier onlyVault() {
        require(msg.sender == vault, "Only vault");
        _;
    }
    
    modifier whenNotPaused() {
        require(!paused, "Contract paused");
        _;
    }
    
    constructor(
        address _vault,
        address _asset,
        address _strategy,
        address[] memory _pools,
        uint256 _originChainId
    ) payable {
        require(_vault != address(0), "Invalid vault");
        require(_asset != address(0), "Invalid asset");
        require(_strategy != address(0), "Invalid strategy");
        require(_pools.length > 0, "No pools");
        
        vault = _vault;
        asset = _asset;
        strategy = _strategy;
        ORIGIN_CHAIN_ID = _originChainId;
        
        service = ISystemContract(payable(SERVICE));
        
        for (uint256 i = 0; i < _pools.length; i++) {
            monitoredPools.push(_pools[i]);
            isMonitored[_pools[i]] = true;
        }
        
        emit MonitoringActive(_vault, _pools.length);
    }
    
    function getPausableSubscriptions() internal view override returns (Subscription[] memory) {
        Subscription[] memory subs = new Subscription[](monitoredPools.length * 2);
        uint256 index = 0;
        
        for (uint256 i = 0; i < monitoredPools.length; i++) {
            if (isMonitored[monitoredPools[i]]) {
                subs[index++] = Subscription({
                    chain_id: ORIGIN_CHAIN_ID,
                    _contract: monitoredPools[i],
                    topic_0: uint256(RESERVE_DATA_UPDATED_TOPIC),
                    topic_1: REACTIVE_IGNORE,
                    topic_2: REACTIVE_IGNORE,
                    topic_3: REACTIVE_IGNORE
                });
                
                subs[index++] = Subscription({
                    chain_id: ORIGIN_CHAIN_ID,
                    _contract: monitoredPools[i],
                    topic_0: uint256(RATE_UPDATE_TOPIC),
                    topic_1: REACTIVE_IGNORE,
                    topic_2: REACTIVE_IGNORE,
                    topic_3: REACTIVE_IGNORE
                });
            }
        }
        
        // Resize array to actual size
        Subscription[] memory result = new Subscription[](index);
        for (uint256 i = 0; i < index; i++) {
            result[i] = subs[i];
        }
        
        return result;
    }
    
    function activateSubscriptions() external {
        require(!vm, "Reactive Network only");
        
        for (uint256 i = 0; i < monitoredPools.length; i++) {
            service.subscribe(
                ORIGIN_CHAIN_ID,
                monitoredPools[i],
                uint256(RESERVE_DATA_UPDATED_TOPIC),
                REACTIVE_IGNORE,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE
            );
            
            service.subscribe(
                ORIGIN_CHAIN_ID,
                monitoredPools[i],
                uint256(RATE_UPDATE_TOPIC),
                REACTIVE_IGNORE,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE
            );
            
            emit PoolAdded(monitoredPools[i]);
        }
    }
    
    function react(LogRecord calldata log) external vmOnly {
        require(log.chain_id == ORIGIN_CHAIN_ID, "Wrong chain");
        require(isMonitored[log._contract], "Pool not monitored");
        
        _checkAndRebalance();
    }
    
    function periodicCheck() external {
        if (block.number >= lastRebalanceBlock + checkInterval) {
            emit PeriodicCheckTriggered(block.number);
            _checkAndRebalance();
        }
    }
    
    function _checkAndRebalance() internal whenNotPaused {
        lastRebalanceBlock = block.number;
        
        RebalanceStrategy strategyContract = RebalanceStrategy(strategy);
        
        uint256 vaultTotalAssets = _getVaultTotalAssets();
        
        (
            bool shouldRebal,
            address fromPool,
            address toPool,
            uint256 amount,
            int256 expectedProfit
        ) = strategyContract.findBestRebalance(
            monitoredPools,
            asset,
            vaultTotalAssets
        );
        
        if (!shouldRebal) {
            return;
        }
        
        bytes memory payload = abi.encodeWithSignature(
            "rebalance(address,address,uint256)",
            fromPool,
            toPool,
            amount
        );
        
        emit Callback(ORIGIN_CHAIN_ID, vault, GAS_LIMIT, payload);
        
        strategyContract.recordRebalance(fromPool);
        strategyContract.recordRebalance(toPool);
        
        totalRebalances++;
        
        emit RebalanceTriggered(fromPool, toPool, amount, expectedProfit);
    }
    
    function _getVaultTotalAssets() internal view returns (uint256) {
        uint256 total = 0;
        
        for (uint256 i = 0; i < monitoredPools.length; i++) {
            if (!isMonitored[monitoredPools[i]]) continue;
            
            try ILendingPool(monitoredPools[i]).getUserBalance(asset, vault) returns (uint256 balance) {
                total += balance;
            } catch {
                continue;
            }
        }
        
        return total;
    }
    
    function addPool(address pool) external onlyVault {
        require(!isMonitored[pool], "Already monitored");
        
        monitoredPools.push(pool);
        isMonitored[pool] = true;
        
        if (!vm) {
            service.subscribe(
                ORIGIN_CHAIN_ID,
                pool,
                uint256(RESERVE_DATA_UPDATED_TOPIC),
                REACTIVE_IGNORE,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE
            );
            
            service.subscribe(
                ORIGIN_CHAIN_ID,
                pool,
                uint256(RATE_UPDATE_TOPIC),
                REACTIVE_IGNORE,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE
            );
        }
        
        emit PoolAdded(pool);
    }
    
    function removePool(address pool) external onlyVault {
        require(isMonitored[pool], "Not monitored");
        
        isMonitored[pool] = false;
        
        if (!vm) {
            service.unsubscribe(
                ORIGIN_CHAIN_ID,
                pool,
                uint256(RESERVE_DATA_UPDATED_TOPIC),
                REACTIVE_IGNORE,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE
            );
            
            service.unsubscribe(
                ORIGIN_CHAIN_ID,
                pool,
                uint256(RATE_UPDATE_TOPIC),
                REACTIVE_IGNORE,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE
            );
        }
        
        emit PoolRemoved(pool);
    }
    
    function setCheckInterval(uint256 newInterval) external onlyVault {
        require(newInterval > 0, "Invalid interval");
        checkInterval = newInterval;
    }
    
    function getMonitoringStatus() external view returns (
        uint256 poolCount,
        uint256 lastCheck,
        uint256 rebalanceCount,
        bool isPaused
    ) {
        return (
            monitoredPools.length,
            lastRebalanceBlock,
            totalRebalances,
            paused
        );
    }
    
    function getPoolAtIndex(uint256 index) external view returns (address) {
        require(index < monitoredPools.length, "Index out of bounds");
        return monitoredPools[index];
    }
}
