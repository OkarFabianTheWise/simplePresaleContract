// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

// onlyOwner security constraint
contract Auth {
    address internal owner;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function.");
        _;
    }

    function isOwner() public view returns (address) {
        return owner;
    }
}

contract Presaler is Auth {
    address public token = 0x0; // token to be sold
    
    constructor() Auth(msg.sender) {}

    // records
    mapping (address => uint256) private _balances;
    
    function buypresale(uint256 _value, uint256 units) external payable{
        require(msg.value >= _value, "insufficient funds");
        _balances[msg.sender] += units;
    }

    function claim() external {
        uint256 units = _balances[msg.sender];
        require(units > 0, "no tokens to claim");
        IERC20 _token = IERC20(token);
        _token.transfer(msg.sender, units);
        _balances[msg.sender] -= units;
    }
    
    // presale buyer's balance of the presale tokens
    function buyerBalance() public view returns (uint256) {
        return _balances[msg.sender];
    }
    
    // this contract's balance of the presale tokens
    function PresalerBalance() external view returns (uint256) {
        uint256 balance = address(this).balance;
        return balance;
    }
    
    // admin rescue stuck tokens
    function withdrawTokens(address tokenToWithdraw, address _to) external onlyOwner {
        IERC20 _token = IERC20(tokenToWithdraw);
        uint256 balance = _token.balanceOf(address(this));
        require(balance > 0, "insufficent balance");
        _token.transfer(_to, balance);
    }

    // admin withdrawEth
    function withdrawEth(address _to) external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "insufficent balance");
        payable(_to).transfer(balance);
    }

    // fallback
    receive() external payable {}
}
