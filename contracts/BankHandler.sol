pragma solidity ^0.5.9;
import "./Types.sol";
import "./DataStorage.sol";
import "./Helpers.sol";
import "./AccessControl.sol";

contract BankHandler is Types,DataStorage,Helpers,AccessControl{
    constructor() public{}
    
    /**
     * Record a new KYC request on behalf of a customer
     * The sender of message call is the bank itself
     * @param  {string} _userName The name of the customer for whom KYC is to be done
     * @param  {address} _bankEthAddress The ethAddress of the bank issuing this request
     * @return {bool}        True if this function execution was successful
     */
    function addKycRequest(string memory _userName, string memory _customerData) onlyBank public returns (uint8) {
        // Check that the user's KYC has not been done before, the Bank is a valid bank and it is allowed to perform KYC.
        require(kycRequests[_customerData].bank == address(0), "This user already has a KYC request with same data in process.");
        kycRequests[_customerData].data_hash = _customerData;
        kycRequests[_customerData].userName = _userName;
        kycRequests[_customerData].bank = msg.sender;
        banks[msg.sender].KYC_count++; //Update the KYC_count so that it can be used in getBankRequests for allocation array sizes.
        if(banks[msg.sender].rating <= 50)
            kycRequests[_customerData].isAllowed = false;
        else
            kycRequests[_customerData].isAllowed = true;
        customerDataList.push(_customerData);
        return 1;
    }
    
    /**
     * Gets the list of each fields of kyc requests filtered for a bankAddress.
     * @param {string} bankAddress
     * returns tuple with n lists where n corresponds to fields of KYC_Request struct. Each of the list are assosicated accross each other with index
     */
    function getBankRequests(address bankAddress) public view returns(address[] memory, bytes32[] memory, bytes32[] memory, bool[] memory ){
        Bank storage bank = banks[bankAddress]; // Just a pointer to actual storage. So no gas spent.
        address[] memory addresses = new address[](bank.KYC_count); // Only allocate memory with the KYC_count value of the bank.
        bytes32[] memory usernames = new bytes32[](bank.KYC_count);
        bytes32[] memory dataHashes = new bytes32[](bank.KYC_count);
        bool[] memory isAlloweds = new bool[](bank.KYC_count);
        uint filteredKYC_Count = 0;
        for(uint i=0; i<customerDataList.length; i++){
            if(kycRequests[customerDataList[i]].bank == bankAddress){
             addresses[filteredKYC_Count] = bankAddress ;
             usernames[filteredKYC_Count] = bytesToBytes32(bytes(kycRequests[customerDataList[i]].userName),0);
             isAlloweds[filteredKYC_Count] = kycRequests[customerDataList[i]].isAllowed;
             dataHashes[filteredKYC_Count] = bytesToBytes32(bytes(kycRequests[customerDataList[i]].data_hash),0);
             filteredKYC_Count++;
            }
        }
        return (addresses, usernames,dataHashes, isAlloweds);
    }

    /**
     * Add a new customer
     * @param {string} _userName Name of the customer to be added
     * @param {string} _hash Hash of the customer's ID submitted for KYC
     */
    function addCustomer(string memory _userName, string memory _customerData) onlyBank onlyKYCExists(_userName,_customerData) onlyAllowedBanksKYC(_customerData) public returns (uint8) {
        require(customers[_userName].bank == address(0), "This customer is already present, please call modifyCustomer to edit the customer data");
        customers[_userName].userName = _userName;
        customers[_userName].data_hash = _customerData;
        customers[_userName].bank = msg.sender;
        customers[_userName].upvotes = 0;
        customers[_userName].password = keccak256("0");
        customerNames.push(_userName);
        removeKYCRequest(_userName, _customerData); // Remove the related kyc request after creating cutomer.
        return 1;
    }

    /**
     * Remove KYC request from kycRequests mapping and remove kyc data hash from customerDataList
     * @param  {string} _userName Name of the customer
     * @return {uint8} A 0 indicates failure, 1 indicates success
     */
    function removeKYCRequest(string memory _userName, string memory customerData) public returns (uint8) {
        uint8 i=0;
        for (i = 0; i< customerDataList.length; i++) {
            if (stringsEquals(kycRequests[customerDataList[i]].userName,_userName)
                && stringsEquals(kycRequests[customerDataList[i]].data_hash , customerData)) {
                Bank storage bank = banks[kycRequests[customerDataList[i]].bank];
                delete kycRequests[customerDataList[i]];
                for(uint j = i+1;j < customerDataList.length;j++){
                    customerDataList[j-1] = customerDataList[j];
                }
                customerDataList.length --;
                bank.KYC_count--;
                i=1;
            }
        }
        return i; // 0 is returned if no request with the input username is found.
    }

    /**
     * Remove customer from customer mapping and remove customer name from customerNames
     * @param  {string} _userName Name of the customer
     * @return {uint8} A 0 indicates failure, 1 indicates success
     */
    function removeCustomer(string memory _userName) public returns (uint8) {
        for(uint i = 0;i < customerNames.length;i++)
        {
            if(stringsEquals(customerNames[i],_userName))
            {
                delete customers[_userName];
                for(uint j = i+1;j < customerNames.length;j++)
                {
                    customerNames[j-1] = customerNames[j];
                }
                customerNames.length--;
                return 1;
            }
        }
        return 0;
    }

    /**
     * Edit customer information
     * @param  {string} _userName Name of the customer
     * @param  {string} _hash New hash of the updated ID provided by the customer
     * @param  {string} password password of the customer or '0' if no password is set
     * @return {uint8} A 0 indicates failure, 1 indicates success
     */
    function modifyCustomer(string memory _userName, string memory _newcustomerData, string memory password) public  authenticated(_userName,password) returns (uint8) {
        for(uint i = 0;i < customerNames.length;i++)
            {
                if(stringsEquals(customerNames[i],_userName))
                {
                    if( stringsEquals(finalCustomers[_userName].userName,_userName)) // If customer found in final customer list remove it
                        delete finalCustomers[_userName];
                    customers[_userName].data_hash = _newcustomerData;
                    customers[_userName].userName = _userName;
                    customers[_userName].upvotes = 0; // set upvote and rating to 0
                    customers[_userName].rating = 0;
                    customers[_userName].bank = msg.sender;
                    return 1;
                }
            }
            return 0;
    }

    /**
     * View customer information
     * @param  {string} _userName Name of the customer
     * @return {Customer} The customer struct as an object
     */
    function viewCustomer(string memory _userName, string memory password) public authenticated(_userName,password) view returns (string memory, string memory, uint8, address) {
        //if passes authenticated modfier returns customer data
        return (customers[_userName].userName, customers[_userName].data_hash, customers[_userName].upvotes, customers[_userName].bank);
    }

    /**
     * Add a new upvote from a bank to a customer
     * @param {string} _userName Name of the customer to be upvoted
     */
    function upvoteCustomer(string memory _userName) public returns (uint8) {
        for(uint i = 0;i < customerNames.length;i++)
            {
                if(stringsEquals(customerNames[i],_userName))
                {
                    if(upvotes[_userName][msg.sender]!=0) //Donot allow upvote if bank already upvoted.
                        revert("You have already voted for this customer");
                    customers[_userName].upvotes++;
                    customers[_userName].rating  =  calcPercentage(customers[_userName].upvotes, bankAddresses.length); // Store raing as percentage
                    upvotes[_userName][msg.sender] = now;//storing the timestamp when vote was casted, not required though, additional
                    if(customers[_userName].rating > 50)
                        finalCustomers[_userName] = customers[_userName]; // add to final customer list
                    return 1;
                }
            }
            return 0;
    }

     /**
     * Add a new upvote from a bank to another bank. caller should be a bank.
     * @param {address} bankAddress Address of the bank to be upvoted
     */
    function upVoteBank(address bankAddress) public onlyBank returns (uint8){
        require(bankAddress != msg.sender, "You cannot vote yourself"); // A bank cannot vote itself
        require(banks[bankAddress].ethAddress != address(0), "The Bank you are trying to vote for is not registered");
        if(bankUpvotes[bankAddress][msg.sender] != 0) // Dont allow vote if already voted
            revert("You have already voted for this customer");
        banks[bankAddress].upvotes++;
        banks[bankAddress].rating = calcPercentage(banks[bankAddress].upvotes, bankAddresses.length); // Calcullate bank rating
        bankUpvotes[bankAddress][msg.sender]=now;
        return 1;
    }

    /**
     * Get bank details as tuple
     * @param {address} bankAddress Address of the bank to get the details
     */
    function getBankDetails(address bankAddress) public view  returns(address , string memory,string memory, uint256, uint256,uint8){
        require(banks[bankAddress].ethAddress != address(0) , "Bank you queried for is not registered.");
        return (banks[bankAddress].ethAddress,banks[bankAddress].bankName,banks[bankAddress].regNumber,banks[bankAddress].KYC_count,banks[bankAddress].rating,banks[bankAddress].upvotes);
    }

    /**
     * Get bank's rating
     * @param {address} bankAddress Address of the bank to get the rating
     */
    function getBankRating(address bankAddress) public view returns (uint256){
        require(banks[bankAddress].ethAddress != address(0) , "Bank you queried for is not registered.");
        return banks[bankAddress].rating;
    }

    /**
     * Get customer's rating
     * @param {string} username customer's username
     */
    function getCustomerRating(string memory username) public view returns (uint256){
         for(uint i = 0;i < customerNames.length;i++)
            {
                if(stringsEquals(customerNames[i],username))
                {
                        return customers[username].rating;
                }
            }
        revert("Customer you queried for does not exist.");
    }

    /**
     * Get the last bank which validated the cutomer data
     * @param {string} username customer's username
     */
    function getAccessHistory(string memory username) public view returns(address , string memory,string memory, uint256, uint256,uint8){
        return getBankDetails( customers[username].bank); // Customer.bank always hold the bank which updated it last. Customer in customers list is always validated.
    }
    
    /**
     * Set password to protect customer data
     * @param {string} username customer's username
     * @param {string} password password
     */
    function setCustomerPassword(string memory username, string memory password) public onlyBank returns(uint8){
        require(customers[username].password == keccak256("0"), "Customer is already protected by password. Use modifyCustomerPassword to update password");
        customers[username].password = keccak256(bytes(password)); // hash the password with keccak256 which is bytes32
        return 1;
    }
    
    /**
     * Modify the password of the customer whos has an existing password
     * @param {string} username customer's username and password
     * @param {string} currentPassword existing password
     * @param {string} newPassword new password to set
     */
    function modifyCustomerPassword(string memory username, string memory currentPassword, string memory newPassword) public onlyBank authenticated(username,currentPassword) returns(uint8){
        customers[username].password = keccak256(bytes(newPassword));
        return 1;
    }
}
