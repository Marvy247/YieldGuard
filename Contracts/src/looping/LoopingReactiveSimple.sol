// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../../lib/reactive-lib/src/interfaces/ISystemContract.sol';
import '../../lib/reactive-lib/src/abstract-base/AbstractPausableReactive.sol';
import '../../lib/reactive-lib/src/interfaces/IReactive.sol';
import './IAaveV3Pool.sol';

/**
 * @title LoopingReactiveSimple
 * @notice Simplified version for deployment testing
 * @dev Subscriptions are done manually after deployment
 */
contract LoopingReactiveSimple is IReactive, AbstractPausableReactive {
    
    uint64 private constant GAS_LIMIT = 2000000;
    address public constant SERVICE = 0x0000000000000000000000000000000000fffFfF;
    
    uint256 private immutable ORIGIN_CHAIN_ID;
    
    address public immutable loopingCallback;
    address public immutable aavePool;
    address public immutable monitoredPosition;
    
    uint256 public warningThreshold = 2e18;
    uint256 public dangerThreshold = 15e17;
    uint256 public safeThreshold = 3e18;
    
    uint256 public lastCheckedBlock;
    uint256 public lastHealthFactor;
    uint256 public alertCount;
    bool public subscriptionsActive;
    
    bytes32 private constant SUPPLY_TOPIC = 0x2b627736bca15cd5381dcf80b0bf11fd197d01a037c52b927a881a10fb73ba61;
    bytes32 private constant BORROW_TOPIC = 0xb3d084820fb1a9decffb176436bd02558d15fac9b0ddfed8c465bc7359d7dce0;
    bytes32 private constant REPAY_TOPIC = 0xa534c8dbe71f871f9f3530e97a74601fea17b426cae02e1c5aee42c96c784051;
    
    event HealthFactorChecked(uint256 healthFactor, uint256 blockNumber);
    event WarningTriggered(uint256 healthFactor, uint256 totalCollateral, uint256 totalDebt);
    event EmergencyTriggered(uint256 healthFactor, uint256 totalCollateral, uint256 totalDebt);
    event MonitoringActive(address indexed position, address indexed callback);
    event SubscriptionsActivated();

    constructor(
        address _loopingCallback,
        address _aavePool,
        address _monitoredPosition,
        uint256 _originChainId
    ) payable {
        require(_loopingCallback != address(0), "Invalid callback");
        require(_aavePool != address(0), "Invalid Aave pool");
        require(_monitoredPosition != address(0), "Invalid position");
        
        loopingCallback = _loopingCallback;
        aavePool = _aavePool;
        monitoredPosition = _monitoredPosition;
        ORIGIN_CHAIN_ID = _originChainId;
        
        service = ISystemContract(payable(SERVICE));
        
        // DON'T subscribe here - do it manually after deployment
        emit MonitoringActive(_monitoredPosition, _loopingCallback);
    }

    /**
     * @notice Manually activate subscriptions after deployment
     * @dev Call this after the contract is funded and ready
     */
    function activateSubscriptions() external {
        require(!subscriptionsActive, "Already active");
        require(!vm, "Reactive Network only");
        
        // Subscribe to Supply events
        service.subscribe(
            ORIGIN_CHAIN_ID,
            aavePool,
            uint256(SUPPLY_TOPIC),
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        
        // Subscribe to Borrow events  
        service.subscribe(
            ORIGIN_CHAIN_ID,
            aavePool,
            uint256(BORROW_TOPIC),
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        
        // Subscribe to Repay events
        service.subscribe(
            ORIGIN_CHAIN_ID,
            aavePool,
            uint256(REPAY_TOPIC),
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        
        subscriptionsActive = true;
        emit SubscriptionsActivated();
    }

    function getPausableSubscriptions() internal view override returns (Subscription[] memory) {
        Subscription[] memory subs = new Subscription[](3);
        
        subs[0] = Subscription(
            ORIGIN_CHAIN_ID,
            aavePool,
            uint256(SUPPLY_TOPIC),
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        
        subs[1] = Subscription(
            ORIGIN_CHAIN_ID,
            aavePool,
            uint256(BORROW_TOPIC),
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        
        subs[2] = Subscription(
            ORIGIN_CHAIN_ID,
            aavePool,
            uint256(REPAY_TOPIC),
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        
        return subs;
    }

    /**
     * @notice THE CORE REACTIVE FUNCTION
     */
    function react(LogRecord calldata log) external vmOnly {
        lastCheckedBlock = log.block_number;
        
        (
            uint256 totalCollateral,
            uint256 totalDebt,
            ,
            ,
            ,
            uint256 healthFactor
        ) = IAaveV3Pool(aavePool).getUserAccountData(monitoredPosition);
        
        lastHealthFactor = healthFactor;
        emit HealthFactorChecked(healthFactor, log.block_number);
        
        if (totalDebt == 0) return;
        
        if (healthFactor < dangerThreshold && healthFactor > 1e18) {
            alertCount++;
            emit EmergencyTriggered(healthFactor, totalCollateral, totalDebt);
            
            bytes memory payload = abi.encodeWithSignature("callback(address)", address(this));
            emit Callback(ORIGIN_CHAIN_ID, loopingCallback, GAS_LIMIT, payload);
        }
        else if (healthFactor < warningThreshold && healthFactor >= dangerThreshold) {
            alertCount++;
            emit WarningTriggered(healthFactor, totalCollateral, totalDebt);
            
            bytes memory payload = abi.encodeWithSignature("callback(address)", address(this));
            emit Callback(ORIGIN_CHAIN_ID, loopingCallback, GAS_LIMIT, payload);
        }
    }

    receive() external payable override(AbstractPayer, IPayer) {
        // Accept payments
    }
}
