pragma solidity ^0.5.9;

contract Helpers{
    constructor() internal{}

    /*
     function to compare two string value
     This is an internal fucntion to compare string values
        @Params - String a and String b are passed as Parameters
        @return - This function returns true if strings are matched and false if the strings are not matching
    */
    function stringsEquals(string storage _a, string memory _b) internal view returns (bool) {
        bytes storage a = bytes(_a);
        bytes memory b = bytes(_b);
        if (a.length != b.length)
            return false;
        // @todo unroll this loop
        for (uint i = 0; i < a.length; i ++)
        {
            if (a[i] != b[i])
                return false;
        }
        return true;
    }

    /*
     function to convert bytes to byest32
     This is an internal fucntion to compare string values
        @Params - bytes to convert. offet from what index shoudl the conversion start from
        @return - bytes32 of input bytes. if the bytes array has more that 32 bytes, the tailing bytes are discarded
    */
    function bytesToBytes32(bytes storage b, uint offset) internal view returns (bytes32) {
      bytes32 out;
      uint bytesLength = (b.length > 32) ? 32 : b.length;
      for (uint i = 0; i < bytesLength; i++) {
        out |= bytes32(b[offset + i] & 0xFF) >> (i * 8);
      }
      return out;
    }
    
    /* internal function to calcualte percentage
        @Params _of and _in , percentage of _of in _in
    */
    function calcPercentage(uint  _of , uint  _in ) internal pure returns(uint){
        return 100 * _of/_in;
    }
    
    /* internal function to calculat string length of string.
        @Params string to find lenght for
        @return lenght of the string
    */
    function stringLength(string storage inString) internal view returns(uint){
        return bytes(inString).length;
    }
}
