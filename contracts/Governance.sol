// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "./interfaces/IERC20.sol";
contract Governance {


    // ============================
    // STATE VARIABLE
    // ============================

    uint ID = 1;
    address admin;
    address tokenAddress;

    struct ClaimRequests {
        uint amountRequested;
        string description;
        string protocolName;
        string protocolDomain;
        address claimer;
        uint claimRequestDate;
    }

    mapping (uint => ClaimRequests) Requests;
    ClaimRequests[] allRequests;


    // ============================
    // CONSTRUCTOR
    // ============================

    constructor (address _tokenAddress) {
        admin = msg.sender;
        tokenAddress = _tokenAddress;
    }


    // ***************** //
    
     // WRITE FUNCTIONS
    
     // ***************** //

    /// @notice Function is called by from the insurance contract when there is a request for cover
    /// @dev This is funciton that allows the users from the insurance contract request for their claim
    /// @param _amountRequest: This is the amount of cover requested from the user
    /// @param _description: This is the reason given be the user to get their claims.

    function requestCoverClaim (
        uint _amountRequest,
        string memory _description,
        string memory _protocolName,
        string memory _protocolDomain,
        address _claimerAddress)
        public 
    {
        bool deposited = deposit(_amountRequest);
        require(deposited == true, "Deposit failed claim request failed");
        ClaimRequests storage claim = Requests[ID];
        claim.amountRequested = _amountRequest;
        claim.description = _description;
        claim.protocolName = _protocolName;
        claim.protocolDomain = _protocolDomain;
        claim.claimRequestDate = block.timestamp;
        claim.claimer = _claimerAddress;
        allRequests.push(claim);
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