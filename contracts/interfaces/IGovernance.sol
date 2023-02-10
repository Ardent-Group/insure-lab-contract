// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

interface IGovernace {

      function requestCoverClaim (uint _amountRequest,string memory _description,string memory _protocolName, string memory _protocolDomain,  address _claimerAddress )external;
}