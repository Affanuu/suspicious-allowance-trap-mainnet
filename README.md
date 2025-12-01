# Suspicious Allowance Trap Mainnet

> Production-ready Drosera security trap monitoring ANY suspicious USDC allowance increases on Ethereum mainnet.

## What does the trap does

This Trap is designed Monitors Vitalik Buterin's wallet for **ANY** suspicious USDC approval increases:
-  Tracks common DeFi contracts + unknown addresses
-  Alerts on approvals ≥10,000 USDC to non-whitelisted spenders
-  Catches phishing attacks, compromised wallets, and malicious approvals
-  Real-time detection

## How the trap works
```
Drosera Operators
  └─ Deploy trap every block
  └─ Call collect() → Check spender allowances
  └─ Call shouldRespond() → Detect suspicious increases
  └─ Trigger response if alert threshold exceeded
       └─ Call executeAllowance() on Ethereum mainnet
            └─ Emit SuspiciousAllowanceDetected event
```

### Monitoring
- **Token:** USDC (`0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48`)
- **Wallet:** Vitalik Buterin (`0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045`)
- **Threshold:** 10,000 USDC

### Whitelisted address on the trap (No Alerts)
- Uniswap V2, V3, Universal Router
- 1inch V4, V5
- 0x Exchange
- Metamask Swap
- Aave V2, V3
- Compound

## 📦 Installation
```bash
# Clone
git clone https://github.com/Affanuu/suspicious-allowance-trap-mainnet.git
cd suspicious-allowance-trap-mainnet

# Install dependencies, Build & Test
forge install
forge build
forge test -vvv

```
## Deploy
```bash
forge script script/DeployResponseContract.s.sol \
  --rpc-url mainnet \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify
```




