// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ResponseContract {
    event SuspiciousAllowanceDetected(
        address indexed owner,
        address indexed spender,
        uint256 previousAllowance,
        uint256 currentAllowance
    );

    /// @notice Called by Drosera when trap triggers
    /// @dev Signature MUST match response_function in drosera.toml
    /// @dev Parameters MUST match shouldRespond() return data encoding
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
