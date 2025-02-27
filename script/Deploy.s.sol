// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;
import {Script, console} from "forge-std/Script.sol";

import {GameContract} from "../src/Game.sol";

// First step in process
// Generate new monad-deployer account
// cast wallet import monad-deployer --private-key $(cast wallet new | grep 'Private key:' | awk '{print $3}')
// print wallet address
// cast wallet address --account monad-deployer # 0x73673Baa430f20d45dA0d14073988d9F22db1C23


// Local forge script script/Deploy.s.sol:Deploy --rpc-url $RPC_URL_LOCAL --account monad-deployer --broadcast
// Sepolia forge script script/Deploy.s.sol:Deploy --rpc-url $RPC_URL_DEV --broadcast
// Prd forge script script/Deploy.s.sol:Deploy --rpc-url $RPC_URL_PRD --broadcast
contract Deploy is Script {
    address public teamVault = address(0xa0Ee7A142d267C1f36714E4a8F75612F20a79720); // index 9
    address public gameManager = address(0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f); // index 8

    address public deployer = address(0x73673Baa430f20d45dA0d14073988d9F22db1C23);

    address public player = address(0x7482B336283041386942fC106Fd47F99976D1A06);
    function run() public {
        uint256 account9 = vm.envUint("PRIVATE_KEY_9");
        vm.startBroadcast(account9);
        (bool success,) = deployer.call{value: 1 ether}("");
        require(success, "Transfer failed.");


        (bool success,) = player.call{value: 1 ether}("");
        require(success, "Transfer failed.");
        vm.stopBroadcast();

        deploy();
//        deployLocal();
//        deploySepolia();
        // deployMainnet();
    }


    function deploy() public {
        vm.startBroadcast();
        GameContract game = new GameContract(teamVault, gameManager);
        console.log("GameContract deployed at: ", address(game));
        vm.stopBroadcast();
    }

//    function deploy(uint256 deployerPrivateKey) public {
//        vm.startBroadcast(deployerPrivateKey);
//
//        GameContract game = new GameContract();
//        console.log("GameContract deployed at: ", address(game));
//        vm.stopBroadcast();
//    }
//
//    function deployLocal() public {
//        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_LOCAL");
//        address deployer = vm.envAddress("DEPLOYER_LOCAL");
//        return deploy(deployerPrivateKey);
//    }
//
//    function deploySepolia() public {
//        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_DEV");
//        address deployer = vm.envAddress("DEPLOYER_DEV");
//        return deploy(deployerPrivateKey);
//    }
//
//    function deployMainnet() public {
//        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_PRD");
//        address deployer = vm.envAddress("DEPLOYER_PRD");
//        return deploy(deployerPrivateKey);
//    }
}
