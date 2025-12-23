// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/ILendingPool.sol";
import "../interfaces/IERC20.sol";

contract MockLendingPool is ILendingPool {
    mapping(address => mapping(address => uint256)) public userBalances;
    mapping(address => uint256) public totalDeposits;
    
    uint256 public supplyRate; // APY in basis points (e.g., 500 = 5%)
    uint256 public utilizationRate; // in basis points (e.g., 8000 = 80%)
    
    event RatesUpdated(uint256 newSupplyRate, uint256 newUtilization);
    
    constructor(uint256 _initialRate, uint256 _initialUtilization) {
        supplyRate = _initialRate;
        utilizationRate = _initialUtilization;
    }
    
    function deposit(address asset, uint256 amount, address onBehalfOf) 
        external 
        override 
        returns (uint256) 
    {
        require(amount > 0, "Zero amount");
        
        IERC20(asset).transferFrom(msg.sender, address(this), amount);
        
        userBalances[asset][onBehalfOf] += amount;
        totalDeposits[asset] += amount;
        
        return amount;
    }
    
    function withdraw(address asset, uint256 amount, address to) 
        external 
        override 
        returns (uint256) 
    {
        require(amount > 0, "Zero amount");
        require(userBalances[asset][msg.sender] >= amount, "Insufficient balance");
        
        userBalances[asset][msg.sender] -= amount;
        totalDeposits[asset] -= amount;
        
        IERC20(asset).transfer(to, amount);
        
        return amount;
    }
    
    function getSupplyRate(address) external view override returns (uint256) {
        return supplyRate;
    }
    
    function getUtilizationRate(address) external view override returns (uint256) {
        return utilizationRate;
    }
    
    function getTotalSupplied(address asset) external view override returns (uint256) {
        return totalDeposits[asset];
    }
    
    function getUserBalance(address asset, address user) external view override returns (uint256) {
        return userBalances[asset][user];
    }
    
    function setRates(uint256 newSupplyRate, uint256 newUtilization) external {
        supplyRate = newSupplyRate;
        utilizationRate = newUtilization;
        emit RatesUpdated(newSupplyRate, newUtilization);
    }
}
