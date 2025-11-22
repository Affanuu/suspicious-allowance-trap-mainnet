// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ResponseContract {
    event SuspiciousAllowanceDetected(
        address indexed owner,
        address indexed spender,
        uint256 previousAllowance,
        uint256 currentAllowance
    );

    /// @notice Executed by Drosera when trap triggers
    /// @param owner Wallet that granted the allowance
    /// @param spender Contract that received approval
    /// @param previousAllowance Previous allowance amount
    /// @param currentAllowance New allowance amount
    function executeAllowance(
        address owner,
        address spender,
        uint256 previousAllowance,
        uint256 currentAllowance
    ) external {
        emit SuspiciousAllowanceDetected(
            owner, 
            spender, 
            previousAllowance, 
            currentAllowance
        );
    }
}
