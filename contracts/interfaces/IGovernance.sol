// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

interface IGovernace {

    function requestCoverClaim (uint _amountRequest,string memory _description,string memory _protocolName, address _riskProvider,  address _claimerAddress, uint _insuranceID )external;
    function userWithdrawInsurance (uint _idClaimRequests) external;
    function riskAssessorWithdrawInsurance (uint _idClaimRequests) external returns (uint _insuranceID, uint refund); 
    function depositGovernanceFee (uint _amount)external;
}