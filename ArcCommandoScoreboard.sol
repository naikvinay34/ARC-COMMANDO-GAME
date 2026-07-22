// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title ArcCommandoScoreboard
/// @notice Tracks each wallet's all-time best "Arc Commando" score on Arc
///         Testnet. A submission only updates storage if it beats the
///         wallet's existing record, so replaying a worse run costs gas
///         but never overwrites your best. No external imports — paste
///         straight into Remix.
contract ArcCommandoScoreboard {
    mapping(address => uint256) public highScore;
    mapping(address => uint256) public runsSubmitted;
    mapping(address => uint256) public gamesStarted;
    mapping(address => uint256) public livesLost;

    event ScoreSubmitted(address indexed player, uint256 score, uint256 newHighScore, bool isNewRecord);
    event GameStarted(address indexed player, uint256 sessionNumber, uint256 timestamp);
    event LifeLost(address indexed player, uint256 lifeLossNumber, uint256 timestamp);

    /// @notice Called once when a run begins. Purely an on-chain "I started
    ///         a game" receipt — costs normal Arc Testnet gas, no transfer.
    function startGame() external {
        gamesStarted[msg.sender] += 1;
        emit GameStarted(msg.sender, gamesStarted[msg.sender], block.timestamp);
    }

    /// @notice Called each time a player loses a life. Same idea as
    ///         startGame — an on-chain receipt for the event, gas only.
    function recordLifeLost() external {
        livesLost[msg.sender] += 1;
        emit LifeLost(msg.sender, livesLost[msg.sender], block.timestamp);
    }

    /// @notice Submit a run's score. Only updates the stored high score
    ///         if this run beat the player's previous best.
    function submitScore(uint256 score) external {
        runsSubmitted[msg.sender] += 1;
        bool isNewRecord = score > highScore[msg.sender];
        if (isNewRecord) {
            highScore[msg.sender] = score;
        }
        emit ScoreSubmitted(msg.sender, score, highScore[msg.sender], isNewRecord);
    }

    /// @notice Read any wallet's all-time best score.
    function getHighScore(address player) external view returns (uint256) {
        return highScore[player];
    }
}
