pragma solidity ^0.5.0;

import "./CrptoVox.sol";

/**
    * @dev    - give the ability to mint a coin for specified tokens
    * @param  - 
    * @return - 
 */
contract CryptoVoxMinting is CryptoVox{

    event MintingFinished();
    event Mint(address to, uint tokens);
    
    bool private _finishedMinting = false;
    
    address private _owner;
    
    modifier isOwner() {
        require(msg.sender == _owner,"Only admin can run this function contract");
        _;
    }
    
    modifier isFinishedMinting() {
        require(_finishedMinting == false,"Minting for new coin is finished");
        _;
    }
    
    constructor() public {
        _owner = msg.sender;
    }
    
    /**
    * @dev    - mint a new coin/token
    * @param  - to is the address of the owner and tokens is the number of supplied coind
    * @return - true if succesful
    */
    function Minting(address to, uint tokens) public isOwner returns(bool) {
        balances[to] = balances[to].add(tokens);
        supply = supply.add(tokens);
        
        emit Mint(to,tokens);
        emit Transfer(msg.sender, address(balances[to]), tokens);
        return true;
    }

    
    /**
    * @dev    - stop minting
    * @param  - 
    * @return - true if succesful
    */
    function FinishMinting() public isOwner returns(bool) {
        _finishedMinting = true;
        
        emit MintingFinished();();
        return true;
    }
}