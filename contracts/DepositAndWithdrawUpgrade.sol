// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

contract DepositAndWithdrawUpgrade is
    Initializable,
    PausableUpgradeable,
    AccessControlUpgradeable
{
    event FundsDeposited(
        address indexed tokenDeposited,
        uint256 amountDeposited
    );
    event FundsWithdrawn(
        address indexed tokenWithdrawn,
        address indexed withdrawAddress,
        uint256 amountWithdrawn
    );
    event FundsWithdrawnBNB(
        address indexed withdrawAddressbnb,
        uint256 amountWithdrawnbnb
    );
    event UniqueTokenAdded(address indexed addedToken);
    event contractTokenBalanceAdjusted(address indexed token, uint256 amount);
    address[] public allowedTokensAddresses;
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 public constant WITHDRAWER_ROLE = keccak256("WITHDRAWER_ROLE");
    uint256 public bnbBalance;
    mapping(address => uint256) public contractTokenBalances;
    mapping(address => bool) public tokenIsAllowed;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __Pausable_init();
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(OWNER_ROLE, msg.sender);
        _grantRole(WITHDRAWER_ROLE, msg.sender);
    }

    function pause() public onlyRole(OWNER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(OWNER_ROLE) {
        _unpause();
    }

    receive() external payable {
        bnbBalance += msg.value;
    }

    fallback() external payable {}

    function addAllowedToken(address _token) public onlyRole(OWNER_ROLE) {
        require(!tokenIsAllowed[_token], "token Already Exists");
        allowedTokensAddresses.push(_token);
        tokenIsAllowed[_token] = true;
        emit UniqueTokenAdded(_token);
    }

    function DepositBNB() public payable {
        require(msg.value > 0, "the amount should be greater than zero");
        bnbBalance += msg.value;
    }

    function deposit(address _token, uint256 _amount) public {
        require(_amount > 0, "the amount should be greater than zero");
        require(tokenIsAllowed[_token], "the token is not currently allowed");
        require(
            IERC20Upgradeable(_token).balanceOf(msg.sender) >= _amount,
            "you have insufficient Funds available in your wallet"
        );
        IERC20Upgradeable(_token).transferFrom(
            msg.sender,
            address(this),
            _amount
        );
        uint256 contractTokenBalance = contractTokenBalances[_token] += _amount;
        emit contractTokenBalanceAdjusted(_token, contractTokenBalance);
        emit FundsDeposited(_token, _amount);
    }

    function withdraw(
        address _withdrawerAddress,
        address _token,
        uint256 _amount
    ) public onlyRole(WITHDRAWER_ROLE) whenNotPaused {
        require(_amount > 0, "Withdraw an amount greater than 0");
        require(tokenIsAllowed[_token], "the token is not currently allowed");
        require(
            IERC20Upgradeable(_token).balanceOf(address(this)) >= _amount,
            "insufficient tokens available in the contract"
        );
        IERC20Upgradeable(_token).transfer(_withdrawerAddress, _amount);
        uint256 contractTokenBalance = contractTokenBalances[_token] -= _amount;
        emit contractTokenBalanceAdjusted(_token, contractTokenBalance);
        emit FundsWithdrawn(_token, _withdrawerAddress, _amount);
    }

    function withdrawBNB(address _withdrawerAddress, uint256 _amount)
        public
        payable
        onlyRole(WITHDRAWER_ROLE)
        whenNotPaused
    {
        require(_amount > 0, "Withdraw an amount greater than 0");
        require(
            bnbBalance >= _amount,
            "insufficient bnb available in the contract"
        );
        payable(_withdrawerAddress).transfer(_amount);
        bnbBalance -= _amount;
        emit FundsWithdrawnBNB(_withdrawerAddress, _amount);
    }
}
