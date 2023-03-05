//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDT is ERC20 {
    constructor() ERC20('Mock USDT', 'mUSDT') {
        _mint(msg.sender, 1000000000 * 10 ** 18);
    }
    
    function mint(address to, uint amount) external {
        _mint(to, amount);
    }
    
    function burn(uint amount) external {
        _burn(msg.sender, amount);
    }
}