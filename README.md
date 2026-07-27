# Arc Commando — a wallet-linked Arc Testnet platformer

**Latest update:** added a boss fight at the end of every level — each
one visually distinct (color/horns/eyes match its level's theme),
with its own attack pattern, and gets tougher level over level
(Meadow Brute → Sandstorm Djinn → Frost Titan → Shadow Wyrm). The
flag won't activate until the boss is defeated. Also added a magnet
power-up that pulls nearby $USDC coins toward you, replaced the HUD's
generic "SCORE" with a `$USDC` counter showing coins collected, and
put the ArcMan character image on the start screen under the title.
Levels are ~20 tiles longer than before (the boss arena itself). See
"Known simplifications" below for the honest limits of this pass.

A browser-playable, original 2D platformer (own character "Commando",
own art — not Nintendo's Mario) built for **Arc Testnet** (Circle's
stablecoin-native L1, chain ID `5042002`). Connect any EVM wallet and:

- **every installed browser wallet is listed individually** via
  EIP-6963 discovery (MetaMask, Rabby, Coinbase Wallet, Brave Wallet,
  etc. all show up as separate buttons if you have more than one
  installed) — plus a WalletConnect option for any mobile wallet via
  QR code
- **you must connect a wallet to play** — the Start button stays
  locked until you do
- **connecting a wallet is gasless** — it's a plain `personal_sign`
  message signature, not a blockchain transaction, so it costs zero
  gas. It just proves the wallet controls that address before you're
  let in.
- **starting a game pays a real entry fee — once** — a real signed
  transaction that costs Arc Testnet gas, charged only when you click
  Start / Try Again / Play Again. Losing a life does NOT sign
  anything — 3 lives = 1 paid game, exactly one transaction per game.
  If you've deployed `ArcCommandoScoreboard.sol` and set
  `SCOREBOARD_ADDRESS`, the entry fee calls `startGame()` on that
  contract. If you haven't deployed it yet, it falls back to a plain
  0-value self-transfer instead — still a real signature, still real
  (small) gas, it just doesn't write to a custom contract until you
  deploy one.
- **4 themed levels** (Countryside → Sun-Scorched Desert → Frostbyte
  Peaks → Deep Cavern), each with its own color palette and layout.
  Clearing a level's flag shows a free "Continue" screen (no
  transaction) into the next level; clearing the final level triggers
  the full win screen with score-save and badge-mint.
- **Bounce-Tales-style springs** (bounce pads that launch you much
  higher than a normal jump) and **spike hazards** (instant life loss
  on contact) are scattered through the levels alongside the existing
  glitches, armored insects, gun pickup, and extra-life pickup.
- if your wallet has no gas, a **faucet button** appears after
  connecting, linking straight to the Circle faucet for Arc Testnet
- your **all-time best score** is read from an on-chain scoreboard and
  shown every time you play
- finishing a run lets you **save your score on-chain** (only updates
  your record if it's a new best)
- finishing the level lets you **mint a one-per-wallet completion
  badge NFT**
- **background music and sound effects** are synthesized live in the
  browser with the Web Audio API — an original bouncy chiptune loop
  plus SFX for every action, no external audio files. (It can't
  reproduce the actual Super Mario theme — that melody is Nintendo's
  copyrighted work — but it's written to sit in the same energetic,
  bouncy platformer spirit.) A 🔊/🔇 button in the HUD mutes everything.
- if a contract address in `config.js` is still the placeholder zero
  address, a **warning banner** appears on the start screen explaining
  exactly what still works via the self-transfer fallback and what
  needs the real contract deployed (on-chain best score, save-score,
  badge mint).
- **fully responsive layout** — the game stage scales to fit any
  screen using both width and height constraints (so it never
  overflows on short/landscape phones), all text and buttons scale
  with the stage size via CSS container queries instead of fixed
  pixel sizes, touch controls only appear on touch devices, and the
  footer hides on very short viewports to save space.

On real ERC-4337 "gasless" transactions (where a third party pays gas
for the user, not just a free signature): Arc supports account
abstraction for this, but it requires a paymaster service — a
third-party provider like Pimlico or Biconomy, which means signing up
for an account and an API key, similar to what you did for
WalletConnect. That's a separate, bigger integration than this repo
sets up; the connect step here uses a plain signature instead, which
gets you the "no gas to connect" result without needing that
infrastructure.

Heads up on UX: only starting/retrying a game asks for a wallet
signature and gas — losing a life is instant and free, so a rough run
never means a wall of signature prompts.

No build step, no npm install — it's plain HTML/CSS/JS. Open
`index.html` in any browser, or host it (GitHub Pages / Vercel, see
below).

## Files

```
index.html                          # the game: canvas, physics, controls, wallet + mint UI
assets/character-body.png           # player character sprite (head/torso/arms) — legs are drawn procedurally for the running animation
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
- **Springs** launch you much higher than a normal jump — Bounce-Tales
  style. **Spikes** cost a life on contact — jump over them.
- Reach the beacon (flag) to complete the level

Every level's pit gaps are capped at 3 tiles wide, which is safely
inside the character's maximum jump range (~5.6 tiles at full run
speed) — the maps are generated and validated by a script (checks
pit width, row-length consistency, and that spawn/flag both sit on
solid ground) rather than hand-typed ASCII art, specifically so a
level can never accidentally contain an uncrossable gap.

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
   - Repeat for `contracts/ArcCommandoScoreboard.sol` — this one now also has `connectWallet()`, `startGame()`, and `recordLifeLost()`, called automatically by the game on connect, on run start, and on each life lost.
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

## Known simplifications (this pass)

- **The boss doesn't physically block the path** — there's no wall,
  so a player can technically walk past it toward the flag. The flag
  just won't trigger completion until `boss.defeated` is true, so
  they'll have to walk back and fight. Adding an actual barrier that
  drops on boss defeat would be the next improvement here.
- **Bosses are entirely canvas-drawn** (gradients, glowing eyes, horn
  silhouettes that vary by pattern) — there's no boss artwork/sprite
  like the ArcMan character image, since none was provided for them.
- **"Longer levels"** was implemented as a dedicated ~20-tile boss
  arena appended to the end of each existing level, rather than
  hand-editing more content into the middle of every level — lower
  risk of breaking already-tuned platforming, but the middle sections
  themselves aren't longer than before.

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
