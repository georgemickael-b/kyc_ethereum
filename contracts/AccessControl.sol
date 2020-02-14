pragma solidity ^0.5.9;
import "./DataStorage.sol";
import "./Helpers.sol";

contract AccessControl is DataStorage,Helpers{
    /**
     * Modifier to Only allow banks that is present in banks mapping
     */
    modifier onlyBank{
        require(banks[msg.sender].ethAddress != address(0), "You are not registered as bank");
        _;
    }

    /**
     * Modifier to only allow if username and customerData is already present in KYC kycRequests
     * @param username of the user in KYC kycRequests
     * @param customerData data hash of the kyc kycRequests
     */
    modifier onlyKYCExists(string memory username, string memory customerData){
       bool  exists = false;
       for(uint i = 0;i < customerDataList.length;i++)
            {
                if(stringsEquals(kycRequests[customerDataList[i]].data_hash,customerData) && stringsEquals(kycRequests[customerDataList[i]].userName,username) ){
                      exists = true;
                      break;
                }
            }
        require(exists,"KYC Request for this Customer doesnot exist");
        _;
    }
    
    /**
     * Modifier to only allow if the kycs request is created by allowed bank
     * @param customerData data hash of thekyc request
     */
    modifier onlyAllowedBanksKYC(string memory customerData){
        require(kycRequests[customerData].isAllowed == true,"Denied. This KYC is not requested by allowed bank.");
        _;
    }
    /**
     * Modifier to only allow admin
     */
    modifier onlyAdmin{
        require(msg.sender == admin, "You do not have permssion to call this method");
        _;
    }

    /**
     * Modifier to allow the access to customer data only to requets having correct password or '0' id there is no password set.
     * @param userName userName of the customers
     * @param password password of the customers
     */
    modifier authenticated(string memory userName , string memory password){
        require(stringLength(customers[userName].userName)!=0, "Customer not found.");
        if(customers[userName].password == keccak256(bytes(password))){
            _;
        }
        else
         revert( "Password is incorrect. Pass '0' if customer has no password");
    }
}
