// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/ResponseContract.sol";

/// @notice Deploy response contract to mainnet
contract DeployResponseContract is Script {
    function run() external {
        vm.startBroadcast();
        
        ResponseContract response = new ResponseContract();
        
        console.log("=================================");
        console.log("Response Contract Deployed");
        console.log("=================================");
        console.log("Address:", address(response));
        console.log("Network: Ethereum Mainnet");
        console.log("Function: executeAllowance(address,address,uint256,uint256)");
        
        vm.stopBroadcast();
    }
}
