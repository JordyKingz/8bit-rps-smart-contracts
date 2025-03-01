// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;
import {Script, console} from "forge-std/Script.sol";

import {GameContract} from "../src/Game.sol";

// source .env
// forge script script/FundPlayers.s.sol:FundPlayers --rpc-url $RPC_URL_LOCAL --broadcast
contract FundPlayers is Script {
    address public player = address(0x7482B336283041386942fC106Fd47F99976D1A06);
    address public player2 = address(0x7B52aC329297D8172102776d6956b7f26A00e7BA);

    address[3] public players = [
        address(0x7482B336283041386942fC106Fd47F99976D1A06),
        address(0x7B52aC329297D8172102776d6956b7f26A00e7BA),
        address(0xA8BdE64407298A43320f5Fd0c529d3C03d0D9AB1)
    ];

    function run() public {
        uint256 account9 = vm.envUint("PRIVATE_KEY_9");
        vm.startBroadcast(account9);

        for (uint i = 0; i < players.length; i++) {
            fundPlayer(players[i]);
        }

//        (bool success,) = player.call{value: 1 ether}("");
//        require(success, "Transfer failed.");
//
//        (bool successP2,) = player2.call{value: 1 ether}("");
//        require(successP2, "Transfer failed.");

        vm.stopBroadcast();

    }

    function fundPlayer(address _player) private {
        console.log("Funded player: ", _player);
        (bool success,) = _player.call{value: 1 ether}("");
        require(success, "Transfer failed.");
    }
}
