// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "./interfaces/IERC20.sol";
import "./interfaces/IGovernance.sol";

contract insure {

    // ============================
    // CONSTRUCTOR
    // ============================

    constructor (address _tokenAddress) {
        admin = msg.sender;
        tokenAddress = _tokenAddress;
    }
    // ============================
    // STATE VARIABLE
    // ============================

    uint40 id = 1;
    address admin;
    address tokenAddress;
    address goveranceAddress;
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
        uint covePaidFor;
        uint dateBought;
        bool requestedCover;
    }
    struct Protocol {
        uint ID;
        uint totalCover;
        uint coverLeft;
        uint totalCoverPaid;
        string protocolName;
        address firstRiskProvider;
        string domainName;
        RiskLevel risklevel;
        address[] currentUsers;
        mapping (address => Users) UsersData;
        mapping ( address => RiskAsessor) RiskAsessors;
    }

    Protocol[] allProtocols;
    mapping (uint => Protocol) AllProtocols;


    // =============================
    //            EVENTS
    // =============================

    event NewInsure (string protocolName, string protocolDomain, uint totalCoverCreated, address creatorAddress, RiskLevel _risklevel, uint creationTime);
    event AddOnExistingInsure (string protocolName, string protocolDomain, uint coverAdded, address creatorAddress, uint creationTime);
    event CoverBought (string protocol, uint totalCoverBought, uint amountPaid, uint totalPeriod,  RiskLevel _risklevel);
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
        Proto.firstRiskProvider = msg.sender;
        Proto.RiskAsessors[msg.sender].description = _description;
        Proto.RiskAsessors[msg.sender].totalCoverProvided = totalCoverAmount;
        Proto.RiskAsessors[msg.sender].initialCoverCreationDate = block.timestamp;
        // allProtocols.push(Proto);
        id+= 1;
        // _mint(msg.sender, totalCoverAmount);
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


    /// @notice Function is called by users to buy cover
    /// @dev This funciton is called by users to buy cover
    /// @param _id: This is the ID of the Protocol cover that is been bought
    /// @param _coverPeriod: This is the period a user is covering for
    /// @param _coverAmount: This is the amount of cover the user is buying 

    function buyCover (
        uint _id,  
        uint _coverPeriod,
        uint _coverAmount) 
        public 
    {
        Protocol storage Proto = AllProtocols[_id];
        RiskLevel levelOfRisk = Proto.risklevel;
        uint coverToPay = calculateCover(levelOfRisk, _coverPeriod, _coverAmount);
        bool deposited = deposit(coverToPay);
        require(deposited == true, "Deposit failed Insurance not created");
        require(Proto.coverLeft >= _coverAmount, "Not enough cover left for you");
        Proto.UsersData[msg.sender].totalCoverBought += _coverAmount;
        Proto.coverLeft -= _coverAmount;
        Proto.UsersData[msg.sender].dateBought += block.timestamp + (_coverPeriod * 1 days);
        Proto.UsersData[msg.sender].covePaidFor += coverToPay;
        Proto.totalCoverPaid += coverToPay;
        Proto.UsersData[msg.sender].requestedCover = false;
        Proto.currentUsers.push(msg.sender);
        emit CoverBought(Proto.protocolName, _coverAmount, coverToPay, _coverPeriod, levelOfRisk);
    }


    /// @notice Function is called by users to request for their insurance cover when there is a protocol compromise
    /// @dev This is a public funciton called by users to get their cover, this function calls another frunction from the governance called requestCoverClaim
    /// @param _id: This is the ID of the Protocol cover that is been bought
    /// @param _description: This is the reason given be the user to get their claims.

    function userRequestCover (
        uint _id,
        string memory _description) 
        public 
    {
        Protocol storage Proto = AllProtocols[_id];
        uint date = Proto.UsersData[msg.sender].dateBought;
        require(date >= block.timestamp, "You can't claim cover, period over");
        require( Proto.UsersData[msg.sender].requestedCover == false, "You can't request twice");
        uint _userCover = Proto.UsersData[msg.sender].totalCoverBought;
        IGovernace(goveranceAddress).requestCoverClaim(_userCover, _description, Proto.protocolName, Proto.firstRiskProvider, msg.sender, _id);
        Proto.UsersData[msg.sender].requestedCover = true;
        Proto.UsersData[msg.sender].totalCoverBought = 0;
        // Proto.coverLeft -=  _userCover;
    }

    function userGetClaim (
        uint _idOfClaimRequests) 
        public 
    {
         IGovernace(goveranceAddress).userWithdrawInsurance(_idOfClaimRequests);
    }

    function riskAssessorGetsClaimBack (
         uint _idOfClaimRequests) 
         public 
    {
        (uint insureId, uint _refund) =  IGovernace(goveranceAddress).riskAssessorWithdrawInsurance(_idOfClaimRequests);
        Protocol storage Proto = AllProtocols[insureId];
        Proto.coverLeft += _refund;
    }


    function riskassessorWithdrawProfit (
        uint _id
    ) 
        public
    {
         Protocol storage Proto = AllProtocols[_id];
        uint totalclaimable = Proto.RiskAsessors[msg.sender].totalCoverProvided;
        uint totalclaim = Proto.totalCover;
        uint totalclaimPaid = Proto.totalCoverPaid;
        uint profitClaimable = (totalclaimable * totalclaimPaid) / totalclaim;
        bool withdrawn = withdraw(msg.sender, profitClaimable);
        require(withdrawn == true, "Couldn't perform the transaction");
        Proto.RiskAsessors[msg.sender].totalCoverProvided = 0;
    }

    function riskassessorWithdrawClaimBack() 
        public
    {

    }

    function riskassessor() 
        public
    {

    }

    /// @dev This is a funcion used to set token address and can be called only by the admin
    function setTokenAddress (
        address _tokenAddress) 
        external 
    {
        onlyAdmin();
        addressZeroCheck(_tokenAddress);
        tokenAddress = _tokenAddress;
    }

    function setGovernanceAddress (
        address _governanceAddress)
        public 
    {
        onlyAdmin();
        addressZeroCheck(_governanceAddress);
        goveranceAddress =_governanceAddress;
    }

     // ***************** //
    // VIEW FUNCTIONS
    // ***************** //

     /// @dev This is a view function that returns the risk asessor data
    function viewRiskAssessorData (uint _id) 
        public 
        view 
        returns 
        (RiskAsessor memory) 
    {
        Protocol storage proto =  AllProtocols[_id];
        return proto.RiskAsessors[msg.sender];
    }


     /// @dev This is a view function that returns the user data on certain protocol
    function viewProtocolCoverUser (uint _id) 
        public
        view 
        returns 
        (Users memory)
    {
        Protocol storage proto =  AllProtocols[_id];
        return proto.UsersData[msg.sender];
    }

     /// @dev This is a view function that returns all the users that bought cover in a protocol
    function getAllUsersOfProtocol (uint _id)
        public
        view
        returns
        (address[] memory) 
    {
         Protocol storage proto =  AllProtocols[_id];
         return proto.currentUsers;
    }

     /// @dev This is a view a view function that returns all the data of a protocol
    function getProtocolData (uint _id)
        public 
        view
        returns
        (uint,uint, uint, uint, string memory, string memory)
    {
         Protocol storage proto =  AllProtocols[_id];
         return (proto.ID, proto.totalCover, proto.coverLeft, proto.totalCoverPaid, proto.protocolName, proto.domainName);
    }  


    // ***************** //
    // INTERNAL FUNCTIONS
    // ***************** //


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
        internal 
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

      function withdraw (
        address _to,
        uint _amount)
        private
        returns (bool sent)
    {
        amountMustBeGreaterThanZero(_amount);
        sent = IERC20(tokenAddress).transfer(_to, _amount);
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

    /// @notice this is the internal function used to check that address must be greater than zero
    /// @param _amount: this is the amount you want to check
    function amountMustBeGreaterThanZero(uint _amount) internal pure {
        require(_amount > 0, "Amount must be greater than zero");
    }

  
    


}