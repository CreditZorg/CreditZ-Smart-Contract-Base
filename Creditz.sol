pragma solidity ^0.4.15;

import './F_ICO.sol';
import './F_MiscFeatures.sol';
import './F_Multiround.sol';
import './F_DateTime.sol';
import './F_Referral.sol';
import './Creditz_minting.sol';

/*
"0x14723a09acff6d2a60dcdf7aa4aff308fddc160c","0xdd870fa1b7c4700f2bd7f44238821c26f7392148"
"0x14723a09acff6d2a60dcdf7aa4aff308fddc160c","0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db"
"0x14723a09acff6d2a60dcdf7aa4aff308fddc160c","0x583031d1113ad414f02576bd6afabfb302140225"

Metamask addresses 
"0x4f065ED5ED710323C32217CaDfBD4b33758e7926","0xCFD582351282cBd61b77F0eb821930729EBF7a0b"
"0x4f065ED5ED710323C32217CaDfBD4b33758e7926","0xCB2D4a51ae1ae45f041910BED2bf3b56146D7f0D"
"0x4f065ED5ED710323C32217CaDfBD4b33758e7926","0x86289090b7116B2DEb8fe16F18629f9c7939FB25"


*/

//TODO - ADD Total ETH raised and Record token wise contribution    
contract CreditzToken is ICO,killable,MultiRound,ReferralEnabledToken,MintingToken {
    
    uint256 constant alloc1perc=1000;//in percent --CORETEAM ALLOCATION
    address constant alloc1Acc = 0x4d00DEd04BefF0B3EF2B9A0aD3aedE5DA50C87aE; //CORETEAM Address (test-TestRPC4)

    uint256 constant alloc2perc=0;//in percent -- ADVISORS ALLOCATION
    address constant alloc2Acc = 0x0; //TestRPC5

    uint256 constant alloc3perc=0;//in percent -- LEAVE IT TO ZERO IF NO MORE ALLOCATIONS ARE THERE
    address constant alloc3Acc = 0x0; //TestRPC6

    uint256 constant alloc4perc=0;//in percent -- LEAVE IT TO ZERO IF NO MORE ALLOCATIONS ARE THERE
    address constant alloc4Acc = 0x0; //TestRPC7

    address constant ownerMultisig = 0x0; //Test4
    mapping(address=>uint) blockedTill;

    function CreditzToken() {
        decimals = 18;
        multiplier=base**decimals;

        totalSupply = 200000*multiplier;//200 mn-- extra 18 zeroes are for the wallets which use decimal variable to show the balance 
        owner = msg.sender;
        multiplier=base**decimals;
        name = "Creditz Token";
        symbol = "CRZ";
        currentICOPhase = 1;
        addICOPhase("Pre Sale",1000000000*multiplier,40,addDaystoTimeStamp(180));//40 is the RATE per ETH
        addICOPhase("ICO",1000000000*multiplier,100,addDaystoTimeStamp(180));//100 is the Rate per ETH
        runAllocations();
    }

    function runAllocations() ownerOnly {
        balances[owner]=((1000-(alloc1perc+alloc2perc+alloc3perc+alloc4perc))*totalSupply)/1000;
        
        balances[alloc1Acc]=(alloc1perc*totalSupply)/1000;
        blockedTill[alloc1Acc] = addDaystoTimeStamp(180);
        
        balances[alloc2Acc]=(alloc2perc*totalSupply)/1000;
        blockedTill[alloc2Acc] = addDaystoTimeStamp(180);
        
        balances[alloc3Acc]=(alloc3perc*totalSupply)/1000;
        blockedTill[alloc3Acc] = addDaystoTimeStamp(180);
        
        balances[alloc4Acc]=(alloc4perc*totalSupply)/1000;
        blockedTill[alloc4Acc] = addDaystoTimeStamp(180);
        
    }


    function () payable {
        createTokens();
    }   

    
    function createTokens() payable {
        ICOPhase storage i = icoPhases[currentICOPhase]; 
        require(msg.value > 0
            && i.saleOn == true);
        
        referral storage r = referrals[msg.sender];

        ownerMultisig.transfer(msg.value);

        //Token Disbursement
        uint256 tokens = msg.value.mul(i.RATE);
        balances[msg.sender] = balances[msg.sender].add(tokens);
        i.tokensAllocated = i.tokensAllocated.add(tokens);
        
        ethContributedBy[msg.sender] = ethContributedBy[msg.sender].add(msg.value);
        totalEthRaised = totalEthRaised.add(msg.value);
        totalTokensSoldTillNow = totalTokensSoldTillNow.add(tokens);

        if(i.tokensAllocated>=i.tokensStaged){
            i.saleOn = !i.saleOn; 
            currentICOPhase++;
        }
    }
    
    function transfer(address _to, uint _value) onlyWhenTokenIsOn onlyPayloadSize(2 * 32) returns (bool success){
        //_value = _value.mul(1e18);
        require(
            balances[msg.sender]>=_value 
            && _value > 0
            && now > blockedTill[msg.sender]
        );
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender,_to,_value);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint _value) onlyWhenTokenIsOn onlyPayloadSize(3 * 32) returns (bool success){
        //_value = _value.mul(10**decimals);
        require(
            allowed[_from][msg.sender]>= _value
            && balances[_from] >= _value
            && _value >0 
            && now > blockedTill[_from]            
        );

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
            
    }
    
}

