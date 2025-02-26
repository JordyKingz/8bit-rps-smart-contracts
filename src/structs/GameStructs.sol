pragma solidity ^0.8.12;

library GameStructs {
    struct Game {
        uint Id;
        address PlayerAddress;
        GameAction Action;
        GameResult Result;
        uint Wager;
        GameState State;
        bool Exists;
    }

    enum GameResult {
        UNKNOWN,
        WIN,
        LOSE,
        TIE
    }

    enum GameAction {
        ROCK,
        PAPER,
        SCISSORS
    }

    enum GameState {
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