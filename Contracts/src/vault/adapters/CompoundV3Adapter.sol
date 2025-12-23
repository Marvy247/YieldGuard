// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/ILendingPool.sol";
import "../interfaces/IERC20.sol";

interface IComet {
    function supply(address asset, uint256 amount) external;
    function withdraw(address asset, uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
    function getSupplyRate(uint256 utilization) external view returns (uint64);
    function getUtilization() external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function totalBorrow() external view returns (uint256);
    function baseToken() external view returns (address);
}

contract CompoundV3Adapter is ILendingPool {
    IComet public immutable comet;
    address public immutable baseAsset;
    
    event Deposited(address indexed asset, uint256 amount, address indexed user);
    event Withdrawn(address indexed asset, uint256 amount, address indexed user);
    
    constructor(address _comet) {
        comet = IComet(_comet);
        baseAsset = comet.baseToken();
    }
    
    function deposit(address asset, uint256 amount, address onBehalfOf) 
        external 
        override 
        returns (uint256) 
    {
        require(amount > 0, "Zero amount");
        require(asset == baseAsset, "Asset not supported");
        
        IERC20(asset).transferFrom(msg.sender, address(this), amount);
        IERC20(asset).approve(address(comet), amount);
        
        comet.supply(asset, amount);
        
        emit Deposited(asset, amount, onBehalfOf);
        return amount;
    }
    
    function withdraw(address asset, uint256 amount, address to) 
        external 
        override 
        returns (uint256) 
    {
        require(amount > 0, "Zero amount");
        require(asset == baseAsset, "Asset not supported");
        
        comet.withdraw(asset, amount);
        IERC20(asset).transfer(to, amount);
        
        emit Withdrawn(asset, amount, to);
        return amount;
    }
    
    function getSupplyRate(address asset) external view override returns (uint256) {
        require(asset == baseAsset, "Asset not supported");
        
        uint256 utilization = comet.getUtilization();
        uint64 rate = comet.getSupplyRate(utilization);
        
        return uint256(rate);
    }
    
    function getUtilizationRate(address asset) external view override returns (uint256) {
        require(asset == baseAsset, "Asset not supported");
        return comet.getUtilization();
    }
    
    function getTotalSupplied(address asset) external view override returns (uint256) {
        require(asset == baseAsset, "Asset not supported");
        return comet.totalSupply();
    }
    
    function getUserBalance(address asset, address user) external view override returns (uint256) {
        require(asset == baseAsset, "Asset not supported");
        return comet.balanceOf(user);
    }
}
