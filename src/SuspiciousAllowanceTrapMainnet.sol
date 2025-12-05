// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ITrap.sol";

interface IERC20 {
    function allowance(address owner, address spender) external view returns (uint256);
}

/// @notice Drosera trap monitoring suspicious USDC allowance increases in ETH Mainnet
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
        
        // Known phishing/drainer contracts/wallets
        SPENDERS_TO_MONITOR[10] = 0x29488E5fD6bF9B3cc98A9d06A25204947ccCBE4D;
        SPENDERS_TO_MONITOR[11] = 0x3453fBB87ddE4985c0a379969235c5D392152C2a;
        SPENDERS_TO_MONITOR[12] = 0xED7827cd7Fc27888CDd0C00E91ACc7Ce1C9463b7;
        SPENDERS_TO_MONITOR[13] = 0x293e6fA9505754d1e78e2C511d6126840b53DA9B;
        SPENDERS_TO_MONITOR[14] = 0x0c46044f98EF99BC6960071D10aC69b7488Dd615;
        SPENDERS_TO_MONITOR[15] = 0xc7aBA6484782Bb9e187A1dE73d50fFF649344Bb5;
        SPENDERS_TO_MONITOR[16] = 0x000037bB05B2CeF17c6469f4BcDb198826Ce0000;
        SPENDERS_TO_MONITOR[17] = 0x854dda621785DCA278df9b298825f2Ec32578B76;
        SPENDERS_TO_MONITOR[18] = 0x0000553F880fFA3728b290e04E819053A3590000;
        SPENDERS_TO_MONITOR[19] = 0x00001f78189bE22C3498cFF1B8e02272C3220000;
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
        // Guard 1: Require at least 2 data points
        if (data.length < 2) return (false, "");
        
        // Guard 2: Ensure data blobs are not empty
        if (data[0].length < 96 || data[1].length < 96) return (false, "");
        
        // Guard 3: Decode data
        (address[] memory ownersC, address[] memory spendersC, uint256[] memory allowancesC) =
            abi.decode(data[0], (address[], address[], uint256[]));
        
        (address[] memory ownersP, address[] memory spendersP, uint256[] memory allowancesP) =
            abi.decode(data[1], (address[], address[], uint256[]));
        
        // Guard 4: Validate array lengths match
        if (ownersC.length != ownersP.length) return (false, "");
        if (spendersC.length != spendersP.length) return (false, "");
        if (allowancesC.length != allowancesP.length) return (false, "");
        if (ownersC.length != spendersC.length) return (false, "");
        if (ownersC.length != allowancesC.length) return (false, "");
        
        // Guard 5: Ensure arrays are not empty
        if (ownersC.length == 0) return (false, "");
        
        // Check each spender for suspicious allowance increases
        for (uint256 i = 0; i < ownersC.length; i++) {
            if (ownersC[i] != ownersP[i] || spendersC[i] != spendersP[i]) {
                continue;
            }
            
            if (allowancesC[i] > allowancesP[i]) {
                uint256 delta = allowancesC[i] - allowancesP[i];
                
                if (delta >= THRESHOLD && !isWhitelisted(spendersC[i])) {
                    return (
                        true, 
                        abi.encode(
                            ownersC[i],
                            spendersC[i],
                            allowancesP[i],
                            allowancesC[i]
                        )
                    );
                }
            }
        }
        
        return (false, "");
    }
}
