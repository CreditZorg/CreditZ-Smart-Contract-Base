pragma solidity ^0.4.15;

import './F_ICO.sol';


contract CappedSupplyICO is ICO,DividendInEthEnabledToken,fileUploadEnabled,VotingEnabledToken_blocking {

    uint256 constant alloc1perc=30;//in percent --CORETEAM ALLOCATION
    address constant alloc1Acc = 0xC01188A69d83373cD199f601Eb79603AE92CfF99; //CORETEAM Address (test-TestRPC4)

    uint256 constant alloc2perc=10;//in percent -- ADVISORS ALLOCATION
    address constant alloc2Acc = 0x85625A5a48729F1E1AB65C856cfe4f46DE131f89; //TestRPC5

    uint256 constant alloc3perc=0;//in percent -- LEAVE IT TO ZERO IF NO MORE ALLOCATIONS ARE THERE
    address constant alloc3Acc = 0x789431a6c795F26b6ed950ea0eA7515f88a35A3A; //TestRPC6

    uint256 constant alloc4perc=0;//in percent -- LEAVE IT TO ZERO IF NO MORE ALLOCATIONS ARE THERE
    address constant alloc4Acc = 0x2E36bd3CD6eD6ecF2341855C73646F7bD43cfd74; //TestRPC7

    address constant ownerMultisig = 0xff36bBdC68b10bf0b8FC01AB5fb8F7CC39Dbc4b4;


    function CappedSupplyICO() {
        totalSupply = 200e24;//200 mn-- extra 18 zeroes are for the wallets which use decimal variable to show the balance 
        owner = msg.sender;
        balances[owner]=totalSupply;
        currentICOPhase = 1;
        addICOPhase("Pre ICO",8e24,1200);
        addICOPhase("ICO",12e24,900);
        //addICOPhase("ICO",60e24,30e6);
        runAllocations();
    }
    
    function () payable {
        createTokens();
    }   
    
    function createTokens() payable {
        require(msg.value > 0
            && icoPhases[currentICOPhase].saleOn == true);        
        uint256 tokens = msg.value.mul(icoPhases[currentICOPhase].RATE);
        //require(balances[owner].sub(tokens)>0);
        // Put an IF condition over here
        balances[owner] = balances[owner].sub(tokens);
        ownerMultisig.transfer(msg.value);
        balances[msg.sender] = balances[msg.sender].add(tokens);
        icoPhases[currentICOPhase].tokensAllocated = icoPhases[currentICOPhase].tokensAllocated.add(tokens);
        if(icoPhases[currentICOPhase].tokensAllocated>=icoPhases[currentICOPhase].tokensStaged){
            icoPhases[currentICOPhase].saleOn = !icoPhases[currentICOPhase].saleOn; //CHECK WHETHER THEY WANT TO REMOVE THIS AUTOMATIC CLOSURE OF SALE
            currentICOPhase++;
        }
    }

    function runAllocations() ownerOnly {
        balances[owner]=((100-(alloc1perc+alloc2perc+alloc3perc+alloc4perc))*totalSupply)/100;
        balances[alloc1Acc]=(alloc1perc*totalSupply)/100;
        balances[alloc2Acc]=(alloc2perc*totalSupply)/100;
        balances[alloc3Acc]=(alloc3perc*totalSupply)/100;
        balances[alloc4Acc]=(alloc4perc*totalSupply)/100;
    }

    function newICORound(uint256 _newSupply) ownerOnly {//This is different from Stages which means multiple parts of one round
        _newSupply = _newSupply.mul(1e18);
        balances[owner] = balances[owner].add(_newSupply);
        totalSupply = totalSupply.add(_newSupply);
    }

    function killContract() ownerOnly{
        selfdestruct(ownerMultisig);
    }
    
    function destroyUnsoldTokens(uint256 _tokens) ownerOnly{
        _tokens = _tokens.mul(1e18);
        totalSupply = totalSupply.sub(_tokens);
        balances[owner] = balances[owner].sub(_tokens);
    }

    function pauseStartToken() ownerOnly{
        tokenStatus = !tokenStatus;
    }

    
}

