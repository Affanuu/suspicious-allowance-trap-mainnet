// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/SuspiciousAllowanceTrap.sol";
import "../src/MockERC20.sol";

contract SuspiciousAllowanceTrapTest is Test {
    SuspiciousAllowanceTrap trap;
    MockERC20 token;
    address ownerA = address(0xAA);
    address badSpender = address(0xB0);
    address safeSpender = address(0xC0);

    function setUp() public {
        token = new MockERC20();
        trap = new SuspiciousAllowanceTrap(address(token), 1000 ether);
        trap.addPair(ownerA, badSpender);
        trap.addPair(ownerA, safeSpender);
        trap.addToWhitelist(safeSpender);
    }

    function test_noTrigger_on_small_increase() public {
        bytes memory prev = trap.encodeSingle(ownerA, badSpender, 100 ether);
        bytes memory curr = trap.encodeSingle(ownerA, badSpender, 200 ether);
        bytes[] memory arr = new bytes[](2);
        arr[0] = curr; 
        arr[1] = prev;
        (bool should, ) = trap.shouldRespond(arr);
        assertFalse(should);
    }

    function test_trigger_on_spike() public {
        bytes memory prev = trap.encodeSingle(ownerA, badSpender, 100 ether);
        bytes memory curr = trap.encodeSingle(ownerA, badSpender, 2000 ether);
        bytes[] memory arr = new bytes[](2);
        arr[0] = curr; 
        arr[1] = prev;
        (bool should, bytes memory data) = trap.shouldRespond(arr);
        assertTrue(should);
        (address o, address s, uint256 p, uint256 c) = abi.decode(data, (address, address, uint256, uint256));
        assertEq(o, ownerA);
        assertEq(s, badSpender);
        assertEq(p, 100 ether);
        assertEq(c, 2000 ether);
    }

    function test_whitelisted_spender_not_trigger() public {
        bytes memory prev = trap.encodeSingle(ownerA, safeSpender, 100 ether);
        bytes memory curr = trap.encodeSingle(ownerA, safeSpender, 2000 ether);
        bytes[] memory arr = new bytes[](2);
        arr[0] = curr; 
        arr[1] = prev;
        (bool should, ) = trap.shouldRespond(arr);
        assertFalse(should);
    }

    function test_collect_returns_data() public {
        bytes memory data = trap.collect();
        (address[] memory owners, address[] memory spenders, uint256[] memory allowances) = 
            abi.decode(data, (address[], address[], uint256[]));
        
        assertEq(owners.length, 2);
        assertEq(spenders.length, 2);
        assertEq(allowances.length, 2);
        assertEq(owners[0], ownerA);
        assertEq(spenders[0], badSpender);
    }
}
