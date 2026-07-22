# Arc Commando — a wallet-linked Arc Testnet platformer

A browser-playable, original 2D platformer (own character "Commando",
own art — not Nintendo's Mario) built for **Arc Testnet** (Circle's
stablecoin-native L1, chain ID `5042002`). Connect any EVM wallet —
via a browser extension or WalletConnect (any mobile wallet, scan a
QR code) — and:

- **you must connect a wallet to play** — the Start button stays
  locked until you do
- **starting a run signs an on-chain transaction** (`startGame()`)
  on Arc Testnet — real gas, no value transfer
- **every life you lose signs another on-chain transaction**
  (`recordLifeLost()`) before the loss is applied — the game pauses
  with a "confirm in wallet" overlay each time
- if your wallet has no gas, a **faucet button** appears after
  connecting, linking straight to the Circle faucet for Arc Testnet
- your **all-time best score** is read from an on-chain scoreboard and
  shown every time you play
- finishing a run lets you **save your score on-chain** (only updates
  your record if it's a new best)
- finishing the level lets you **mint a one-per-wallet completion
  badge NFT**
- **background music and sound effects** are synthesized live in the
  browser with the Web Audio API — no external audio files, so
  there's nothing to license or host. A 🔊/🔇 button in the HUD mutes
  everything.

Heads up on UX: because every life lost asks for a wallet signature,
a rough run can mean several signature prompts in a row. That's by
design here, but worth knowing before you hand this to playtesters —
it trades smooth gameplay for an on-chain paper trail of every life
lost.

No build step, no npm install — it's plain HTML/CSS/JS. Open
`index.html` in any browser, or host it (GitHub Pages / Vercel, see
below).

## Files

```
index.html                          # the game: canvas, physics, controls, wallet + mint UI
config.js                           # Arc Testnet params, contract addresses, WalletConnect Project ID
contracts/LevelCompleteBadge.sol    # minimal ERC-721 badge contract, no imports
contracts/ArcCommandoScoreboard.sol # on-chain best-score-per-wallet contract, no imports
README.md                           # this file
```

## Gameplay

- **Move / jump**: arrow keys or WASD, Space or ↑ to jump (desktop);
  on-screen pad (mobile)
- **Coins**: +50 score each
- **Glitches** (small purple enemies): stomp or shoot, +100/+150
- **Armored insects** (red, 3 hit points shown as pips above them):
  block your path — stomp or shoot them 3 times to clear the way,
  +250 on kill
- **◆ Gun pickup**: lets you shoot forward with X (desktop) or the 🔫
  button (mobile) — a short cooldown between shots
- **♥ Extra-life pickup**: +1 life, up to 9
- Reach the beacon (flag) to complete the level

## 1. Get a WalletConnect Project ID (required for the WalletConnect button)

The "🦊 Browser Wallet" button works out of the box with any injected
wallet (MetaMask, Rabby, Coinbase Wallet extension, etc). The
"🔗 WalletConnect" button — which lets players connect *any* EVM
wallet via QR code / deep link, including mobile-only wallets — needs
a free Project ID tied to your app:

1. Go to https://cloud.reown.com (formerly WalletConnect Cloud) and sign up.
2. Create a new project, choose "AppKit" or the plain "WalletConnect" SDK.
3. Copy the **Project ID** it gives you.
4. Paste it into `config.js`:
   ```js
   const WALLETCONNECT_PROJECT_ID = "your-project-id-here";
   ```

This can't be pre-filled for you — it's tied to your account/domain.
Until you set it, the WalletConnect button will explain what's
missing; the browser-wallet button works regardless.

## 2. Deploy the two contracts to Arc Testnet

You need a wallet with Arc Testnet configured and a little test USDC
for gas.

1. **Add Arc Testnet to your wallet**:
   - Network name: `Arc Testnet`
   - RPC URL: `https://rpc.testnet.arc.network`
   - Chain ID: `5042002`
   - Currency symbol: `USDC`
   - Block explorer: `https://testnet.arcscan.app`
2. **Get test USDC** from the Arc faucet (linked from https://docs.arc.io) to cover gas.
3. **Deploy both contracts** via [Remix](https://remix.ethereum.org) (no install needed):
   - Paste in `contracts/LevelCompleteBadge.sol`, compile with Solidity `0.8.20+`, deploy with Environment set to "Injected Provider" on Arc Testnet.
   - Repeat for `contracts/ArcCommandoScoreboard.sol` — this one now also has `startGame()` and `recordLifeLost()`, called automatically by the game when a run starts and each time a life is lost.
   - Both files have zero imports, so they also drop straight into Hardhat/Foundry if you'd rather use those.

If a player's wallet has no testnet USDC, the "🚰 Get Testnet USDC" button that appears after connecting sends them to https://faucet.circle.com (official Circle faucet, select Arc Testnet). For developer-focused daily claims there's also https://arc-faucet.dev.
4. **Copy both deployed addresses** into `config.js`:
   ```js
   const CONTRACT_ADDRESS   = "0xYourBadgeContractAddress";
   const SCOREBOARD_ADDRESS = "0xYourScoreboardContractAddress";
   ```

## 3. Push to GitHub

I can't push to your GitHub account directly — no access to your
credentials. Run this locally, or use GitHub's web UI ("Add file →
Upload files"):

```bash
cd arc-commando
git init
git add .
git commit -m "Arc Commando: wallet-linked Arc Testnet platformer"
git branch -M main
git remote add origin https://github.com/<your-username>/<your-repo>.git
git push -u origin main
```

## 4. Deploy to Vercel

Go to https://vercel.com/new, "Import Git Repository," pick the repo
you just pushed. It's static HTML — no build settings needed. You'll
get a `https://your-repo.vercel.app` URL that works in any browser,
desktop or mobile.

(GitHub Pages also works if you'd rather: repo → Settings → Pages →
Deploy from branch `main`, folder `/root`.)

## Notes

- The game and character are original — not using any Nintendo/Mario
  assets, names, or trademarks, so it's safe to host publicly.
- Arc Testnet is a test network — badges and scores have no monetary
  value; it's a fun on-chain proof of play.
- `submitScore` only overwrites your stored high score if the new run
  beats it, so replaying a worse run costs a bit of gas but never
  erases your record.
- Wallet connection is optional — the game is fully playable without
  it, you just won't see a best score or be able to save one.
