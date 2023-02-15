require("dotenv").config({path: ".env"});
require("hardhat-tracer");
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-etherscan";



const FANTOM_RPC_URL = process.env.FANTOM_RPC_URL
const PRIVATE_KEY = process.env.PRIVATE_KEY
const API_KEY = process.env.API_KEY


module.exports = {
    solidity: "0.8.16",
    networks: {
        fantom: {
            url: FANTOM_RPC_URL,
            accounts: [PRIVATE_KEY]
        },
    },
    etherscan: {
        apiKey: API_KEY
    }
}