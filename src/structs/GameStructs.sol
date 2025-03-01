pragma solidity ^0.8.12;

library GameStructs {
    struct Game {
        uint Id;
        address PlayerOneAddress;
        address PlayerTwoAddress;
        address WinnerAddress;
        GameAction PlayerOneAction;
        GameAction PlayerTwoAction;
        GameResult Result;
        uint Wager;
        GameState State;
        bool Exists;
    }

    enum GameResult {
        UNKNOWN,
        DRAW,
        PLAYER1,
        PLAYER2
    }

    enum GameAction {
        ROCK,
        PAPER,
        SCISSORS
    }

    enum GameState {
        CREATED,
        START,
        WAGER_SET,
        RESULT_SET,
        CANCELED
    }
}

//struct Game {
//    uint Id;
//    address PlayerAddress;
//    GameResult Result;
//    GameAction Action;
//    uint Wager;
//    GameState State;
//    bool Exists;
//}
//
//enum GameResult {
//    UNKNOWN,
//    WIN,
//    LOSE,
//    TIE
//}
//
//enum GameAction {
//    ROCK,
//    PAPER,
//    SCISSORS
//}
//
//enum GameState {
//    WAGER_SET,
//    RESULT_SET,
//    CANCELED
//}