// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ITrap.sol";

interface IERC20 {
    function allowance(address owner, address spender) external view returns (uint256);
}

/// @notice Production Drosera trap monitoring ANY suspicious USDC allowance increases
/// @dev Zero-arg constructor, collect() is view, shouldRespond() is pure
contract SuspiciousAllowanceTrapMainnet is ITrap {
    // ============ CONSTANTS ============
    
    // USDC on Ethereum Mainnet
    address public constant TOKEN = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    
    // 10,000 USDC threshold (6 decimals)
    uint256 public constant THRESHOLD = 10000 * 1e6;
    
    // Vitalik's mainnet wallet
    address public constant VITALIK = 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045;
    
    // Monitor allowances to these common contracts + unknown addresses
    address[20] private SPENDERS_TO_MONITOR;

    /// @notice Zero-arg constructor
    constructor() {
        // Common DeFi protocols (whitelisted in shouldRespond)
        SPENDERS_TO_MONITOR[0] = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;  // Uniswap V2 Router
        SPENDERS_TO_MONITOR[1] = 0xE592427A0AEce92De3Edee1F18E0157C05861564;  // Uniswap V3 Router
        SPENDERS_TO_MONITOR[2] = 0x1111111254EEB25477B68fb85Ed929f73A960582;  // 1inch V5 Router
        SPENDERS_TO_MONITOR[3] = 0xDef1C0ded9bec7F1a1670819833240f027b25EfF;  // 0x Exchange
        SPENDERS_TO_MONITOR[4] = 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;  // Uniswap Universal Router
        
        // Lending protocols
        SPENDERS_TO_MONITOR[5] = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9;  // Aave V2 Pool
        SPENDERS_TO_MONITOR[6] = 0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2;  // Aave V3 Pool
        SPENDERS_TO_MONITOR[7] = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;  // Compound
        
        // Other major protocols
        SPENDERS_TO_MONITOR[8] = 0x881D40237659C251811CEC9c364ef91dC08D300C;  // Metamask Swap Router
        SPENDERS_TO_MONITOR[9] = 0x11111112542D85B3EF69AE05771c2dCCff4fAa26;  // 1inch V4 Router
        
        // Known phishing/drainer addresses (https://github.com/MetaMask/eth-phishing-detect)
        SPENDERS_TO_MONITOR[10] = 0x5D4b914Fcd95802F2654EFe8690c6576A1296fcB; // Pink Drainer
        SPENDERS_TO_MONITOR[11] = 0x0eEc9a89c7f2B0D8b86ceCE10A17FA3D3f2d6D5f; // Inferno Drainer
        SPENDERS_TO_MONITOR[12] = 0x3b91Cf699Bc8d5DA3DE88BD9BDb4d6F4E8e7D6fC; // Monkey Drainer
        SPENDERS_TO_MONITOR[13] = 0x00000000A991C429eE2Ec6df19d40fe0c80088B8; // Fake Permit2
        SPENDERS_TO_MONITOR[14] = 0x1337DEF18C680aF1f9f45cBcab6309562975b1dD; // Recent phish
        SPENDERS_TO_MONITOR[15] = 0xC0F0f4ab324C46e55D02D0033343B4Be8A55532d; // Fake Seaport
        SPENDERS_TO_MONITOR[16] = 0xFe76f05dc59fEC04184fA0245AD0C3CF9a57b964; // Flagged wallet
        SPENDERS_TO_MONITOR[17] = 0x01e2919679362dFBC9ee1644Ba9C6da6D6245BB1; // Vyper exploit  // Correct checksum
    }

    /// @notice Collect current allowances for all monitored spenders
    /// @dev Returns (owners[], spenders[], allowances[])
    function collect() external view override returns (bytes memory) {
        uint256 len = SPENDERS_TO_MONITOR.length;
        
        address[] memory owners = new address[](len);
        address[] memory spenders = new address[](len);
        uint256[] memory allowances = new uint256[](len);
        
        // Check allowance for each spender
        for (uint256 i = 0; i < len; i++) {
            owners[i] = VITALIK;
            spenders[i] = SPENDERS_TO_MONITOR[i];
            
            // Query allowance from USDC contract
            try IERC20(TOKEN).allowance(VITALIK, SPENDERS_TO_MONITOR[i]) returns (uint256 allowance) {
                allowances[i] = allowance;
            } catch {
                allowances[i] = 0;
            }
        }
        
        return abi.encode(owners, spenders, allowances);
    }

    /// @notice Check if spender is whitelisted (trusted protocol)
    function isWhitelisted(address spender) internal pure returns (bool) {
        // Major DEXs
        if (spender == 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D) return true; // Uniswap V2
        if (spender == 0xE592427A0AEce92De3Edee1F18E0157C05861564) return true; // Uniswap V3
        if (spender == 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45) return true; // Uniswap Universal
        if (spender == 0x1111111254EEB25477B68fb85Ed929f73A960582) return true; // 1inch V5
        if (spender == 0x11111112542D85B3EF69AE05771c2dCCff4fAa26) return true; // 1inch V4
        if (spender == 0xDef1C0ded9bec7F1a1670819833240f027b25EfF) return true; // 0x Exchange
        if (spender == 0x881D40237659C251811CEC9c364ef91dC08D300C) return true; // Metamask Swap
        
        // Lending protocols
        if (spender == 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9) return true; // Aave V2
        if (spender == 0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2) return true; // Aave V3
        if (spender == 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B) return true; // Compound
        
        return false;
    }

    /// @notice Analyze allowance changes and trigger on suspicious increases
    /// @dev Pure function - compares current vs previous block data
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length < 2) return (false, "");

        // Decode current block data
        (address[] memory ownersC, address[] memory spendersC, uint256[] memory allowancesC) =
            abi.decode(data[0], (address[], address[], uint256[]));
        
        // Decode previous block data
        (address[] memory ownersP, address[] memory spendersP, uint256[] memory allowancesP) =
            abi.decode(data[1], (address[], address[], uint256[]));

        if (ownersC.length != ownersP.length) return (false, "");
        
        // Check each spender for suspicious allowance increases
        for (uint256 i = 0; i < ownersC.length; i++) {
            // Verify we're comparing the same owner/spender pair
            if (ownersC[i] != ownersP[i] || spendersC[i] != spendersP[i]) {
                continue;
            }
            
            // Check if allowance increased
            if (allowancesC[i] > allowancesP[i]) {
                uint256 delta = allowancesC[i] - allowancesP[i];
                
                // TRIGGER if: increase >= 10,000 USDC AND spender is NOT whitelisted
                if (delta >= THRESHOLD && !isWhitelisted(spendersC[i])) {
                    return (
                        true, 
                        abi.encode(
                            ownersC[i],      // owner (Vitalik)
                            spendersC[i],    // suspicious spender
                            allowancesP[i],  // previous allowance
                            allowancesC[i]   // new allowance
                        )
                    );
                }
            }
        }
        
        return (false, "");
    }
}
