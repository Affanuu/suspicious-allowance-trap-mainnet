// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/SuspiciousAllowanceTrap.sol";

contract AddYourWallet is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address trapAddress = 0x1F89B0BA4CE081530e716E7b2336F11F4745D40e;
        
        vm.startBroadcast(deployerPrivateKey);
        
        SuspiciousAllowanceTrap trap = SuspiciousAllowanceTrap(trapAddress);
        
        // Monitor your own wallet (deployer address)
        address yourWallet = 0xC44F6deeFebBCcd68d7f82B75D375FD89170e968;
        
        // Add some common suspicious/unknown contract as spender to watch
        // This is just a random address for testing - you can change it
        address testSpender = 0x1111111111111111111111111111111111111111;
        
        console.log("Adding monitoring pair...");
        console.log("Owner (your wallet):", yourWallet);
        console.log("Spender to watch:", testSpender);
        
        trap.addPair(yourWallet, testSpender);
        
        console.log("Pair added successfully!");
        
        // Verify it was added by calling collect
        bytes memory data = trap.collect();
        (address[] memory owners, address[] memory spenders, uint256[] memory allowances) = 
            abi.decode(data, (address[], address[], uint256[]));
        
        console.log("\nVerification:");
        console.log("Total pairs monitored:", owners.length);
        if (owners.length > 0) {
            console.log("First pair - Owner:", owners[0]);
            console.log("First pair - Spender:", spenders[0]);
            console.log("First pair - Current allowance:", allowances[0]);
        }
        
        vm.stopBroadcast();
    }
}
