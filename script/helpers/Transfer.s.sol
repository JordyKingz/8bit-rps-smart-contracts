// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;
import {Script, console} from "forge-std/Script.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Transfer is Script {
    address public deployer = address(0x73673Baa430f20d45dA0d14073988d9F22db1C23);

    address public tokenAddress = address(0x836047a99e11F376522B447bffb6e3495Dd0637c);
    address public receiver = address(0x73673Baa430f20d45dA0d14073988d9F22db1C23);

    function run() public {
//        transferToken();
//        transferNative();
    }

    function transferToken() public {
        IERC20 token = IERC20(tokenAddress);
        uint256 senderBalance = token.balanceOf(deployer);
        console.log("senderBalance: ", senderBalance);

        token.transfer(receiver, senderBalance);

        uint256 receiverBalance = token.balanceOf(receiver);
        console.log("receiverBalance: ", receiverBalance);
    }

    function transferNative() public {
        uint256 accountBalance = deployer.balance;
        console.log("accountBalance: ", accountBalance);
        (bool success,) = receiver.call{value: accountBalance}("");
        require(success, "Transfer failed.");

        uint256 receiverBalance = receiver.balance;
        console.log("receiverBalance: ", receiverBalance);
    }
}