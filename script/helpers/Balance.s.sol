// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;
import {Script, console} from "forge-std/Script.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Balance is Script {
    address public deployer = address(0x73673Baa430f20d45dA0d14073988d9F22db1C23);

    function run() public view {
        uint256 accountBalance = deployer.balance;
        console.log("accountBalance: ", accountBalance);
    }
}