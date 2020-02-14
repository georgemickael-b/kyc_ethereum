pragma solidity ^0.5.9;

contract Types{
    /*
    Struct for a customer
    */
    struct Customer {
        string userName;   //unique
        string data_hash;  //unique
        uint8 upvotes;
        address bank;
        uint256 rating;   // Percentage
        bytes32 password; // keccak256 will be used to hash password which will be always 32 bytes
    }

    /*
    Struct for a Bank
    */
    struct Bank {
        address ethAddress;  //unique
        string bankName;
        string regNumber;    //unique
        uint256 KYC_count;
        uint256 rating; //Percentage
        uint8 upvotes;
    }

    /*
    Struct for a KYC Request
    */
    struct KYCRequest {
        string userName;
        string data_hash;  //unique
        address bank;
        bool isAllowed;
    }

}
