// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract tipsjar{
    address public owner;
    string[] public supportedcurriences; 
    mapping(string=>uint256) public convertions;
    uint256 public totaltips;
    mapping (address=>uint256) public tipsperperson;
    mapping (string=>uint256) public tipspercurrency;
    modifier onlyOwner (){
        require(msg.sender==owner, "only owner can do it ");
        _;
    }
    constructor(){
        owner=msg.sender;
        addcurrency("USD", 5*10^14);//1USD=0.0005ETH, 1ETH=10^17wei;
        addcurrency("EUR", 6*10^14);
        addcurrency("JYP", 3*10^12);
        addcurrency("CNY", 7*10^13);
    }
    function addcurrency(string memory _currencycode, uint256 _ratetoEth)public onlyOwner{
        require(_ratetoEth>0, "coversion rate must > 0");

        bool currencyExists= false; // first check if currency is existed
        for (uint256 i=0; i<supportedcurriences.length; i++){
         // use .length for the length of str
         if(keccak256(bytes(supportedcurriences[i]))==keccak256(bytes(_currencycode))){
            currencyExists= true;
            break;
         }// once found the currency code is existed, break the loop, and the currecyExits bool become to true

        }
        if (!currencyExists){ // if not existed
        supportedcurriences.push(_currencycode);
        //convertions[_currencycode]=_ratetoEth; if put in this part, only new currency can add rate,old can not be changed
        }
        convertions[_currencycode]=_ratetoEth;
    }
    function covertToEth(string memory _currencycode,uint256 _amount) public view returns(uint256){ //return _ethAmount;
        require(convertions[_currencycode]>0, "not support this currency");
        uint256 ethAmount=_amount*convertions[_currencycode];
        return ethAmount;
    }
    function tipInEth()public payable{ // pay money need payable after public;
    require (msg.value>0,"Tips must>0");
    tipsperperson[msg.sender]+=msg.value;
    totaltips+=msg.value;
    tipspercurrency["ETH"]+=msg.value;
    }
    function tipInCurrency(string memory _currencycode,uint256 _amount) public payable{ // pay money need payable after public;
    require(convertions[_currencycode]>0, "not support this currency");
    require (_amount>0,"Tips must>0");
    uint256 ethAmount=covertToEth(_currencycode,_amount);// direct use function  covertToEth, notice the _currencycode and _amount is used before in function
    require(msg.value==ethAmount,"sent ETH does not match the value");
    // tipsperperson[msg.sender]+=ethAmount; is this work?
    tipsperperson[msg.sender]+=msg.value;
    totaltips+=msg.value;
    tipspercurrency[_currencycode]+=_amount;
    }
    function withdrawTips()public onlyOwner{
        uint256 contractBalance = address(this).balance;// check the balance of account, if no money will stop;
        require (contractBalance>0, "no tips to withdraw");
        (bool success, )=payable(owner).call{value:contractBalance}("");
        require(success,"Tranfer failed");
        totaltips=0;
    }
    function transferOwner(address _newowner) public onlyOwner{
        require (_newowner!=address(0),"Invalid address");
        owner=_newowner;
    }
    function getSupportedCurrenices()public view returns(string[] memory){
        return supportedcurriences; //no need [];
    }
    function getContractBalance()public view returns(uint256){
        return address(this).balance;
    }
    function gettipsperperson(address _tipper)public view returns(uint256){
        return tipsperperson[_tipper];
    }
    function gettipsIncurrency(string memory _currencycode)public view returns(uint256){
        return tipspercurrency[_currencycode];
    }
    function getconverstions(string memory _currencycode)public view returns(uint256){
        require(convertions[_currencycode]>0,"currency not support");
        return convertions[_currencycode];
    }

}