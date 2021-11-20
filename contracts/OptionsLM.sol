// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
import "./SafeMath8.sol";
import "./ERC721.sol";

interface erc20 {
    function transfer(address recipient, uint amount) external returns (bool);
    function balanceOf(address) external view returns (uint);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
}

interface v3oracle {
    function assetToAsset(address from, uint amount, address to, uint twap_duration) external view returns (uint);
}

contract OptionsLM is ERC721 {
    using SafeMath8 for uint256;

    address immutable public reward;
    address immutable public stake;
    address immutable public buyWith;
    address immutable public treasury;

    v3oracle constant oracle = v3oracle(0x0F1f5A87f99f0918e6C81F16E59F3518698221Ff);

    uint constant DURATION = 7 days;
    uint constant PRECISION = 10 ** 18;
    uint constant TWAP_PERIOD = 3600;
    uint constant OPTION_EXPIRY = 30 days;

    uint rewardRate;
    uint periodFinish;
    uint lastUpdateTime;
    uint rewardPerTokenStored;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    struct option {
        uint amount;
        uint strike;
        uint expiry;
        bool exercised;
    }

    option[] public options;
    uint public nextIndex;

    uint _totalSupply;
    mapping(address => uint) public _balanceOf;

    event Deposit(address indexed from, uint amount);
    event Withdraw(address indexed to, uint amount);
    event Created(address indexed owner, uint amount, uint strike, uint expiry, uint id);
    event Redeem(address indexed from, address indexed owner, uint amount, uint strike, uint id);

    constructor(
        address _reward,
        address _stake,
        address _buyWith,
        address _treasury,
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
        reward = _reward;
        stake = _stake;
        buyWith = _buyWith;
        treasury = _treasury;
    }

    function lastTimeRewardApplicable() public view returns (uint) {
        return block.timestamp < periodFinish ? block.timestamp : periodFinish;
    }

    function rewardPerToken() public view returns (uint) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored + ((lastTimeRewardApplicable() - lastUpdateTime) * rewardRate * PRECISION / _totalSupply);
    }

    function earned(address account) public view returns (uint) {
        return (_balanceOf[account] * (rewardPerToken() - userRewardPerTokenPaid[account]) / PRECISION) + rewards[account];
    }

    function getRewardForDuration() external view returns (uint) {
        return rewardRate * DURATION;
    }

    function deposit(address recipient) external {
        _deposit(erc20(stake).balanceOf(msg.sender), recipient);
    }

    function deposit() external {
        _deposit(erc20(stake).balanceOf(msg.sender), msg.sender);
    }

    function deposit(uint amount) external {
        _deposit(amount, msg.sender);
    }

    function deposit(uint amount, address recipient) external {
        _deposit(amount, recipient);
    }

    function _deposit(uint amount, address to) internal update(to) {
        _totalSupply += amount;
        _balanceOf[to] += amount;
        _safeTransferFrom(stake, msg.sender, address(this), amount);
        emit Deposit(msg.sender, amount);
    }

    function withdraw() external {
        _withdraw(_balanceOf[msg.sender], msg.sender);
    }

    function withdraw(address recipient) external {
        _withdraw(_balanceOf[msg.sender], recipient);
    }

    function withdraw(uint amount, address recipient) external {
        _withdraw(amount, recipient);
    }

    function withdraw(uint amount) external {
        _withdraw(amount, msg.sender);
    }

    function _withdraw(uint amount, address to) internal update(msg.sender) {
        _totalSupply -= amount;
        _balanceOf[msg.sender] -= amount;
        _safeTransfer(stake, to, amount);
        emit Withdraw(msg.sender, amount);
    }

    function price(uint amount) public view returns(uint) {
        //return oracle.assetToAsset(reward, amount, buyWith, 3600);
        uint result = amount.mul(3); // to test price is 3 SGT TODO UNDO
        return result;
    }

    function _claim(uint amount) internal {
        uint _strike = price(amount);
        uint _expiry = block.timestamp + OPTION_EXPIRY;
        options.push(option(amount, _strike, _expiry, false));
        _safeMint(msg.sender, nextIndex);
        emit Created(msg.sender, amount, _strike, _expiry, nextIndex);
        nextIndex++;
    }

    function redeem(uint id) external {
        require(_isApprovedOrOwner(msg.sender, id));
        option storage _opt = options[id];
        require(_opt.expiry >= block.timestamp && !_opt.exercised);
        _opt.exercised = true;
        _safeTransferFrom(buyWith, msg.sender, treasury, _opt.strike);
        _safeTransfer(reward, msg.sender, _opt.amount);
        emit Redeem(msg.sender, msg.sender, _opt.amount, _opt.strike, id);
    }

    function getReward() public update(msg.sender) {
        uint _reward = rewards[msg.sender];
        if (_reward > 0) {
            rewards[msg.sender] = 0;
            _claim(_reward);
        }
    }

    function exit() external {
        _withdraw(_balanceOf[msg.sender], msg.sender);
        getReward();
    }

    function notify(uint amount) external update(address(0)) {
        _safeTransferFrom(reward, msg.sender, address(this), amount);
        if (block.timestamp >= periodFinish) {
            rewardRate = amount / DURATION;
        } else {
            uint _remaining = periodFinish - block.timestamp;
            uint _leftover = _remaining * rewardRate;
            rewardRate = (amount + _leftover) / DURATION;
        }

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp + DURATION;
    }

    modifier update(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function _safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(erc20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))));
    }

    function _safeTransferFrom(address token, address from, address to, uint256 value) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(erc20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))));
    }
}
