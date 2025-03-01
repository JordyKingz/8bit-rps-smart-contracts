// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/structs/GameStructs.sol";
import {GameContract} from "../src/Game.sol";
import {Test, console} from "forge-std/Test.sol";

contract GameTest is Test {
    GameContract public game;
    address public teamVault = address(0xa0Ee7A142d267C1f36714E4a8F75612F20a79720); // index 9
    address public gameManager = address(0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f); // index 8
    address public owner = address(0x14dC79964da2C08b23698B3D3cc7Ca32193d9955); // index 7

    address public playerOne = address(0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc); // index 5
    address public playerTwo = address(0x976EA74026E726554dB657fA54763abd0C3a0aa9); // index 6

    uint[] public wagers = [0.01 ether, 0.05 ether, 0.1 ether, 0.2 ether, 0.5 ether, 1 ether];

    function setUp() public {
        _setup();
        vm.startPrank(owner);
        game = new GameContract(teamVault, gameManager);
        vm.stopPrank();
    }

    function test_createGame() public {
        uint256 gameIndex = game.GameIndexer();
        assertEq(gameIndex, 0);

        vm.startPrank(playerOne);
        game.CreateGame{value: wagers[0]}();
        vm.stopPrank();

        gameIndex = game.GameIndexer();
        assertEq(gameIndex, 1);

        GameStructs.Game memory gameData = game.GetGame(gameIndex);
        assertEq(gameData.Id, gameIndex);
        assertEq(gameData.Wager, wagers[0]);
        assertEq(gameData.PlayerOneAddress, playerOne);
        assertEq(gameData.PlayerTwoAddress, address(0));
        if (gameData.State != GameStructs.GameState.CREATED) {
            revert("Game State is not CREATED");
        }
        if (gameData.Result != GameStructs.GameResult.UNKNOWN) {
            revert("Game Result is not UNKNOWN");
        }
    }

    function test_CreateAndJoinGame() public {
        uint256 gameIndex = game.GameIndexer();
        assertEq(gameIndex, 0);

        vm.startPrank(playerOne);
        game.CreateGame{value: wagers[0]}();
        vm.stopPrank();

        gameIndex = game.GameIndexer();
        assertEq(gameIndex, 1);

        GameStructs.Game memory gameData = game.GetGame(gameIndex);

        vm.startPrank(playerTwo);
        game.JoinGame{value: gameData.Wager}(gameIndex);
        vm.stopPrank();

        gameData = game.GetGame(gameIndex);
        assertEq(gameData.Id, gameIndex);
        assertEq(gameData.Wager, wagers[0]);
        assertEq(gameData.PlayerOneAddress, playerOne);
        assertEq(gameData.PlayerTwoAddress, playerTwo);
        if (gameData.State != GameStructs.GameState.START) {
            revert("Game State is not START");
        }
        if (gameData.Result != GameStructs.GameResult.UNKNOWN) {
            revert("Game Result is not UNKNOWN");
        }
    }

    function test_CreateJoinSetGameResult() public {
        uint256 gameIndex = game.GameIndexer();
        assertEq(gameIndex, 0);

        vm.startPrank(playerOne);
        game.CreateGame{value: wagers[0]}();
        vm.stopPrank();

        uint256 p1BalanceBefore = playerOne.balance;

        gameIndex = game.GameIndexer();
        assertEq(gameIndex, 1);

        GameStructs.Game memory gameData = game.GetGame(gameIndex);

        vm.startPrank(playerTwo);
        game.JoinGame{value: gameData.Wager}(gameIndex);
        vm.stopPrank();

        uint256 TeamBalanceBefore = game.TeamVaultBalance();
        assertEq(TeamBalanceBefore, 0);
        uint256 TeamVaultBefore = game.TEAM_VAULT().balance;
        console.log("TeamVaultBefore: ", TeamVaultBefore);

        // playerOne ROCK 0
        // playerTwo Scissors 2
        vm.startPrank(gameManager);
        game.SetGameResult(gameIndex, playerOne, 0, 2); // playerOne wins
        vm.stopPrank();

        GameStructs.Game memory gameDataAfter = game.GetGame(gameIndex);
        assertEq(gameDataAfter.Id, gameIndex);
        assertEq(gameDataAfter.Wager, wagers[0]);
        assertEq(gameDataAfter.PlayerOneAddress, playerOne);
        assertEq(gameDataAfter.PlayerTwoAddress, playerTwo);
        assertEq(gameDataAfter.WinnerAddress, playerOne);
        if (gameDataAfter.State != GameStructs.GameState.RESULT_SET) {
            revert("Game State is not RESULT_SET");
        }
        if (gameDataAfter.Result != GameStructs.GameResult.PLAYER1) {
            revert("Game Result is not PLAYER1");
        }

        // include fee in calculations
//        uint256 p1BalanceAfter = playerOne.balance;
//        assertEq(p1BalanceAfter, p1BalanceBefore + gameDataAfter.Wager * 2);

        uint256 TeamBalanceAfter = game.TeamVaultBalance();
        assertGt(TeamBalanceAfter, 0);

        vm.startPrank(owner);
        game.WithdrawTeamVault();

        uint256 TeamVaultAfter = game.TEAM_VAULT().balance;
        assertGt(TeamVaultAfter, TeamVaultBefore);
        console.log("TeamVaultAfter: ", TeamVaultAfter);
    }

    function _setup() private {
        vm.deal(playerOne, 1 ether);
        vm.deal(playerTwo, 1 ether);
        vm.deal(gameManager, 1 ether);
        vm.deal(owner, 1 ether);
    }
}
