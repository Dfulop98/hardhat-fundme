//SPDX-License-Identifier: MIT

//Pragma
pragma solidity ^0.8.8;

//Imports
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

// Error codes
error FundMe__NotOwner();

// Interfaces, Libraries, Contracts

/** @title A contract for crowd funding
 * @author Fülöp Dobó
 * @notice This contract is to demo a sample funding contract
 * @dev This contract price feeds as our library
 */
contract FundMe {
    // type declarations
    using PriceConverter for uint256;
    
    //State variables
    mapping(address => uint256) public s_addressToAmountFunded;
    address[] public s_funders;
    address public immutable i_owner;
    uint256 public constant MINIMUM_USD = 50 * 1e18; // 1*10**18

    AggregatorV3Interface public priceFeed;

    //Modifiers
    modifier onlyOwner {
        // require(msg.sender == i_owner, "Sender is not owner!");
        if(msg.sender != i_owner) { revert FundMe__NotOwner(); }
        _;
    }

    /*
     Functions order:
     constructor
     receive
     fallback
     external
     public
     internal
     private
     view / pure
     */

    constructor(address priceFeedAddress){
        i_owner = msg.sender;
        priceFeed = AggregatorV3Interface(priceFeedAddress);
    }
    
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /**
     * @notice This function is used to fund the contract
     * @dev Push funders to the dictionary
     */
    function fund() public payable{
        require(
            msg.value.getConversionRate(priceFeed) >= MINIMUM_USD,
             "Didn't send enough!"
        );

        s_addressToAmountFunded[msg.sender] +=  msg.value;
        s_funders.push(msg.sender);
    }

    function withdraw() public payable onlyOwner{
        for(
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool success,) = payable(msg.sender).call{
            value: address(this).balance
        }("");        
        require(success, "Transfer failed!");
    }

    function getAddressToAmountFunded(address fundingAddress) 
        public 
        view 
        returns (uint256)
    {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }
}
