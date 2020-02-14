pragma solidity ^0.5.9;
import "./Types.sol";

contract DataStorage is Types{
    /**
    Contract to store all the storage Variables.
     */
    address admin;
    /*
    Mapping a customer's username to the Customer struct
    We also keep an array of all keys of the mapping to be able to loop through them when required.
     */
    mapping(string => Customer) customers;
    string[] customerNames;

    /*
    Mapping a bank's address to the Bank Struct
    We also keep an array of all keys of the mapping to be able to loop through them when required.
     */
    mapping(address => Bank) banks;
    address[] bankAddresses;

    /*
    Mapping a customer's Data Hash to KYC request captured for that customer.
    This mapping is used to keep track of every kycRequest initiated for every customer by a bank.
     */
    mapping(string => KYCRequest) kycRequests;
    string[] customerDataList;

    /*
    Mapping a customer's username to customer Data
    this mapping is uses to keep track of final customer customerDataList
    */
    mapping(string => Customer) finalCustomers;

    /*
    Mapping a customer's user name with a bank's address
    This mapping is used to keep track of every upvote given by a bank to a customer
     */
    mapping(string => mapping(address => uint256)) upvotes;

    /*
    Mapping a bank address who is voted for with a bank's address who is voting.
    This mapping is used to keep track of every upvote given by a bank to another bank
     */
    mapping(address => mapping(address => uint256)) bankUpvotes;

}
