// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "./IERC20.sol";

contract insure {

    // ============================
    // CONSTRUCTOR
    // ============================

    constructor () {
        admin = msg.sender;
    }
    // ============================
    // STATE VARIABLE
    // ============================

    uint40 id = 1;
    address admin;
    address tokenAddress;
    uint8 constant VERY_LOW = 0;
    uint8 constant LOW = 20;
    uint8 constant MEDIUM = 40;
    uint8 constant HIGH = 60;
    uint8 constant VERY_HIGH = 80;
    uint16 constant PERCENTAGE = 1000;
    uint16 constant YEAR = 365;

    enum RiskLevel {
        very_low,
        low,
        medium,
        high,
        very_high
    }
    struct RiskAsessor {
        uint totalCoverProvided;
        uint initialCoverCreationDate;
        string description;
    }

    struct Users {
        uint totalCoverBought;
        uint dateBought;
    }
    struct Protocol {
        uint ID;
        uint totalCover;
        uint coverLeft;
        string protocolName;
        string domainName;
        RiskLevel risklevel;
        mapping ( address => RiskAsessor) RiskAsessors;
        mapping (address => Users) UsersData;
    }

    Protocol[] allProtocols;
    mapping (uint => Protocol) AllProtocols;


    // =============================
    //            EVENTS
    // =============================

    event NewInsure (string protocolName, string protocolDomain, uint totalCoverCreated, address creatorAddress, RiskLevel _risklevel, uint creationTime);
    event AddOnExistingInsure (string protocolName, string protocolDomain, uint coverAdded, address creatorAddress, uint creationTime);
    
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
        string memory _description,
        uint totalCoverAmount,
        RiskLevel _risklevel) 
        public 
    {
        bool deposited = deposit(totalCoverAmount);
        require(deposited == true, "Deposit failed Insurance not created");
        Protocol storage Proto = AllProtocols[id];
        Proto.protocolName = protocolName;
        Proto.domainName = protocolDomain;
        Proto.totalCover += totalCoverAmount;
        Proto.risklevel = _risklevel;
        Proto.RiskAsessors[msg.sender].description = _description;
        Proto.RiskAsessors[msg.sender].totalCoverProvided = totalCoverAmount;
        Proto.RiskAsessors[msg.sender].initialCoverCreationDate = block.timestamp;
        // allProtocols.push(Proto);
        id+= 1;
        emit NewInsure(protocolName, protocolDomain, totalCoverAmount, msg.sender, _risklevel, block.timestamp);
    }

    /// @notice Function allows new rsk assessors add more cover for existing protocol insurance
    /// @dev This funciton is called whenever a risk assessor wants to add cover for an already existing protocol insured
    /// @param _id: This is the ID of the Protocol insured 
    /// @param _coverAmount: Amount of cover created 
    function createOnExistinginsure (
        uint _id, 
        uint _coverAmount,
        string memory _description) 
        public 
    {
        bool deposited = deposit(_coverAmount);
        require(deposited == true, "Deposit failed Insurance not created");
        Protocol storage Proto = AllProtocols[_id];
        Proto.totalCover += _coverAmount;
        Proto.RiskAsessors[msg.sender].description = _description;
        Proto.RiskAsessors[msg.sender].totalCoverProvided += _coverAmount;
        Proto.RiskAsessors[msg.sender].initialCoverCreationDate = block.timestamp;
        emit AddOnExistingInsure(Proto.protocolName, Proto.domainName, _coverAmount, msg.sender, block.timestamp);
    }

    
    /// @notice Function is used to calculate the total cover for a user
    /// @dev This funciton is a pure function that is called to calculate cover for a user
    /// @param _riskLevel: This is the level of risk involved for the user
    /// @param _coverPeriod: This is the period a user is covering for
    /// @param _coverAmount: This is the amount of cover the user is buying 
     function calculateCover (
        RiskLevel _riskLevel,
        uint _coverPeriod,
        uint _coverAmount
     ) 
        public 
        pure
        returns (uint cover)
    {
        if (_riskLevel == RiskLevel.very_low) {
            cover = ((VERY_LOW + 25) * (_coverPeriod * _coverAmount))/ (uint256(PERCENTAGE) * YEAR);
        }
        else if (_riskLevel == RiskLevel.low) {
            cover = ((LOW + 25) * (_coverPeriod * _coverAmount))/ (uint256(PERCENTAGE) * YEAR);
        }
        else if (_riskLevel == RiskLevel.medium) {
            cover = ((MEDIUM + 25) * (_coverPeriod * _coverAmount))/ (uint256(PERCENTAGE) * YEAR); 
        }
        else if (_riskLevel == RiskLevel.high) {
             cover = ((HIGH + 25) * (_coverPeriod * _coverAmount))/ (uint256(PERCENTAGE) * YEAR);
        }
        else {
             cover = ((VERY_HIGH + 25) * (_coverPeriod * _coverAmount))/ (uint256(PERCENTAGE) * YEAR);
        }
    }

    function buyCover (uint _id,  
        uint _coverPeriod,
        uint _coverAmount) 
        public 
    {

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

     /// @dev This is a private function used to allow only an admin call a function
    function onlyAdmin () 
        private 
        view
    {
        require(msg.sender == admin, "Not admin");
    }

     /// @dev This is a private funcion used to check for address zero
    function addressZeroCheck (address depositAddress) private pure {
        require(depositAddress != address(0));
    }

     /// @dev This is a funcion used to set token address and can be called only by the admin
    function setTokenAddress (
        address _tokenAddress) 
        external 
    {
        onlyAdmin();
        tokenAddress = _tokenAddress;
    }

   


}