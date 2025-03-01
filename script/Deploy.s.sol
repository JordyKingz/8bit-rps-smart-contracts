// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;
import {Script, console} from "forge-std/Script.sol";

import {GameContract} from "../src/Game.sol";

// First step in process
// Generate new monad-deployer account
// cast wallet import monad-deployer --private-key $(cast wallet new | grep 'Private key:' | awk '{print $3}')
// print wallet address
// cast wallet address --account monad-deployer # 0x73673Baa430f20d45dA0d14073988d9F22db1C23


// Local forge script script/Deploy.s.sol:Deploy --sender 0x73673Baa430f20d45dA0d14073988d9F22db1C23 --rpc-url $RPC_URL_LOCAL --account monad-deployer --broadcast
// Sepolia forge script script/Deploy.s.sol:Deploy --rpc-url $RPC_URL_DEV --account monad-deployer --broadcast
// Prd forge script script/Deploy.s.sol:Deploy --rpc-url $RPC_URL_PRD --broadcast
contract Deploy is Script {
    address public teamVault = address(0x7B52aC329297D8172102776d6956b7f26A00e7BA); // Firefox account 1
    address public gameManager = address(0x8427941818410c2519cbb294C70370458145ee64); // Firefox account 5

    address public deployer = address(0x73673Baa430f20d45dA0d14073988d9F22db1C23);
    function run() public {
        _local();

        deploy();
    }

    function deploy() public {
        vm.startBroadcast();
        GameContract game = new GameContract(teamVault, gameManager);
        console.log("GameContract deployed at: ", address(game));
        vm.stopBroadcast();
    }

    function _local() private {
        uint256 account9 = vm.envUint("PRIVATE_KEY_9");
        vm.startBroadcast(account9);
        (bool success,) = deployer.call{value: 1 ether}("");
        require(success, "Transfer failed.");
        vm.stopBroadcast();
    }
}
