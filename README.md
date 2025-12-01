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

# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Install dependencies
forge install

# Build
forge build
```

## 🧪 Testing
```bash
# Run tests
forge test -vvv

# Verify compliance
./verify_drosera_compliance.sh

# Gas report
forge test --gas-report
```

## 🚀 Deployment

### 1. Deploy Response Contract (One-time)
```bash
forge script script/DeployResponseContract.s.sol \
  --rpc-url mainnet \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify
```

### 2. Register with Drosera
```bash
# Build trap
forge clean && forge build

# Verify compliance
./verify_drosera_compliance.sh

# Register
drosera apply --private-key $PRIVATE_KEY
```

## 📁 Project Structure
```
suspicious-allowance-trap-mainnet/
├── src/
│   ├── SuspiciousAllowanceTrapMainnet.sol  # Main trap (zero-arg)
│   ├── ResponseContract.sol                 # On-chain responder
│   └── ITrap.sol                           # Drosera interface
├── test/
│   └── SuspiciousAllowanceTrap.t.sol       # Production tests
├── script/
│   └── DeployResponseContract.s.sol        # Deploy response only
├── drosera.toml                            # Drosera config
├── verify_drosera_compliance.sh            # Compliance checker
└── DROSERA_DEPLOYMENT.md                   # Deployment guide
```

## 🔍 How It Works

1. **Every Block:** Operators deploy trap in shadow fork
2. **collect():** Queries allowances for 20 spenders
3. **shouldRespond():** Compares with previous block
4. **If triggered:** Calls `executeAllowance()` on mainnet
5. **Event emitted:** `SuspiciousAllowanceDetected`

## 🛡️ Security

- **No on-chain deployment:** Trap runs in operator shadow forks
- **Hardcoded config:** No storage manipulation possible
- **Pure functions:** No state dependencies
- **Whitelisting:** Prevents false positives from legitimate DeFi

## 📈 Gas Efficiency

| Function | Gas Usage |
|----------|-----------|
| `collect()` | ~92,000 gas (20 allowance checks) |
| `shouldRespond()` | ~50,000 gas |

## 🔗 Links

- [Response Contract](https://etherscan.io/address/0x9650910581cBbFa4f9B1E55d14339DDeAdC88d5C)
- [Drosera Docs](https://docs.drosera.io)
- [Drosera Network](https://drosera.io)

## 📄 License

MIT License - see [LICENSE](LICENSE)

## ⚠️ Disclaimer

Educational and security research purposes. Audit before production use.

---

**Built with ❤️ by [Affan](https://github.com/Affanuu)**
