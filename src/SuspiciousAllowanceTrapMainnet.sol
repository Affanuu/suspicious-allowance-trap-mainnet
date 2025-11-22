// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ITrap.sol";

interface IERC20 {
    function allowance(address owner, address spender) external view returns (uint256);
}

/// @notice This trap is deployed by Drosera operators in shadow fork with zero-arg constructor
/// @dev All configuration must be hardcoded constants or read from on-chain config contract
contract SuspiciousAllowanceTrapMainnet is ITrap {
    // ============ HARDCODED CONSTANTS ============
    // These cannot be changed - operators deploy this bytecode as-is
    
    // USDC on Ethereum Mainnet
    address public constant TOKEN = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    
    // 10,000 USDC threshold (USDC has 6 decimals)
    uint256 public constant THRESHOLD = 10000 * 1e6;
    
    // Monitored addresses - hardcoded for this trap
    address public constant VITALIK = 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045;
    
    // Potential suspicious spenders to watch
    address public constant SPENDER_1 = 0x0000000000000000000000000000000000000001;
    address public constant SPENDER_2 = 0x0000000000000000000000000000000000000002;
    address public constant SPENDER_3 = 0x0000000000000000000000000000000000000003;

    /// @notice Zero-arg constructor required for Drosera operators
    constructor() {
        // No initialization needed - all config is hardcoded constants
    }

    /// @notice Collect current allowance data for monitored pairs
    /// @dev Called by operators every block in shadow fork
    function collect() external view override returns (bytes memory) {
        // Fixed set of 3 monitoring pairs
        address[] memory owners = new address[](3);
        address[] memory spenders = new address[](3);
        uint256[] memory allowances = new uint256[](3);
        
        // Pair 1: Vitalik -> Spender 1
        owners[0] = VITALIK;
        spenders[0] = SPENDER_1;
        allowances[0] = IERC20(TOKEN).allowance(VITALIK, SPENDER_1);
        
        // Pair 2: Vitalik -> Spender 2
        owners[1] = VITALIK;
        spenders[1] = SPENDER_2;
        allowances[1] = IERC20(TOKEN).allowance(VITALIK, SPENDER_2);
        
        // Pair 3: Vitalik -> Spender 3
        owners[2] = VITALIK;
        spenders[2] = SPENDER_3;
        allowances[2] = IERC20(TOKEN).allowance(VITALIK, SPENDER_3);
        
        return abi.encode(owners, spenders, allowances);
    }

    /// @notice Check if spender is whitelisted (trusted DEX)
    /// @param spender Address to check
    function isWhitelisted(address spender) internal pure returns (bool) {
        // Uniswap V2 Router
        if (spender == 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D) return true;
        // Uniswap V3 Router
        if (spender == 0xE592427A0AEce92De3Edee1F18E0157C05861564) return true;
        // 1inch V5 Router
        if (spender == 0x1111111254EEB25477B68fb85Ed929f73A960582) return true;
        // 0x Exchange Proxy
        if (spender == 0xDef1C0ded9bec7F1a1670819833240f027b25EfF) return true;
        return false;
    }

    /// @notice Analyze collected data and determine if response needed
    /// @param data Array of encoded (owners, spenders, allowances) from previous blocks
    /// @return shouldRespond True if suspicious activity detected
    /// @return responseData Encoded (owner, spender, prevAllowance, currAllowance)
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length < 2) return (false, "");

        // Current block data
        (address[] memory ownersC, address[] memory spendersC, uint256[] memory allowancesC) =
            abi.decode(data[0], (address[], address[], uint256[]));
        
        // Previous block data
        (address[] memory ownersP, address[] memory spendersP, uint256[] memory allowancesP) =
            abi.decode(data[1], (address[], address[], uint256[]));

        if (ownersC.length != ownersP.length) return (false, "");
        
        // Check each pair for suspicious increases
        for (uint256 i = 0; i < ownersC.length; i++) {
            if (ownersC[i] != ownersP[i] || spendersC[i] != spendersP[i]) {
                continue;
            }
            
            // Check if allowance increased
            if (allowancesC[i] > allowancesP[i]) {
                uint256 delta = allowancesC[i] - allowancesP[i];
                
                // Trigger if increase >= threshold AND spender not whitelisted
                if (delta >= THRESHOLD && !isWhitelisted(spendersC[i])) {
                    // Return data matching response function signature:
                    // executeAllowance(address owner, address spender, uint256 prev, uint256 curr)
                    return (
                        true, 
                        abi.encode(
                            ownersC[i],      // owner (address)
                            spendersC[i],    // spender (address)
                            allowancesP[i],  // previousAllowance (uint256)
                            allowancesC[i]   // currentAllowance (uint256)
                        )
                    );
                }
            }
        }
        
        return (false, "");
    }
}
