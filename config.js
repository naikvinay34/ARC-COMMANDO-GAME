// -----------------------------------------------------------------
// Arc Testnet network configuration.
// Source: https://docs.arc.io (Circle's Arc public testnet)
// -----------------------------------------------------------------
const ARC_TESTNET = {
  chainId: 5042002, // 0x4cef52
  chainName: "Arc Testnet",
  nativeCurrency: { name: "USD Coin", symbol: "USDC", decimals: 18 },
  rpcUrls: ["https://rpc.testnet.arc.network"],
  blockExplorerUrls: ["https://testnet.arcscan.app"],
};

// -----------------------------------------------------------------
// 1) Badge contract — deploy contracts/LevelCompleteBadge.sol, then
//    paste its address here.
// -----------------------------------------------------------------
const CONTRACT_ADDRESS = "0x0000000000000000000000000000000000000000";

// -----------------------------------------------------------------
// 2) Scoreboard contract — deploy contracts/ArcCommandoScoreboard.sol,
//    then paste its address here. This is what stores each wallet's
//    all-time best score on-chain.
// -----------------------------------------------------------------
const SCOREBOARD_ADDRESS = "0x0000000000000000000000000000000000000000";

// -----------------------------------------------------------------
// 3) WalletConnect Project ID — required to let players connect ANY
//    EVM wallet (not just an injected one like MetaMask) via QR code /
//    deep link. Get a free one at https://cloud.reown.com (formerly
//    WalletConnect Cloud): sign up, create a project, copy the
//    Project ID below. It's tied to your app/domain, so you must
//    generate your own — this can't be pre-filled for you.
// -----------------------------------------------------------------
const WALLETCONNECT_PROJECT_ID = "YOUR_WALLETCONNECT_PROJECT_ID";
