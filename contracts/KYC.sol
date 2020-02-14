pragma solidity ^0.5.9;
import "./BankHandler.sol";
import "./AdminHandler.sol";
import "./DataStorage.sol";

/**
 * Main container contract which inherits all handler contracts
 * Logic is seperated out in to multiple contracts for readabilty and maintainability
 *  - Handler functions - Each of business entity functions are put in separate contracts - BankHandler, AdminHandler
 *  - Types - All custom types/struct are defined in the Types contract. Other contract will inherit Types if they need to use custom types.
 *  - DataStorage - All permanant storage varaibles are declared here. This contract can be shared between other contracts by inherting it.
 *  - AccessControl - All modifiers related to access, permission and authentication is defined here.
 *  - Helpers - Utiltites functions defined here
 */
contract KYC is DataStorage,BankHandler, AdminHandler{
    constructor() public{
        admin = msg.sender;
    }
}
