// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/structs/GameStructs.sol";
import {GameContract} from "../src/Game.sol";
import {Test, console} from "forge-std/Test.sol";

contract CounterTest is Test {
    GameContract public game;
    address public teamVault = address(0xa0Ee7A142d267C1f36714E4a8F75612F20a79720); // index 9
    address public gameManager = address(0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f); // index 8
    address public owner = address(0x14dC79964da2C08b23698B3D3cc7Ca32193d9955); // index 7

    function setUp() public {
        game = new GameContract(address(0x0), address(0x0));
    }

    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }
}
