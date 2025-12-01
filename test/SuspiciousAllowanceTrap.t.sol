// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/SuspiciousAllowanceTrapMainnet.sol";

/// @notice Production tests for mainnet trap
/// @dev Tests logic without requiring mainnet fork
contract SuspiciousAllowanceTrapTest is Test {
    SuspiciousAllowanceTrapMainnet trap;
    
    address constant VITALIK = 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045;
    address constant UNKNOWN_SPENDER = 0x0000000000000000000000000000000000000001;
    address constant UNISWAP_V2 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    function setUp() public {
        trap = new SuspiciousAllowanceTrapMainnet();
    }

    function test_zeroArgConstructor() public {
        // Verify contract deploys with zero args
        SuspiciousAllowanceTrapMainnet newTrap = new SuspiciousAllowanceTrapMainnet();
        assertTrue(address(newTrap) != address(0));
    }

    function test_shouldRespondOnLargeIncrease() public {
        // Simulate previous state: no allowance
        address[] memory owners = new address[](1);
        address[] memory spenders = new address[](1);
        uint256[] memory allowancesPrev = new uint256[](1);
        uint256[] memory allowancesCurr = new uint256[](1);
        
        owners[0] = VITALIK;
        spenders[0] = UNKNOWN_SPENDER; // Not whitelisted
        allowancesPrev[0] = 0;
        allowancesCurr[0] = 20000 * 1e6; // 20,000 USDC (over threshold)
        
        bytes memory dataPrev = abi.encode(owners, spenders, allowancesPrev);
        bytes memory dataCurr = abi.encode(owners, spenders, allowancesCurr);
        
        bytes[] memory dataArray = new bytes[](2);
        dataArray[0] = dataCurr;
        dataArray[1] = dataPrev;
        
        (bool shouldRespond, bytes memory responseData) = trap.shouldRespond(dataArray);
        
        assertTrue(shouldRespond, "Should trigger on large increase to unknown spender");
        
        // Verify response data matches executeAllowance signature
        (address owner, address spender, uint256 prev, uint256 curr) = 
            abi.decode(responseData, (address, address, uint256, uint256));
        
        assertEq(owner, VITALIK);
        assertEq(spender, UNKNOWN_SPENDER);
        assertEq(prev, 0);
        assertEq(curr, 20000 * 1e6);
    }

    function test_noTriggerOnSmallIncrease() public {
        address[] memory owners = new address[](1);
        address[] memory spenders = new address[](1);
        uint256[] memory allowancesPrev = new uint256[](1);
        uint256[] memory allowancesCurr = new uint256[](1);
        
        owners[0] = VITALIK;
        spenders[0] = UNKNOWN_SPENDER;
        allowancesPrev[0] = 100 * 1e6;
        allowancesCurr[0] = 200 * 1e6; // Only 100 USDC increase (below threshold)
        
        bytes memory dataPrev = abi.encode(owners, spenders, allowancesPrev);
        bytes memory dataCurr = abi.encode(owners, spenders, allowancesCurr);
        
        bytes[] memory dataArray = new bytes[](2);
        dataArray[0] = dataCurr;
        dataArray[1] = dataPrev;
        
        (bool shouldRespond,) = trap.shouldRespond(dataArray);
        
        assertFalse(shouldRespond, "Should not trigger on small increase");
    }

    function test_noTriggerOnWhitelistedSpender() public {
        address[] memory owners = new address[](1);
        address[] memory spenders = new address[](1);
        uint256[] memory allowancesPrev = new uint256[](1);
        uint256[] memory allowancesCurr = new uint256[](1);
        
        owners[0] = VITALIK;
        spenders[0] = UNISWAP_V2; // Whitelisted
        allowancesPrev[0] = 0;
        allowancesCurr[0] = 20000 * 1e6; // Large increase but to trusted spender
        
        bytes memory dataPrev = abi.encode(owners, spenders, allowancesPrev);
        bytes memory dataCurr = abi.encode(owners, spenders, allowancesCurr);
        
        bytes[] memory dataArray = new bytes[](2);
        dataArray[0] = dataCurr;
        dataArray[1] = dataPrev;
        
        (bool shouldRespond,) = trap.shouldRespond(dataArray);
        
        assertFalse(shouldRespond, "Should not trigger on whitelisted spender");
    }

    function test_shouldRespondIsPure() public {
        // Verify shouldRespond is pure by calling it multiple times
        address[] memory owners = new address[](1);
        address[] memory spenders = new address[](1);
        uint256[] memory allowances = new uint256[](1);
        
        owners[0] = VITALIK;
        spenders[0] = UNKNOWN_SPENDER;
        allowances[0] = 15000 * 1e6;
        
        bytes memory data1 = abi.encode(owners, spenders, allowances);
        
        allowances[0] = 5000 * 1e6;
        bytes memory data2 = abi.encode(owners, spenders, allowances);
        
        bytes[] memory dataArray = new bytes[](2);
        dataArray[0] = data1;
        dataArray[1] = data2;
        
        // Call multiple times - should return same result (pure function)
        (bool result1,) = trap.shouldRespond(dataArray);
        (bool result2,) = trap.shouldRespond(dataArray);
        
        assertEq(result1, result2, "shouldRespond should be deterministic (pure)");
        assertTrue(result1, "Should trigger on 10k USDC increase");
    }

    function test_multipleSpendersOneTriggers() public {
        // Test with multiple spenders, only one triggers
        address[] memory owners = new address[](3);
        address[] memory spenders = new address[](3);
        uint256[] memory allowancesPrev = new uint256[](3);
        uint256[] memory allowancesCurr = new uint256[](3);
        
        // Spender 1: Small increase (no trigger)
        owners[0] = VITALIK;
        spenders[0] = 0x0000000000000000000000000000000000000001;
        allowancesPrev[0] = 0;
        allowancesCurr[0] = 1000 * 1e6; // 1k USDC (below threshold)
        
        // Spender 2: Large increase but whitelisted (no trigger)
        owners[1] = VITALIK;
        spenders[1] = UNISWAP_V2;
        allowancesPrev[1] = 0;
        allowancesCurr[1] = 50000 * 1e6; // 50k USDC but whitelisted
        
        // Spender 3: Large increase to unknown (TRIGGER!)
        owners[2] = VITALIK;
        spenders[2] = 0x0000000000000000000000000000000000000002;
        allowancesPrev[2] = 0;
        allowancesCurr[2] = 25000 * 1e6; // 25k USDC to unknown
        
        bytes memory dataPrev = abi.encode(owners, spenders, allowancesPrev);
        bytes memory dataCurr = abi.encode(owners, spenders, allowancesCurr);
        
        bytes[] memory dataArray = new bytes[](2);
        dataArray[0] = dataCurr;
        dataArray[1] = dataPrev;
        
        (bool shouldRespond, bytes memory responseData) = trap.shouldRespond(dataArray);
        
        assertTrue(shouldRespond, "Should trigger on spender 3");
        
        // Verify it caught the correct spender
        (address owner, address spender,,) = 
            abi.decode(responseData, (address, address, uint256, uint256));
        
        assertEq(spender, 0x0000000000000000000000000000000000000002, "Should catch spender 3");
    }

    function test_thresholdBoundary() public {
        address[] memory owners = new address[](1);
        address[] memory spenders = new address[](1);
        uint256[] memory allowancesPrev = new uint256[](1);
        uint256[] memory allowancesCurr = new uint256[](1);
        
        owners[0] = VITALIK;
        spenders[0] = UNKNOWN_SPENDER;
        allowancesPrev[0] = 0;
        
        // Test: Exactly at threshold (10,000 USDC) - SHOULD trigger
        allowancesCurr[0] = 10000 * 1e6;
        
        bytes memory dataPrev = abi.encode(owners, spenders, allowancesPrev);
        bytes memory dataCurr = abi.encode(owners, spenders, allowancesCurr);
        
        bytes[] memory dataArray = new bytes[](2);
        dataArray[0] = dataCurr;
        dataArray[1] = dataPrev;
        
        (bool shouldRespond,) = trap.shouldRespond(dataArray);
        
        assertTrue(shouldRespond, "Should trigger at exact threshold (10k USDC)");
        
        // Test: Just below threshold (9,999.999999 USDC) - should NOT trigger
        allowancesCurr[0] = 10000 * 1e6 - 1;
        dataCurr = abi.encode(owners, spenders, allowancesCurr);
        dataArray[0] = dataCurr;
        
        (shouldRespond,) = trap.shouldRespond(dataArray);
        
        assertFalse(shouldRespond, "Should NOT trigger below threshold");
    }
}
