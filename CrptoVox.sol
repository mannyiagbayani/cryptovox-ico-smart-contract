pragma solidity ^0.5.0;

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

import "./SafeMath.sol";

contract CryptoVox is ERC20Interface {
    using SafeMath for uint256;

    string public name = "CryptoVox";
    string public symbol = "CRVOX";
    uint public decimal = 18;
    
    //total number of tokens available
    uint public  supply;
    address public creator;
    
    //token balances using address as key and amount as value
    mapping(address => uint) public balances;

    //track token spending. first address is the actual owner, second address 
    //is the key that have permissions to spend the money. 
    mapping(address => mapping(address => uint)) internal allowed;
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    
    constructor() public {
        creator = msg.sender;
        //supply = _initialSupply;
        //store all token supply to the owner
        balances[creator] = supply;
    }
    
    /**
    * @dev all numbers of token 
     */
    function totalSupply() public view returns (uint) {
        return supply;    
    }
    
    /**
    * @dev     get the balance of an addresss
    * @param   tokenOwner is the address to look for
    * @return  uint balance is the amount available of the @param
     */
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }
    
    /**
    * @dev     transfer token between accounts
    * @param   to is the receiver, tokens is the number of tokens to transfer
    * @return  bool success successful or not
     */    
    function transfer(address to, uint tokens) public returns (bool success) {
        require(to != address(0),"Invalid address");
        require(tokens > 0 && balances[msg.sender] >= tokens, "Insufficient token");
        balances[to] = balances[to].add(tokens);
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        
        emit Transfer(msg.sender, address(balances[to]), tokens);
        return true;
    }
    
    /**
    * @dev     checking approved account
    * @param   tokenOwner is the owner and spender is the address that have permission to spend, tokens is the number of tokens to transfer
    * @return  bool success successful or not
     */        
    function allowance(address tokenOwner, address spender) public view returns (uint remaining){
        return allowed[tokenOwner][spender];
    }
   
    /**
    * @dev     set spending token for an address
    * @param   spender is the address that have permmission from the onwer, tokens is the number of tokens to transfer
    * @return  bool success successful or not
     */    
    function approve(address spender, uint tokens) public returns (bool success) {
        require(balances[msg.sender] >= tokens && tokens > 0,"Insufficient token");
        allowed[msg.sender][spender] = tokens;
        
        emit Approval(msg.sender, address(spender), tokens);
        return true;
    }

    /**
    * @dev     do transfer from different addresses
    * @param   from is the address where the token will come from, 
    *           to is the address of the receiver 
    *           tokens is the number of tokens to transfer
    * @return  bool success successful or not
     */    
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        require(to != address(0),"Invalid 'to' addres");
        require(allowed[from][to] >= tokens,"Insufficient Allowed token ");
        require(balances[from] >= tokens && tokens > 0,"Insufficient token");
        balances[from] = balances[from].sub(tokens);
        balances[to] = balances[to].add(tokens);
        allowed[from][to] = allowed[from][to].sub(tokens);
        return true;
        
    }
    
    /**
    * @dev     increase allowance
    * @param   spender is the address that have permmission from the onwer, tokens is the number of tokens to transfer
    * @return  bool success successful or not
     */    
    function increaseAllowance(address spender, uint tokens) public returns (bool) {
        allowed[msg.sender][spender] = allowed[msg.sender][spender].add(tokens);
        emit Approval(msg.sender, address(spender), allowed[msg.sender][spender]);
        return true;
    }

    /**
    * @dev     decrease allowance
    * @param   spender is the address that have permmission from the onwer, tokens is the number of tokens to transfer
    * @return  bool success successful or not
     */    
    function decreaseAllowance(address spender, uint tokens) public returns (bool) {
        if(tokens > allowed[msg.sender][spender]){
            allowed[msg.sender][spender] = 0;
        }
        allowed[msg.sender][spender] = allowed[msg.sender][spender].sub(tokens);
        emit Approval(msg.sender, address(spender), allowed[msg.sender][spender]);
        return true;
    }
}