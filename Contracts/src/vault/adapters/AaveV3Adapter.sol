// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/ILendingPool.sol";
import "../interfaces/IERC20.sol";

interface IAaveV3Pool {
    function supply(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;
    function withdraw(address asset, uint256 amount, address to) external returns (uint256);
    function getReserveData(address asset) external view returns (ReserveData memory);
}

struct ReserveData {
    ReserveConfigurationMap configuration;
    uint128 liquidityIndex;
    uint128 currentLiquidityRate;
    uint128 variableBorrowIndex;
    uint128 currentVariableBorrowRate;
    uint128 currentStableBorrowRate;
    uint40 lastUpdateTimestamp;
    uint16 id;
    address aTokenAddress;
    address stableDebtTokenAddress;
    address variableDebtTokenAddress;
    address interestRateStrategyAddress;
    uint128 accruedToTreasury;
    uint128 unbacked;
    uint128 isolationModeTotalDebt;
}

struct ReserveConfigurationMap {
    uint256 data;
}

contract AaveV3Adapter is ILendingPool {
    IAaveV3Pool public immutable aavePool;
    
    event Deposited(address indexed asset, uint256 amount, address indexed user);
    event Withdrawn(address indexed asset, uint256 amount, address indexed user);
    
    constructor(address _aavePool) {
        aavePool = IAaveV3Pool(_aavePool);
    }
    
    function deposit(address asset, uint256 amount, address onBehalfOf) 
        external 
        override 
        returns (uint256) 
    {
        require(amount > 0, "Zero amount");
        
        IERC20(asset).transferFrom(msg.sender, address(this), amount);
        IERC20(asset).approve(address(aavePool), amount);
        
        aavePool.supply(asset, amount, onBehalfOf, 0);
        
        emit Deposited(asset, amount, onBehalfOf);
        return amount;
    }
    
    function withdraw(address asset, uint256 amount, address to) 
        external 
        override 
        returns (uint256) 
    {
        require(amount > 0, "Zero amount");
        
        uint256 withdrawn = aavePool.withdraw(asset, amount, to);
        
        emit Withdrawn(asset, withdrawn, to);
        return withdrawn;
    }
    
    function getSupplyRate(address asset) external view override returns (uint256) {
        ReserveData memory data = aavePool.getReserveData(asset);
        return uint256(data.currentLiquidityRate);
    }
    
    function getUtilizationRate(address asset) external view override returns (uint256) {
        ReserveData memory data = aavePool.getReserveData(asset);
        
        address aToken = data.aTokenAddress;
        if (aToken == address(0)) return 0;
        
        uint256 totalSupply = IERC20(aToken).totalSupply();
        if (totalSupply == 0) return 0;
        
        uint256 available = IERC20(asset).balanceOf(aToken);
        uint256 totalBorrowed = totalSupply > available ? totalSupply - available : 0;
        
        return (totalBorrowed * 1e18) / totalSupply;
    }
    
    function getTotalSupplied(address asset) external view override returns (uint256) {
        ReserveData memory data = aavePool.getReserveData(asset);
        address aToken = data.aTokenAddress;
        return aToken != address(0) ? IERC20(aToken).totalSupply() : 0;
    }
    
    function getUserBalance(address asset, address user) external view override returns (uint256) {
        ReserveData memory data = aavePool.getReserveData(asset);
        address aToken = data.aTokenAddress;
        return aToken != address(0) ? IERC20(aToken).balanceOf(user) : 0;
    }
}
