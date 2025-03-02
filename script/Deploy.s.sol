// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;
import {Script, console} from "forge-std/Script.sol";

import {GameContract} from "../src/Game.sol";

contract Deploy is Script {
    address public teamVault = address(0x7B52aC329297D8172102776d6956b7f26A00e7BA);
    address public gameManager = address(0x8427941818410c2519cbb294C70370458145ee64);

    address public deployer = address(0x73673Baa430f20d45dA0d14073988d9F22db1C23);
    function run() public {
//        _local();

        deploy();
    }

    function deploy() public {
        vm.startBroadcast();
        GameContract game = new GameContract(teamVault, gameManager);
        console.log("GameContract deployed at: ", address(game));
        console.log("TEAM_VAULT: ", game.TEAM_VAULT());
        console.log("GAME_MANAGER: ", game.GAME_MANAGER());
        vm.stopBroadcast();
    }

    function _local() private {
        teamVault = address(0xa0Ee7A142d267C1f36714E4a8F75612F20a79720); // Foundry9
        gameManager = address(0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f); // Foundry8

        uint256 account9 = vm.envUint("PRIVATE_KEY_9");
        vm.startBroadcast(account9);
        (bool success,) = deployer.call{value: 1 ether}("");
        require(success, "Transfer failed.");
        vm.stopBroadcast();
    }
}
