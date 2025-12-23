// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILendingPool {
    function deposit(address asset, uint256 amount, address onBehalfOf) external returns (uint256);
    function withdraw(address asset, uint256 amount, address to) external returns (uint256);
    function getSupplyRate(address asset) external view returns (uint256);
    function getUtilizationRate(address asset) external view returns (uint256);
    function getTotalSupplied(address asset) external view returns (uint256);
    function getUserBalance(address asset, address user) external view returns (uint256);
}
