//SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./PriceConverter.sol";

// 	859.987
//  840.451 after constant
//  816.992 after immutable owner address
//  791.854 after changing onlyOwner modifier base
// constant immutable keyword save gas

// use if and own created error cost less gas than require
error NotOwner();

contract FundMe {
    
    using PriceConverter for uint256;
    uint256 public constant MINIMUM_USD = 50 * 1e18; // 1*10**18
    
    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;


    address public immutable i_owner;
    
    // _; --> follow the rest of code
    modifier onlyOwner {
        // require(msg.sender == i_owner, "Sender is not owner!");
        if(msg.sender != i_owner) { revert NotOwner(); }
        _;
    }

    constructor(){
        i_owner = msg.sender;
    }

    // What happens if someone sends this contract ETH without calling the fun function?
    // special functions, more details in fallbackExamples.sol 
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function fund() public payable{
        // Want to be able to set a minimum fund amount in USD
        // 1. How do we send ETH to this contract

        require(msg.value.getConversionRate() >= MINIMUM_USD, "Didn't send enough!"); // 1e18 == 1*10**18 = 1000000000000000000
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] +=  msg.value;

        // What is reveting? ( all change before reverted require cost tx fee, all change after revert cost tx but will revert if require is not passed )
    }

    //onlyOwner modifier
    function withdraw() public onlyOwner{
        /* starting index, ending index, step amount, */
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            //code
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        // reset the array
        funders = new address[](0);
        // actually withdraw the funds

        //transfer
        // payable(msg.sender).transfer(address(this).balance);

        //send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "send failed");

        //call //proper way to make a fund withdraw
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");        
        require(callSuccess, "Call failed");
    }

    
    // 1. Enums
    // 2. Events
    // 3. Try / Catch
    // 4. Function Selectors
    // 5. abi.encode / decode
    // 6. Hashing
    // 7. Yul / Assumbly
}
