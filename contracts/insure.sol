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

    uint40 public id = 1;
    address admin;
    address tokenAddress;
    uint8 protocolFee = 2;
    uint totalFeeGotten;
    uint8 governanceFee = 3;
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
        uint lastWithdrawal;
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
        string description;
        RiskLevel risklevel;
        address[] currentUsers;
        mapping (address => Users) UsersData;
        mapping ( address => RiskAsessor) RiskAsessors;
    }

    mapping (uint => Protocol) AllProtocols;


    // =============================
    //            EVENTS
    // =============================

    event NewInsure (string protocolName, string protocolDomain, uint totalCoverCreated, address creatorAddress, RiskLevel _risklevel, uint creationTime, uint _protocolID);
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
        external 
    {
        bool deposited = deposit(totalCoverAmount);
        require(deposited == true, "Deposit failed Insurance not created");
        Protocol storage Proto = AllProtocols[id];
        Proto.protocolName = protocolName;
        Proto.domainName = protocolDomain;
        Proto.totalCover += totalCoverAmount;
        Proto.risklevel = _risklevel;
        Proto.firstRiskProvider = msg.sender;
        Proto.description = _description;
        Proto.ID = id;
        Proto.RiskAsessors[msg.sender].totalCoverProvided = totalCoverAmount;
        Proto.RiskAsessors[msg.sender].initialCoverCreationDate = block.timestamp;
        
        emit NewInsure(protocolName, protocolDomain, totalCoverAmount, msg.sender, _risklevel, block.timestamp, id);

        id+= 1;
    }

    /// @notice Function allows new rsk assessors add more cover for existing protocol insurance
    /// @dev This funciton is called whenever a risk assessor wants to add cover for an already existing protocol insured
    /// @param _id: This is the ID of the Protocol insured 
    /// @param _coverAmount: Amount of cover created 
    function createOnExistinginsure (
        uint _id, 
        uint _coverAmount) 
        external 
    {
        bool deposited = deposit(_coverAmount);
        require(deposited == true, "Deposit failed Insurance not created");
        Protocol storage Proto = AllProtocols[_id];
        Proto.totalCover += _coverAmount;
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
        external
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
        external
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

    /// @notice Function is called by users after vote in governance to claim cover back
    /// @dev This funciton makes use of in interface to call the userWithdrawInsurance function from the governance contract
    function userGetClaim (
        uint _idOfClaimRequests) 
        external 
    {
         IGovernace(goveranceAddress).userWithdrawInsurance(_idOfClaimRequests);
    }

    /// @notice Riskassessor calls thisfunction to get claim back if the user loses the claim in the governane contract
    /// @dev This funciton calls the riskAssessorWithdrawInsurance function from the governance contract 
    /// @param _idOfClaimRequests: This is the id of the claim; 
    function riskAssessorGetsClaimBack (
         uint _idOfClaimRequests) 
         external 
    {
        (uint insureId, uint _refund) =  IGovernace(goveranceAddress).riskAssessorWithdrawInsurance(_idOfClaimRequests);
        Protocol storage Proto = AllProtocols[insureId];
        Proto.coverLeft += _refund;
    }

    /// @notice This funciton is called by the riskassessor to withdraw his profit 
    /// @dev The risk assessor calls this function to withdraw profit from covers bought by the users
    /// @param _id: This is the id of the claim; 
    function riskassessorWithdrawProfit (
        uint _id
    ) 
        external
    {
        Protocol storage Proto = AllProtocols[_id];
        uint totalclaimable = Proto.RiskAsessors[msg.sender].totalCoverProvided;
        uint totalclaim = Proto.totalCover;
        uint totalclaimPaid = Proto.totalCoverPaid;
        uint profitClaimable = (totalclaimable * totalclaimPaid) / totalclaim;
        uint _protocolfee = (profitClaimable * protocolFee) / 100;
        uint _governanceFee = (governanceFee * profitClaimable) / 100;
        uint profitSendable = profitClaimable - _protocolfee - _governanceFee;
        bool withdrawn = withdraw(msg.sender, profitSendable);
        require(withdrawn == true, "Couldn't perform the transaction");
        IGovernace(goveranceAddress).depositGovernanceFee(_governanceFee);
        Proto.RiskAsessors[msg.sender].totalCoverProvided = 0;
        totalFeeGotten += _protocolfee;
    }


    function  withDrawFee (address _feeAddress) 
        external 
    {
        onlyAdmin();
        bool withdrawn = withdraw(_feeAddress, totalFeeGotten);
        require(withdrawn == true, "Fee not withdrawn");
        totalFeeGotten = 0;
    }



    function riskassessorWithdrawCover(uint _id) 
        external
    {
        Protocol storage Proto = AllProtocols[_id];
        uint depositDate = Proto.RiskAsessors[msg.sender].initialCoverCreationDate;
        uint _lastWithdrawal = Proto.RiskAsessors[msg.sender].lastWithdrawal;
        require (block.timestamp >= (depositDate + 30 days));
        require (block.timestamp >= _lastWithdrawal);
        uint _totalCoverWithdrawable = Proto.coverLeft;
        uint _totalCover = Proto.totalCover;
        uint _riskAssessorCover = Proto.RiskAsessors[msg.sender].totalCoverProvided;
        uint withdrawable = ( _riskAssessorCover * _totalCoverWithdrawable) / _totalCover;
        bool withdrawn = withdraw(msg.sender, withdrawable);
        require(withdrawn == true, "Couldn't withdraw cover provided");
        Proto.coverLeft -= withdrawable;
        Proto.totalCover -= withdrawable;
        Proto.RiskAsessors[msg.sender].totalCoverProvided -= withdrawable;
        Proto.RiskAsessors[msg.sender].lastWithdrawal += 30 days;
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

    /// @dev This is a funcion used to set Governance contract address and can be called only by the admin

    function setGovernanceAddress (
        address _governanceAddress)
        external 
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
        external 
        view 
        returns 
        (RiskAsessor memory) 
    {
        Protocol storage proto =  AllProtocols[_id];
        return proto.RiskAsessors[msg.sender];
    }


     /// @dev This is a view function that returns the user data on certain protocol
    function viewProtocolCoverUser (uint _id) 
        external
        view 
        returns 
        (Users memory)
    {
        Protocol storage proto =  AllProtocols[_id];
        return proto.UsersData[msg.sender];
    }

     /// @dev This is a view function that returns all the users that bought cover in a protocol
    function getAllUsersOfProtocol (uint _id)
        external
        view
        returns
        (address[] memory) 
    {
         Protocol storage proto =  AllProtocols[_id];
         return proto.currentUsers;
    }

     /// @dev This is a view a view function that returns all the data of a protocol
    function getProtocolData (uint _id)
        external 
        view
        returns
        (uint,uint, uint, uint, string memory, string memory, string memory, RiskLevel)
    {
         Protocol storage proto =  AllProtocols[_id];
         return (proto.ID, proto.totalCover, proto.coverLeft, proto.totalCoverPaid, proto.protocolName, proto.domainName, proto.description, proto.risklevel);
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

    /// @notice Function to withdraw ERC20 token from the contract 
    /// @dev This is an internal funcion called by different functions to withdraw ERC20 token from the contract 
    /// @return sent the return value if the token was sent succssfully
 
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