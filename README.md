# Suspicious Allowance Trap 🛡️

A Drosera security trap that monitors ERC20 token allowances and detects suspicious approval patterns on Ethereum mainnet.

## 🎯 Overview

This trap monitors high-profile wallets (like Vitalik Buterin) for suspicious USDC approval increases that could indicate:
- Phishing attacks
- Compromised wallets
- Social engineering attempts
- Approval-based exploits

**Alert Threshold:** 10,000 USDC

## 📋 Deployed Contracts

| Contract | Address | Network |
|----------|---------|---------|
| **Trap Config** | `0xcd40636DbEDe1D60e4046534cE4154DbD4B4C288` | Ethereum Mainnet |
| **Response Contract** | `0x9650910581cBbFa4f9B1E55d14339DDeAdC88d5C` | Ethereum Mainnet |
| **Drosera Network** | `0x01C344b8406c3237a6b9dbd06ef2832142866d87` | Ethereum Mainnet |

## 🏗️ Architecture
```
┌─────────────────────────────────────────────────────────┐
│                    ETHEREUM MAINNET                      │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Response Contract (On-Chain)                            │
│  └─ executeAllowance(...) → Emits Alert Event           │
│                         ▲                                │
│                         │ Transaction (if triggered)     │
└─────────────────────────┼──────────────────────────────┘
                          │
┌─────────────────────────┼──────────────────────────────┐
│              DROSERA OPERATOR NETWORK                    │
├─────────────────────────┼──────────────────────────────┤
│                                                          │
│  Every Block: Shadow Fork Deployment                     │
│  └─ collect() → Get current allowances                   │
│  └─ shouldRespond() → Analyze for suspicious activity   │
└──────────────────────────────────────────────────────────┘
```

## 🔧 Features

- ✅ Real-time monitoring of USDC allowances
- ✅ Whitelisted DEX routers (no false positives)
- ✅ Zero-arg constructor for Drosera operators
- ✅ Hardcoded constants for gas efficiency
- ✅ Comprehensive test suite
- ✅ Mainnet deployment ready

## 📦 Installation
```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/suspicious-allowance-trap.git
cd suspicious-allowance-trap

# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Install dependencies
forge install

# Build contracts
forge build
```

## 🧪 Testing
```bash
# Run all tests
forge test

# Run with verbose output
forge test -vvv

# Run specific test
forge test --match-test test_trigger_on_spike -vvv

# Gas report
forge test --gas-report
```

## 🚀 Deployment

### Deploy Response Contract
```bash
forge script script/DeployResponseContract.s.sol \
  --rpc-url mainnet \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify
```

### Register with Drosera
```bash
# Build the deployable trap
forge build

# Apply to Drosera network
drosera apply --private-key $PRIVATE_KEY
```

## 📊 Configuration

### Monitored Wallet
- **Vitalik Buterin:** `0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045`

### Token
- **USDC:** `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48`

### Whitelisted Spenders (No Alerts)
- Uniswap V2 Router: `0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D`
- Uniswap V3 Router: `0xE592427A0AEce92De3Edee1F18E0157C05861564`
- 1inch V5 Router: `0x1111111254EEB25477B68fb85Ed929f73A960582`
- 0x Exchange: `0xDef1C0ded9bec7F1a1670819833240f027b25EfF`

## 📁 Project Structure
```
suspicious-allowance-trap/
├── src/
│   ├── SuspiciousAllowanceTrap.sol          # Configurable trap
│   ├── SuspiciousAllowanceTrapMainnet.sol   # Deployable (zero-arg)
│   ├── ResponseContract.sol                  # Alert handler
│   ├── MockERC20.sol                        # Test token
│   └── ITrap.sol                            # Drosera interface
├── test/
│   └── SuspiciousAllowanceTrap.t.sol        # Test suite
├── script/
│   ├── DeployResponseContract.s.sol         # Deploy response
│   └── AddMonitoringPairs.s.sol            # Add monitored addresses
├── drosera.toml                             # Drosera config
└── foundry.toml                             # Foundry config
```

## 🔍 How It Works

1. **Continuous Monitoring:** Drosera operators run the trap in shadow fork every block
2. **Data Collection:** `collect()` reads USDC allowances for monitored pairs
3. **Analysis:** `shouldRespond()` compares current vs previous block allowances
4. **Threshold Check:** Triggers if increase ≥ 10,000 USDC and spender not whitelisted
5. **Automated Response:** Calls `executeAllowance()` on response contract
6. **On-Chain Event:** Emits `SuspiciousAllowanceDetected` for community awareness

## 🛡️ Security

- **Zero-arg constructor:** Operators deploy bytecode with no configuration attack surface
- **Hardcoded constants:** No storage manipulation possible
- **Whitelisting:** Prevents false positives from legitimate DEX interactions
- **Audited interface:** Uses standard Drosera ITrap interface

## 📈 Gas Efficiency

| Function | Gas Usage |
|----------|-----------|
| `collect()` | ~46,246 gas |
| `shouldRespond()` | ~46,930 gas |

## 🔗 Links

- [Trap Config (Etherscan)](https://etherscan.io/address/0xcd40636DbEDe1D60e4046534cE4154DbD4B4C288)
- [Response Contract (Etherscan)](https://etherscan.io/address/0x9650910581cBbFa4f9B1E55d14339DDeAdC88d5C)
- [Drosera Documentation](https://docs.drosera.io)
- [Drosera Network](https://drosera.io)

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details

## ⚠️ Disclaimer

This trap is for educational and security research purposes. Always audit smart contracts before mainnet deployment. The authors are not responsible for any losses incurred from using this code.

## 🙏 Acknowledgments

- Built with [Foundry](https://github.com/foundry-rs/foundry)
- Powered by [Drosera Network](https://drosera.io)
- Inspired by the need for real-time DeFi security

---

**Built with ❤️ by Affan**
