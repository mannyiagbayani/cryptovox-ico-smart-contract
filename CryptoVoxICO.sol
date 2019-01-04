pragma solidity ^0.5.0;

import "./CryptoVox.sol";

contract CryptoVoxICO is CryptoVox{
    address private owner;
    
    address payable public deposit;
    uint public raisedAmount;
    uint public maximumInvestment = 10000000000000000000; //10 ether in wei
    uint public minimumInvestment = 1000000000000000; //0.001 ether in wei
    uint public hardCap = 500000000000000000000; //5
    uint public tokenPrice = 2000000000000000; //0/002 ether in wei
    
    
    uint public icoStart = now;
    uint public icoEnd   = now + 604800;
    uint public icoTradingStart = icoEnd + (604800 * 2); //two weeks after icoEnd
    
    enum Action { beforeStart, inProgress, afterEnd, stopped }
    Action public icoAction;
    
    event Invest(address investor, uint value, uint tokens);
    
    modifier isOwner() {
        require(msg.sender == owner,"Restricted to Owner");
        _;
    }
    constructor(address payable _deposit) public {
        deposit = _deposit;
        owner = msg.sender;
        icoAction = Action.beforeStart;
    }
    
    function getIcoState() public view returns (Action) {
        if(icoAction == Action.stopped) {
            return Action.stopped;
        }
        
        if(block.timestamp < icoStart) {
            return Action.beforeStart;
        }
        
        if(block.timestamp >= icoStart && block.timestamp <= icoEnd) {
            return Action.inProgress;
        }
        
        return Action.afterEnd;
    }
    
    function stopped() public isOwner {
        icoAction = Action.stopped;
    }
    
    function restart() public isOwner {
        icoAction = Action.inProgress;
    }
    
    function changeDepositAddress(address payable _deposit) public isOwner {
        deposit = _deposit;
    }
    
    function invest() public payable returns(bool) {
        icoAction = getIcoState();
        require(icoAction == Action.inProgress,"ICO is not active anymore");
        require(msg.value >= minimumInvestment && msg.value <= maximumInvestment,"Investment should be between 0.001 and 5 ether");
        
        
        uint tokens = msg.value / tokenPrice;
        require(raisedAmount + msg.value <= hardCap, "Hardcap reach. ICO stopped accepting investment");
        
        raisedAmount += msg.value;
        
        balances[msg.sender] += tokens;
        balances[creator] -= tokens;
        deposit.transfer(msg.value);
        
        emit Invest(msg.sender,msg.value, tokens);
        return true;
    }
    
    function() payable external {
        invest();
    }
    
    function transfer(address to, uint tokens) public returns (bool success){
        require(block.timestamp > icoTradingStart,"Its not time to transfer token");
        return super.transfer(to,tokens);
    }
    
    function transferFrom(address from, address to, uint tokens) public returns (bool success){
        require(block.timestamp > icoTradingStart,"Its not time to transfer token");
        return super.transferFrom(from,to,tokens);
    }
    
    function burnToken() public isOwner returns(bool){
        icoAction = getIcoState();
        require(icoAction == Action.afterEnd,"ICO is still active");
        balances[creator] =0;
        
    }
    
}