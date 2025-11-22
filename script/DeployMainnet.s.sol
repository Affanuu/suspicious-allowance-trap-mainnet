// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/ResponseContract.sol";
import "../src/SuspiciousAllowanceTrap.sol";

contract DeployMainnet is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        console.log("=== Deploying to Ethereum Mainnet ===");
        console.log("Deployer:", vm.addr(deployerPrivateKey));
        console.log("Balance:", address(vm.addr(deployerPrivateKey)).balance / 1e18, "ETH");
        
        // Deploy Response Contract
        console.log("\n1. Deploying ResponseContract...");
        ResponseContract responseContract = new ResponseContract();
        console.log("   ResponseContract:", address(responseContract));
        
        // Deploy Trap Contract
        // USDC Mainnet: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
        address tokenToMonitor = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        uint256 threshold = 10000 * 1e6; // 10,000 USDC (6 decimals)
        
        console.log("\n2. Deploying SuspiciousAllowanceTrap...");
        console.log("   Token (USDC):", tokenToMonitor);
        console.log("   Threshold: 10,000 USDC");
        
        SuspiciousAllowanceTrap trap = new SuspiciousAllowanceTrap(
            tokenToMonitor,
            threshold
        );
        console.log("   Trap:", address(trap));
        
        console.log("\n=== DEPLOYMENT COMPLETE ===");
        console.log("ResponseContract:", address(responseContract));
        console.log("Trap:", address(trap));
        console.log("\nSave these addresses for drosera.toml configuration!");
        
        vm.stopBroadcast();
    }
}
