# Rock Paper Scissors (PvP) - Monad Testnet

## Overview
This is a **Player vs Player (PvP) Rock Paper Scissors** game developed with **Foundry** and deployed on the **Monad Testnet**. Players can wager tokens, challenge opponents, and earn in-game currency (**ByteBucks**) as they compete.

🔗 **Live Game:** [Play Now](https://rps8bit.xyz)

## Features
- **Smart Contract-Based Gameplay:** Players deposit wagers into the smart contract when creating or joining a game.
- **PvP Battles:** Face off against another player in Rock Paper Scissors.
- **Off-Chain Service:** A **Django** service with **WebSockets** handles game logic and updates.
- **Automatic Payouts:**
    - **Win:** The winner receives **double** their wager.
    - **Tie:** Both players receive their original wagers back.
- **Earn ByteBucks:** Every game rewards players with **ByteBucks**, an in-game currency to be used in **Phase 2**.

## How It Works
1. **Game Creation** - A player initiates a game by transferring their wager to the smart contract.
2. **Joining a Game** - Another player joins by matching the wager.
3. **Game Execution** - Both players select Rock, Paper, or Scissors.
4. **Result Processing** - The off-chain Django service determines the outcome and updates the smart contract:
    - **Winner:** Receives **double** their wager.
    - **Tie:** Both players receives back their wager.
5. **ByteBucks Rewards** - Players earn in-game currency for participating.

## Tech Stack
- **Smart Contracts:** Foundry (Solidity)
- **Blockchain:** Monad Testnet
- **Backend:** Django with WebSockets
- **Frontend:** Vue

## Getting Started
### Prerequisites
- Foundry installed: [Install Foundry](https://book.getfoundry.sh/getting-started/installation)
- Monad Testnet wallet setup

### Deploying the Smart Contract
```sh
forge build
forge test
forge script script/Deploy.s.sol:Deploy --rpc-url <MONAD_RPC_URL> --private-key <PRIVATE_KEY> --broadcast
```

## Roadmap (Phase 2)
- **ByteBucks:** Earn Yields with ByteBucks.
- **Tournaments & Events:** Compete in special events.

## Contributing
Pull requests and improvements are welcome! Feel free to submit issues or suggestions.

## License
MIT License

