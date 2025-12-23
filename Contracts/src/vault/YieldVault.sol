// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IERC4626.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/ILendingPool.sol";

contract YieldVault is IERC4626 {
    IERC20 private immutable _asset;
    
    string private _name;
    string private _symbol;
    uint8 private constant _decimals = 18;
    
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    address public owner;
    address public rebalancer;
    
    ILendingPool[] public lendingPools;
    mapping(address => bool) public isActivePool;
    mapping(address => uint256) public poolAllocations;
    
    uint256 public constant MAX_POOLS = 5;
    uint256 public constant MAX_ALLOCATION_PER_POOL = 5000; // 50% in basis points
    uint256 public constant BASIS_POINTS = 10000;
    
    bool public paused;
    
    event PoolAdded(address indexed pool);
    event PoolRemoved(address indexed pool);
    event Rebalanced(address indexed fromPool, address indexed toPool, uint256 amount);
    event RebalancerUpdated(address indexed oldRebalancer, address indexed newRebalancer);
    event Paused(address indexed by);
    event Unpaused(address indexed by);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    modifier onlyRebalancer() {
        require(msg.sender == rebalancer, "Not rebalancer");
        _;
    }
    
    modifier whenNotPaused() {
        require(!paused, "Paused");
        _;
    }
    
    constructor(
        address asset_,
        string memory name_,
        string memory symbol_
    ) {
        _asset = IERC20(asset_);
        _name = name_;
        _symbol = symbol_;
        owner = msg.sender;
    }
    
    function asset() external view override returns (address) {
        return address(_asset);
    }
    
    // ERC20 Basic Functions
    function name() external view returns (string memory) {
        return _name;
    }
    
    function symbol() external view returns (string memory) {
        return _symbol;
    }
    
    function decimals() external pure override returns (uint8) {
        return _decimals;
    }
    
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address to, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }
    
    function allowance(address owner_, address spender) external view override returns (uint256) {
        return _allowances[owner_][spender];
    }
    
    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) external override returns (bool) {
        _spendAllowance(from, msg.sender, amount);
        _transfer(from, to, amount);
        return true;
    }
    
    // ERC4626 Functions
    function totalAssets() public view override returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < lendingPools.length; i++) {
            if (isActivePool[address(lendingPools[i])]) {
                total += lendingPools[i].getUserBalance(address(_asset), address(this));
            }
        }
        total += _asset.balanceOf(address(this));
        return total;
    }
    
    function convertToShares(uint256 assets) public view override returns (uint256) {
        uint256 supply = _totalSupply;
        return supply == 0 ? assets : (assets * supply) / totalAssets();
    }
    
    function convertToAssets(uint256 shares) public view override returns (uint256) {
        uint256 supply = _totalSupply;
        return supply == 0 ? shares : (shares * totalAssets()) / supply;
    }
    
    function maxDeposit(address) external pure override returns (uint256) {
        return type(uint256).max;
    }
    
    function previewDeposit(uint256 assets) external view override returns (uint256) {
        return convertToShares(assets);
    }
    
    function deposit(uint256 assets, address receiver) external override whenNotPaused returns (uint256 shares) {
        require(assets > 0, "Zero assets");
        
        shares = convertToShares(assets);
        require(shares > 0, "Zero shares");
        
        _asset.transferFrom(msg.sender, address(this), assets);
        
        _mint(receiver, shares);
        
        emit Deposit(msg.sender, receiver, assets, shares);
    }
    
    function maxMint(address) external pure override returns (uint256) {
        return type(uint256).max;
    }
    
    function previewMint(uint256 shares) external view override returns (uint256) {
        uint256 supply = _totalSupply;
        return supply == 0 ? shares : (shares * totalAssets() + supply - 1) / supply;
    }
    
    function mint(uint256 shares, address receiver) external override whenNotPaused returns (uint256 assets) {
        require(shares > 0, "Zero shares");
        
        uint256 supply = _totalSupply;
        assets = supply == 0 ? shares : (shares * totalAssets() + supply - 1) / supply;
        
        _asset.transferFrom(msg.sender, address(this), assets);
        
        _mint(receiver, shares);
        
        emit Deposit(msg.sender, receiver, assets, shares);
    }
    
    function maxWithdraw(address owner_) external view override returns (uint256) {
        return convertToAssets(_balances[owner_]);
    }
    
    function previewWithdraw(uint256 assets) external view override returns (uint256) {
        uint256 supply = _totalSupply;
        return supply == 0 ? assets : (assets * supply + totalAssets() - 1) / totalAssets();
    }
    
    function withdraw(uint256 assets, address receiver, address owner_) 
        external 
        override 
        whenNotPaused 
        returns (uint256 shares) 
    {
        require(assets > 0, "Zero assets");
        
        uint256 supply = _totalSupply;
        shares = supply == 0 ? assets : (assets * supply + totalAssets() - 1) / totalAssets();
        
        if (msg.sender != owner_) {
            _spendAllowance(owner_, msg.sender, shares);
        }
        
        _burn(owner_, shares);
        
        _withdrawFromPools(assets);
        
        _asset.transfer(receiver, assets);
        
        emit Withdraw(msg.sender, receiver, owner_, assets, shares);
    }
    
    function maxRedeem(address owner_) external view override returns (uint256) {
        return _balances[owner_];
    }
    
    function previewRedeem(uint256 shares) external view override returns (uint256) {
        return convertToAssets(shares);
    }
    
    function redeem(uint256 shares, address receiver, address owner_) 
        external 
        override 
        whenNotPaused 
        returns (uint256 assets) 
    {
        require(shares > 0, "Zero shares");
        
        if (msg.sender != owner_) {
            _spendAllowance(owner_, msg.sender, shares);
        }
        
        assets = convertToAssets(shares);
        require(assets > 0, "Zero assets");
        
        _burn(owner_, shares);
        
        _withdrawFromPools(assets);
        
        _asset.transfer(receiver, assets);
        
        emit Withdraw(msg.sender, receiver, owner_, assets, shares);
    }
    
    // Vault Management Functions
    function addLendingPool(address pool) external onlyOwner {
        require(lendingPools.length < MAX_POOLS, "Max pools reached");
        require(!isActivePool[pool], "Pool already active");
        
        lendingPools.push(ILendingPool(pool));
        isActivePool[pool] = true;
        
        emit PoolAdded(pool);
    }
    
    function removeLendingPool(address pool) external onlyOwner {
        require(isActivePool[pool], "Pool not active");
        
        uint256 balance = ILendingPool(pool).getUserBalance(address(_asset), address(this));
        if (balance > 0) {
            ILendingPool(pool).withdraw(address(_asset), balance, address(this));
        }
        
        isActivePool[pool] = false;
        poolAllocations[pool] = 0;
        
        emit PoolRemoved(pool);
    }
    
    function setRebalancer(address newRebalancer) external onlyOwner {
        emit RebalancerUpdated(rebalancer, newRebalancer);
        rebalancer = newRebalancer;
    }
    
    function rebalance(
        address fromPool,
        address toPool,
        uint256 amount
    ) external onlyRebalancer whenNotPaused {
        require(isActivePool[fromPool], "From pool not active");
        require(isActivePool[toPool], "To pool not active");
        require(amount > 0, "Zero amount");
        
        ILendingPool(fromPool).withdraw(address(_asset), amount, address(this));
        
        _asset.approve(toPool, amount);
        ILendingPool(toPool).deposit(address(_asset), amount, address(this));
        
        poolAllocations[fromPool] -= amount;
        poolAllocations[toPool] += amount;
        
        uint256 totalAssets_ = totalAssets();
        require(
            poolAllocations[toPool] * BASIS_POINTS <= totalAssets_ * MAX_ALLOCATION_PER_POOL,
            "Exceeds max allocation"
        );
        
        emit Rebalanced(fromPool, toPool, amount);
    }
    
    function depositToPool(address pool, uint256 amount) external onlyRebalancer whenNotPaused {
        require(isActivePool[pool], "Pool not active");
        require(amount > 0, "Zero amount");
        require(_asset.balanceOf(address(this)) >= amount, "Insufficient balance");
        
        _asset.approve(pool, amount);
        ILendingPool(pool).deposit(address(_asset), amount, address(this));
        
        poolAllocations[pool] += amount;
        
        uint256 totalAssets_ = totalAssets();
        require(
            poolAllocations[pool] * BASIS_POINTS <= totalAssets_ * MAX_ALLOCATION_PER_POOL,
            "Exceeds max allocation"
        );
    }
    
    function withdrawFromPool(address pool, uint256 amount) external onlyRebalancer whenNotPaused {
        require(isActivePool[pool], "Pool not active");
        require(amount > 0, "Zero amount");
        
        ILendingPool(pool).withdraw(address(_asset), amount, address(this));
        
        poolAllocations[pool] -= amount;
    }
    
    function pause() external onlyOwner {
        paused = true;
        emit Paused(msg.sender);
    }
    
    function unpause() external onlyOwner {
        paused = false;
        emit Unpaused(msg.sender);
    }
    
    // View Functions
    function getPoolCount() external view returns (uint256) {
        return lendingPools.length;
    }
    
    function getPool(uint256 index) external view returns (address) {
        return address(lendingPools[index]);
    }
    
    function getPoolYield(address pool) external view returns (uint256) {
        require(isActivePool[pool], "Pool not active");
        return ILendingPool(pool).getSupplyRate(address(_asset));
    }
    
    function getPoolUtilization(address pool) external view returns (uint256) {
        require(isActivePool[pool], "Pool not active");
        return ILendingPool(pool).getUtilizationRate(address(_asset));
    }
    
    function getPoolBalance(address pool) external view returns (uint256) {
        require(isActivePool[pool], "Pool not active");
        return ILendingPool(pool).getUserBalance(address(_asset), address(this));
    }
    
    // Internal Functions
    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "Transfer from zero");
        require(to != address(0), "Transfer to zero");
        
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "Insufficient balance");
        
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }
        
        emit Transfer(from, to, amount);
    }
    
    function _mint(address to, uint256 amount) internal {
        require(to != address(0), "Mint to zero");
        
        _totalSupply += amount;
        unchecked {
            _balances[to] += amount;
        }
        
        emit Transfer(address(0), to, amount);
    }
    
    function _burn(address from, uint256 amount) internal {
        require(from != address(0), "Burn from zero");
        
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "Insufficient balance");
        
        unchecked {
            _balances[from] = fromBalance - amount;
            _totalSupply -= amount;
        }
        
        emit Transfer(from, address(0), amount);
    }
    
    function _approve(address owner_, address spender, uint256 amount) internal {
        require(owner_ != address(0), "Approve from zero");
        require(spender != address(0), "Approve to zero");
        
        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }
    
    function _spendAllowance(address owner_, address spender, uint256 amount) internal {
        uint256 currentAllowance = _allowances[owner_][spender];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "Insufficient allowance");
            unchecked {
                _approve(owner_, spender, currentAllowance - amount);
            }
        }
    }
    
    function _withdrawFromPools(uint256 assets) internal {
        uint256 available = _asset.balanceOf(address(this));
        if (available >= assets) {
            return;
        }
        
        uint256 needed = assets - available;
        
        for (uint256 i = 0; i < lendingPools.length && needed > 0; i++) {
            if (!isActivePool[address(lendingPools[i])]) continue;
            
            uint256 poolBalance = lendingPools[i].getUserBalance(address(_asset), address(this));
            uint256 toWithdraw = poolBalance < needed ? poolBalance : needed;
            
            if (toWithdraw > 0) {
                lendingPools[i].withdraw(address(_asset), toWithdraw, address(this));
                poolAllocations[address(lendingPools[i])] -= toWithdraw;
                needed -= toWithdraw;
            }
        }
        
        require(needed == 0, "Insufficient liquidity");
    }
}
