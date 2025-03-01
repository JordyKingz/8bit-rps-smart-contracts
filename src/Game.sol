// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./structs/GameStructs.sol";

// deployed at 0xD9bb50605AB2F021d7a44a2b5fCA18254ae5C2C8
contract GameContract is Ownable, ReentrancyGuard {
    uint public GAME_FEE = 7 ether;
    uint public TOTAL_PERCENTAGE = 100 ether;
    uint public MAX_WAGER = 1 ether;

    address payable public TEAM_VAULT;
    address public GAME_MANAGER;

    uint public TeamVaultBalance;
    uint public NFTVaultBalance;

    uint public GameIndexer;

    mapping (uint => GameStructs.Game) public Games;

    event Received(address sender, uint value);
    event GameCreated(uint gameId, uint wager, address player);
    event GameJoined(uint gameId, GameStructs.GameState state, address player);
    event GameStateSet(uint gameId, GameStructs.GameState state, address winner);
    event GameEnded(uint gameId, GameStructs.GameAction playerOneResult, GameStructs.GameAction playerTwoResults, address winner);
    event GameCancelled(uint gameId, GameStructs.GameResult result, address player);
    event WithdrawnTeamVault(uint value);

    constructor(
        address _teamVault,
        address _gameManager
    ) Ownable(_msgSender()) {
        TEAM_VAULT = payable(_teamVault);
        GAME_MANAGER = _gameManager;
    }

    /**
     * @dev     Modifier to set game results
     * @notice  Offchain service to handle game results
    */
    modifier OnlyGameManager() {
        require(GAME_MANAGER == _msgSender(), "Error: Sender is not the game manager");
        _;
    }

    /**
     * @dev Receive funds when Treasury is running low
     */
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }


    /**
     * @dev Function for checking if a game exists and return Game
     * @param _gameId the id of the game
     * @return Game
    */
    function GetGame(uint _gameId) nonReentrant external returns(GameStructs.Game memory) {
        _validGame(_gameId);
        return Games[_gameId];
    }

    function CreateGame() nonReentrant external payable returns (uint gameId) {
        require(msg.value > 0, "Error: Can't set 0 as wager");
        require(msg.value <= MAX_WAGER, "Error: Wager can't be more than MAX_WAGER");

        GameIndexer += 1;
        gameId = GameIndexer;
        Games[gameId].Id = gameId;
        Games[gameId].PlayerOneAddress = _msgSender();
        Games[gameId].Wager = msg.value;
        Games[gameId].Result = GameStructs.GameResult.UNKNOWN;
        Games[gameId].State = GameStructs.GameState.CREATED;
        Games[gameId].Exists = true;

        emit GameCreated(gameId, Games[gameId].Wager, Games[gameId].PlayerOneAddress);
        return gameId;
    }

    function JoinGame(uint _gameId) nonReentrant external payable returns (uint) {
        _validGame(_gameId);
        _requireState(_gameId, GameStructs.GameState.CREATED);
        GameStructs.Game storage game = Games[_gameId];
        require(msg.value == game.Wager, "Error: Wager must be equal to the first player's wager");
        require(game.Result == GameStructs.GameResult.UNKNOWN, "Error: Game is already played");

        game.PlayerTwoAddress = _msgSender();
        game.State = GameStructs.GameState.START;

        emit GameJoined(_gameId, game.State, game.PlayerTwoAddress);
        return _gameId;
    }

    function SetDraw(uint _gameId, uint _action) nonReentrant OnlyGameManager external returns (bool) {
        _validGame(_gameId);
        _requireState(_gameId, GameStructs.GameState.START);

        GameStructs.Game storage game = Games[_gameId];
        require(address(this).balance >= (game.Wager * 2), "Error: Not enough funds in contract for payout");

        game.Result = GameStructs.GameResult.DRAW;
        game.WinnerAddress = address(0);
        game.State = GameStructs.GameState.RESULT_SET;
        game.PlayerOneAction = GameStructs.GameAction(_action);
        game.PlayerTwoAction = GameStructs.GameAction(_action);
        uint256 returnWager = game.Wager;

        uint paybackAmount = _takeGameFee(returnWager);

        emit GameEnded(_gameId, GameStructs.GameAction(_action), GameStructs.GameAction(_action), address(0));
        (bool successP1, ) = payable(game.PlayerOneAddress).call{value:paybackAmount}('Transfer back wager');
        require(successP1, "Error: Returning back wager to player failed");
        (bool successP2, ) = payable(game.PlayerTwoAddress).call{value:paybackAmount}('Transfer back wager');
        require(successP2, "Error: Returning back wager to player failed");

        return successP1 && successP2;
    }

    function SetGameResult(uint _gameId, address _winner, uint _p1, uint _p2) nonReentrant OnlyGameManager external returns (bool) {
        _validGame(_gameId);
        _requireState(_gameId, GameStructs.GameState.START);
        require(_winner != address(0), "Error: Winner address is 0");

        GameStructs.Game storage game = Games[_gameId];
        require(address(this).balance >= (game.Wager * 2), "Error: Not enough funds in contract for payout");

        if (_winner == game.PlayerOneAddress) {
            game.Result = GameStructs.GameResult.PLAYER1;
        } else if (_winner == game.PlayerTwoAddress) {
            game.Result = GameStructs.GameResult.PLAYER2;
        } else {
            revert("Error: Winner address is not a player");
        }

        game.WinnerAddress = _winner;
        game.State = GameStructs.GameState.RESULT_SET;
        game.PlayerOneAction = GameStructs.GameAction(_p1);
        game.PlayerTwoAction = GameStructs.GameAction(_p2);
        uint winValue = game.Wager * 2;

        uint amountToWinner = _takeGameFee(winValue);

        emit GameEnded(_gameId, GameStructs.GameAction(_p1), GameStructs.GameAction(_p1), _winner);
        (bool success, ) = payable(_winner).call{value:amountToWinner}('Transfer back double wager');
        require(success, "Error: Returning back wager to player failed");

        return success;
    }

    /**
     * @dev Function to withdraw wager from unplayed game
     * @param _gameId the id of the game
     * @return gameId
    */
    function WithdrawWager(uint _gameId) nonReentrant external returns(uint) {
        _validGame(_gameId);
        _requireState(_gameId, GameStructs.GameState.CREATED);
        GameStructs.Game storage game = Games[_gameId];
        require(game.PlayerOneAddress == _msgSender(), "Error: Only game owner can withdraw wager");
        uint wager = game.Wager;
        game.Wager = 0;
        game.State = GameStructs.GameState.CANCELED;
        (bool success, ) = game.PlayerOneAddress.call{value:wager}('Transfer back wager');
        require(success, "Error: Returning back wager to player failed");
        emit GameCancelled(_gameId, game.Result, _msgSender());
        return _gameId;
    }

    /**
    * @dev Owner function for setting MAX_WAGER value
     * @param _newWager the new MAX_WAGER value
    */
    function SetMaxWager(uint _newWager) onlyOwner external returns(uint) {
        require(_newWager > 0, "Error: New wager must be greater than 0");
        MAX_WAGER = _newWager;
        return MAX_WAGER;
    }

    /**
     * @dev Owner function for setting GAME MANAGER
     * @param _newManager new address of manager
    */
    function SetGameManager(address _newManager) onlyOwner external returns(address) {
        require(_newManager != address(0), "Error: New owner is 0 address");
        GAME_MANAGER = _newManager;
        return GAME_MANAGER;
    }

    /**
     * @dev Owner function for setting TEAM_VAULT
     * @param _newVault new address of TEAM_VAULT
    */
    function SetTeamVault(address _newVault) onlyOwner external returns(address) {
        require(_newVault != address(0), "Error: New vault is 0 address");
        if (TEAM_VAULT.balance > 0) {
            (bool success, ) = payable(owner()).call{value:TEAM_VAULT.balance}('Transfer current team balance to owner');
            require(success, "Error: Transfer balance to owner failed");
        }
        TEAM_VAULT = payable(_newVault);
        return TEAM_VAULT;
    }

    /**
     * @dev Owner function for transferring the TeamVaultBalance to the TEAM_VAULT Address
    */
    function WithdrawTeamVault() nonReentrant onlyOwner external {
        require(TeamVaultBalance > 0, "Error: TeamVaultBalance is 0");
        uint teamVault = TeamVaultBalance;
        TeamVaultBalance = 0;
        (bool success, ) = payable(TEAM_VAULT).call{value:teamVault}('Transfer TeamVaultBalance balance to TEAM_VAULT');
        require(success, "Error: Transfer to TEAM_VAULT failed");
        emit WithdrawnTeamVault(teamVault);
    }

    function _takeGameFee(uint _wager) private returns(uint) {
        uint fee = _wager * GAME_FEE / TOTAL_PERCENTAGE;
        TeamVaultBalance += fee;
        uint amountToWinner =  _wager - fee;
        return amountToWinner;
    }

    /**
     * @dev Private function to check if game exists
     * @param _gameId the id of the game
    */
    function _validGame(uint _gameId) private view {
        require(Games[_gameId].Exists, "Error: Game doesn't exist");
    }

    /**
     * @dev Private function to check if game has the right state for execution
     * @param _gameId the id of the game
     * @param _state the required state of the game
    */
    function _requireState(uint _gameId, GameStructs.GameState _state) private view {
        require(Games[_gameId].State == _state, "Error: Game state don't match");
    }
}
