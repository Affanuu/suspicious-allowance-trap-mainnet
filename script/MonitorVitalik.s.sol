// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/SuspiciousAllowanceTrap.sol";

contract MonitorVitalik is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address trapAddress = 0x1F89B0BA4CE081530e716E7b2336F11F4745D40e;
        
        vm.startBroadcast(deployerPrivateKey);
        
        SuspiciousAllowanceTrap trap = SuspiciousAllowanceTrap(trapAddress);
        
        // Vitalik's wallet address
        address vitalikWallet = 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045;
        
        console.log("=================================");
        console.log("Adding Vitalik's wallet to monitoring...");
        console.log("=================================");
        console.log("");
        
        // Monitor approvals to various potential spenders
        // We'll add multiple pairs to watch different scenarios
        
        // Pair 1: Watch for any unknown contract approvals
        address unknownSpender1 = 0x0000000000000000000000000000000000000001;
        trap.addPair(vitalikWallet, unknownSpender1);
        console.log("1. Monitoring pair added:");
        console.log("   Owner: Vitalik (0xd8dA...96045)");
        console.log("   Spender:", unknownSpender1);
        console.log("");
        
        // Pair 2: Watch for another potential spender
        address unknownSpender2 = 0x0000000000000000000000000000000000000002;
        trap.addPair(vitalikWallet, unknownSpender2);
        console.log("2. Monitoring pair added:");
        console.log("   Owner: Vitalik (0xd8dA...96045)");
        console.log("   Spender:", unknownSpender2);
        console.log("");
        
        // Pair 3: Watch for a third potential spender
        address unknownSpender3 = 0x0000000000000000000000000000000000000003;
        trap.addPair(vitalikWallet, unknownSpender3);
        console.log("3. Monitoring pair added:");
        console.log("   Owner: Vitalik (0xd8dA...96045)");
        console.log("   Spender:", unknownSpender3);
        console.log("");
        
        // Verify the pairs were added
        console.log("=================================");
        console.log("Verifying all monitoring pairs...");
        console.log("=================================");
        console.log("");
        
        bytes memory data = trap.collect();
        (address[] memory owners, address[] memory spenders, uint256[] memory allowances) = 
            abi.decode(data, (address[], address[], uint256[]));
        
        console.log("Total monitoring pairs:", owners.length);
        console.log("");
        
        for (uint256 i = 0; i < owners.length; i++) {
            console.log("Pair #", i + 1);
            console.log("  Owner:", owners[i]);
            console.log("  Spender:", spenders[i]);
            console.log("  Current USDC Allowance:", allowances[i]);
            console.log("");
        }
        
        console.log("=================================");
        console.log("Setup Complete!");
        console.log("=================================");
        console.log("Your trap is now monitoring Vitalik's wallet");
        console.log("for USDC approvals >= 10,000 USDC");
        console.log("");
        console.log("Vitalik's Wallet:", vitalikWallet);
        console.log("USDC Token:", 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        console.log("Alert Threshold: 10,000 USDC");
        
        vm.stopBroadcast();
    }
}
