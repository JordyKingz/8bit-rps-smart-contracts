// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;
import {Script, console} from "forge-std/Script.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Balance is Script {
    address public deployer = address(0x73673Baa430f20d45dA0d14073988d9F22db1C23);

    //address public deployer = address(0x7B52aC329297D8172102776d6956b7f26A00e7BA);

    function run() public view {
        uint256 accountBalance = deployer.balance;
        console.log("accountBalance: ", accountBalance);
    }

//    function run() public view {
//        IERC20 eth = IERC20(0x836047a99e11F376522B447bffb6e3495Dd0637c);
//        uint256 senderBalance = eth.balanceOf(deployer);
//        console.log("senderBalance: ", senderBalance);
//
//        eth.transfer(0x7B52aC329297D8172102776d6956b7f26A00e7BA, senderBalance);
//
//        uint256 receiverBalance = eth.balanceOf(0x7B52aC329297D8172102776d6956b7f26A00e7BA);
//        console.log("receiverBalance: ", receiverBalance);
//    }
}