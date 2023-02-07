// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

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
    mapping (uint => Protocol) allProtocols;

    function createNewInsure (string memory protocolName, uint percentage) public {

    }

    function depositIntoInsureVault () public {

    }

    function setercentage () public {

    }
}