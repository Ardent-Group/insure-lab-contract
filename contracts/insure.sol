// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "./IERC20.sol";

contract insure {


 // Insurance providers 
 // 1. function to create a platform 
 // 2. function to add deposit into it for the cover
 // 3. function to set the percentage 
 
 // admins fuction 
 // function to approve a particular protocol submited 
 
 // Users function 
 // function to chose an insurance 
 // function to set the date to insure  


    // ============================
    // CONSTRUCTOR
    // ============================

    constructor () {
        admin = msg.sender;
    }
    // ============================
    // STATE VARIABLE
    // ============================

    uint id = 1;
    address admin;
    address tokenAddress;

    enum riskLevel {
        very_low,
        low,
        meddium,
        high,
        very_high
    }
    struct RiskAsessor {
        uint totalCoverProvided;
        uint initialCoverCreationDate;
    }
    struct Protocol {
        uint ID;
        uint totalCover;
        string protocolName;
        string domainName;
        string description;
        mapping ( address => RiskAsessor) RiskAsessors;
    }

    Protocol[] allProtocols;
    mapping (uint => Protocol) AllProtocols;


    // =============================
    //            EVENTS
    // =============================

    event NewInsure (string protocolName, string protocolDomain, uint totalCoverCreated, address creatorAddress);

    
    // ***************** //
    
     // WRITE FUNCTIONS
    
     // ***************** //

    /// @notice Function that creates new insurance cover for a protocol
    /// @dev This funciton is called whenever a risk assessor wants to create a new cover for a protocol
    /// @param protocolName: This is the name of the protocol the insurer is creating cover for
    /// @param protocolDomain: This is link to the domain of the procotol
    /// @param totalCoverAmount: The total amount of cover that is been staked for the protocol 
    function createNewInsure (
        string memory protocolName,
        string memory protocolDomain, 
        uint totalCoverAmount ) 
        public 
    {
        bool deposited = deposit(totalCoverAmount);
        require(deposited == true, "Deposit failed Insurance not created");
    }

    /// @notice Function to deposit ERC20 token into the contract 
    /// @dev This is an internal funcion called by different functions to deposit ERC20 token into the contract 
    /// @return sent the return variables of a contract’s function state variable
 
    function deposit(
        uint _amount) 
         internal 
         returns (bool sent)
    {
       sent = IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount);
    }

    function onlyAdmin () 
        private 
        view
    {
        require(msg.sender == admin, "Not admin");
    }

    function addressZeroCheck (address depositAddress) private {

    }

    function setTokenAddress (
        address _tokenAddress) 
        external 
    {
        onlyAdmin();
        tokenAddress = _tokenAddress;
    }

    function calculateCover () 
        public 
    {

    }
}