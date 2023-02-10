// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "./interfaces/IERC20.sol";
contract Governance {


    // ============================
    // STATE VARIABLE
    // ============================

    uint ID;
    address admin;
    address tokenAddress;

    struct claimRequests {
        uint amountRequested;
        string description;
        string protocolName;
        address claimer;
        uint claimRequestDate;
    }

    

    // ============================
    // CONSTRUCTOR
    // ============================

    constructor (address _tokenAddress) {
        admin = msg.sender;
        tokenAddress = _tokenAddress;
    }




    function requestCoverClaim (
        uint _amountRequest,
        string memory _description,
        string memory _protocolName )
        public 
    {

    }


    // ***************** //
    // INTERNAL FUNCTIONS
    // ***************** //

     /// @notice Function to deposit ERC20 token into the contract 
    /// @dev This is an internal funcion called by different functions to deposit ERC20 token into the contract 
    /// @return sent the return variables of a contract’s function state variable
     function deposit(
        uint _amount) 
         internal 
         returns (bool sent)
    {
        amountMustBeGreaterThanZero(_amount);
        sent = IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount);
    }

    /// @notice this is the internal function used to check that address must be greater than zero
    /// @param _amount: this is the amount you want to check
    function amountMustBeGreaterThanZero(uint _amount) internal pure {
        require(_amount > 0, "Amount must be greater than zero");
    }
 
}