// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./YieldVault.sol";
import "./RebalanceStrategy.sol";
import "./ReactiveRebalancer.sol";

contract VaultFactory {
    address public owner;
    
    struct VaultInfo {
        address vault;
        address strategy;
        address rebalancer;
        address asset;
        uint256 createdAt;
        bool isActive;
    }
    
    mapping(address => VaultInfo[]) public userVaults;
    VaultInfo[] public allVaults;
    
    uint256 public constant DEFAULT_YIELD_THRESHOLD = 100; // 1% in bps
    uint256 public constant DEFAULT_MIN_AMOUNT = 1e18; // 1 token
    uint256 public constant DEFAULT_COOLDOWN = 1 hours;
    uint256 public constant DEFAULT_GAS_COST = 0.01 ether;
    
    event VaultCreated(
        address indexed creator,
        address vault,
        address strategy,
        address rebalancer,
        address asset
    );
    
    event VaultDeactivated(address indexed vault, address indexed owner);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    function createVault(
        address asset,
        string memory vaultName,
        string memory vaultSymbol,
        address[] memory initialPools,
        uint256 originChainId
    ) external payable returns (
        address vaultAddress,
        address strategyAddress,
        address rebalancerAddress
    ) {
        require(asset != address(0), "Invalid asset");
        require(initialPools.length > 0, "No pools provided");
        require(initialPools.length <= 5, "Too many pools");
        
        YieldVault vault = new YieldVault(asset, vaultName, vaultSymbol);
        vaultAddress = address(vault);
        
        RebalanceStrategy strategy = new RebalanceStrategy(
            DEFAULT_YIELD_THRESHOLD,
            DEFAULT_MIN_AMOUNT,
            DEFAULT_COOLDOWN,
            DEFAULT_GAS_COST
        );
        strategyAddress = address(strategy);
        
        ReactiveRebalancer rebalancer = new ReactiveRebalancer{value: msg.value}(
            vaultAddress,
            asset,
            strategyAddress,
            initialPools,
            originChainId
        );
        rebalancerAddress = address(rebalancer);
        
        vault.setRebalancer(rebalancerAddress);
        
        for (uint256 i = 0; i < initialPools.length; i++) {
            vault.addLendingPool(initialPools[i]);
        }
        
        VaultInfo memory info = VaultInfo({
            vault: vaultAddress,
            strategy: strategyAddress,
            rebalancer: rebalancerAddress,
            asset: asset,
            createdAt: block.timestamp,
            isActive: true
        });
        
        userVaults[msg.sender].push(info);
        allVaults.push(info);
        
        emit VaultCreated(
            msg.sender,
            vaultAddress,
            strategyAddress,
            rebalancerAddress,
            asset
        );
    }
    
    function deactivateVault(uint256 index) external {
        require(index < userVaults[msg.sender].length, "Invalid index");
        
        VaultInfo storage info = userVaults[msg.sender][index];
        require(info.isActive, "Already deactivated");
        
        info.isActive = false;
        
        for (uint256 i = 0; i < allVaults.length; i++) {
            if (allVaults[i].vault == info.vault) {
                allVaults[i].isActive = false;
                break;
            }
        }
        
        emit VaultDeactivated(info.vault, msg.sender);
    }
    
    function getUserVaults(address user) external view returns (VaultInfo[] memory) {
        return userVaults[user];
    }
    
    function getUserVaultCount(address user) external view returns (uint256) {
        return userVaults[user].length;
    }
    
    function getAllVaults() external view returns (VaultInfo[] memory) {
        return allVaults;
    }
    
    function getTotalVaultCount() external view returns (uint256) {
        return allVaults.length;
    }
    
    function getActiveVaultCount() external view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < allVaults.length; i++) {
            if (allVaults[i].isActive) {
                count++;
            }
        }
        return count;
    }
}
