// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "forge-std/Script.sol";
import "../src/SuspiciousAllowanceTrap.sol";
contract AddPairs is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address trapAddress = 0x1F89B0BA4CE081530e716E7b2336F11F4745D40e;
        
        vm.startBroadcast(deployerPrivateKey);
        
        SuspiciousAllowanceTrap trap = SuspiciousAllowanceTrap(trapAddress);
        
        // Example pairs to monitor
        // Replace these with actual addresses you want to monitor
        
        // Example 1: Monitor a specific wallet for any suspicious approvals
        address wallet1 = 0x30e35f0b9EEA600a3AA9CB62D46C2A3f4F9ed229;
        address unknownContract1 = 0x6039d41712fCEDc37E63e0D9631075721f5c5C86;
        
        trap.addPair(wallet1, unknownContract1);
        console.log("Added pair 1:");
        console.log("  Owner:", wallet1);
        console.log("  Spender:", unknownContract1);
        
        // You can add multiple pairs
        // trap.addPair(wallet2, unknownContract2);
        
        vm.stopBroadcast();
    }
}
