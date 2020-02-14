pragma solidity ^0.5.9;
import "./Types.sol";
import "./DataStorage.sol";
import "./Helpers.sol";
import "./AccessControl.sol";

contract AdminHandler is Types,DataStorage,Helpers,AccessControl{
    constructor() public{
    }
    /**
     * Adds bank to banks mapping and bank's address to bankAddresses list
     * @param {string} bankName Name of the bankName
     * @param {string} regNumber resgistration number of the bankName
     * @param {address} ethAddress address of the bank
     */
    function addBank(string memory bankName, string memory regNumber, address  ethAddress) public onlyAdmin returns(uint8) {
        require(banks[ethAddress].ethAddress == address(0), "This Bank is already registered.");
        banks[ethAddress].bankName =  bankName;
        banks[ethAddress].ethAddress = ethAddress;
        banks[ethAddress].regNumber = regNumber;
        banks[ethAddress].KYC_count = 0;
        banks[ethAddress].rating = 0;
        bankAddresses.push(ethAddress);
        return 1;
    }
    
     /**
     * Removes bank from banks mapping and remove bank's address to bankAddresses list
     * @param {string} bankName Name of the bankName
     * @return {uint8} flag if removal is succesful
     */
    function removeBank(address bankAddress) public onlyAdmin returns(uint8){
        require(banks[bankAddress].ethAddress != address(0), "This Bank is not registered.");
        delete banks[bankAddress];
        for(uint i=0;i < bankAddresses.length;i++)
        {
         for(uint j = i+1;j < bankAddresses.length;j++)
            {
                bankAddresses[j-1] = bankAddresses[j];
            }
        }
        bankAddresses.length--;
        return 1;
    }
}
