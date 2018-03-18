pragma solidity ^0.4.15;

import './F_BaseToken.sol';
import './F_DividendInTokenEnabledToken.sol';

//import './F_DateTime.sol';

contract MintingToken is BaseToken,DividendInTokenEnabledToken {

    uint256 base = 10;
    uint256 multiplier;

    address powBank;
    address dow1;
    address dow2;
    address dow3;

    uint8 powBankAlloc;
    uint8 dow1Alloc;
    uint8 dow2Alloc;
    uint8 dow3Alloc;
    uint8 mintAllocToBank;

    //DateTime DT ;
    uint public lastMinted ;

    //BaseToken token;
    event Mint(uint _tokensMinted,uint _timeStamp);
    
    function MintingToken(){
        powBank = 0x4f065ED5ED710323C32217CaDfBD4b33758e7926;
        dow1 = 0xCFD582351282cBd61b77F0eb821930729EBF7a0b;
        dow2 = 0xCB2D4a51ae1ae45f041910BED2bf3b56146D7f0D;
        dow3 = 0x86289090b7116B2DEb8fe16F18629f9c7939FB25;
        powBankAlloc = 85;
        dow1Alloc = 5;
        dow2Alloc = 5;
        dow3Alloc = 5;
        mintAllocToBank = 50;
        
        lastMinted = now;
        
        //token = new BaseToken();
    }
    
    function mint() returns (uint,uint) {
        uint secondsSinceLastMinting=now - lastMinted;
        uint minutesSinceLastMininting= (secondsSinceLastMinting - secondsSinceLastMinting%60)/60;
        //TODO - Remove the below line its only for testing
        minutesSinceLastMininting= secondsSinceLastMinting;

        if (secondsSinceLastMinting>=60){
            lastMinted = now - secondsSinceLastMinting%60;
            uint coinsMinted = minutesSinceLastMininting.mul(multiplier);
            totalSupply = totalSupply.add(coinsMinted);
            var coinsToBank = (coinsMinted*mintAllocToBank)/100;
            disburse(coinsMinted - coinsToBank);
            balances[powBank] = balances[powBank].add(coinsToBank*powBankAlloc/100);
            balances[dow1] = balances[dow1].add(coinsToBank*dow1Alloc/100);
            balances[dow2] = balances[dow2].add(coinsToBank*dow2Alloc/100);
            balances[dow3] = balances[dow3].add(coinsToBank*dow3Alloc/100);
            Mint(coinsMinted,now);
            return (secondsSinceLastMinting,minutesSinceLastMininting);

        } else{
            return (secondsSinceLastMinting,minutesSinceLastMininting);
        }
    }
    
    function returnNow() returns(uint){
        return now;
    }

    function transfer(address _to, uint _value) onlyWhenTokenIsOn onlyPayloadSize(2 * 32) returns (bool success){
        //_value = _value.mul(1e18);
        mint();
        require(
            balances[msg.sender]>=_value 
            && _value > 0);
            balances[msg.sender] = balances[msg.sender].sub(_value);
            balances[_to] = balances[_to].add(_value);
            Transfer(msg.sender,_to,_value);
            return true;
    }
    
    function transferFrom(address _from, address _to, uint _value) onlyWhenTokenIsOn onlyPayloadSize(3 * 32) returns (bool success){
        //_value = _value.mul(10**decimals);
        mint();
        require(
            allowed[_from][msg.sender]>= _value
            && balances[_from] >= _value
            && _value >0 
            );
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
            
    }
    
    function approve(address _spender, uint _value) onlyWhenTokenIsOn returns (bool success){
        mint();
        //_value = _value.mul(10**decimals);
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

}
