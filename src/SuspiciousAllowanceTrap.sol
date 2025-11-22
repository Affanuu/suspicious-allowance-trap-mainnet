// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ITrap.sol";

interface IERC20 {
    function allowance(address owner, address spender) external view returns (uint256);
}

contract SuspiciousAllowanceTrap is ITrap {
    address public token;
    uint256 public threshold;

    address[] public owners;
    address[] public spenders;

    mapping(address => bool) public spenderWhitelist;

    constructor(address _token, uint256 _threshold) {
        token = _token;
        threshold = _threshold;
    }

    function addPair(address owner, address spender) external {
        owners.push(owner);
        spenders.push(spender);
    }

    function addToWhitelist(address spender) external {
        spenderWhitelist[spender] = true;
    }

    function removeFromWhitelist(address spender) external {
        spenderWhitelist[spender] = false;
    }

    function collect() external view override returns (bytes memory) {
        uint256 len = owners.length;
        
        if (len == 0) {
            address[] memory emptyAddresses = new address[](0);
            uint256[] memory emptyAmounts = new uint256[](0);
            return abi.encode(emptyAddresses, emptyAddresses, emptyAmounts);
        }

        address[] memory _owners = new address[](len);
        address[] memory _spenders = new address[](len);
        uint256[] memory _allowances = new uint256[](len);

        for (uint256 i = 0; i < len; i++) {
            _owners[i] = owners[i];
            _spenders[i] = spenders[i];
            
            try IERC20(token).allowance(owners[i], spenders[i]) returns (uint256 allowance) {
                _allowances[i] = allowance;
            } catch {
                _allowances[i] = 0;
            }
        }

        return abi.encode(_owners, _spenders, _allowances);
    }

    function shouldRespond(bytes[] calldata data) external view override returns (bool, bytes memory) {
        if (data.length < 2) return (false, "");

        (address[] memory ownersC, address[] memory spendersC, uint256[] memory allowancesC) =
            abi.decode(data[0], (address[], address[], uint256[]));
        (address[] memory ownersP, address[] memory spendersP, uint256[] memory allowancesP) =
            abi.decode(data[1], (address[], address[], uint256[]));

        if (ownersC.length != ownersP.length) return (false, "");
        for (uint256 i = 0; i < ownersC.length; i++) {
            if (ownersC[i] != ownersP[i] || spendersC[i] != spendersP[i]) {
                continue;
            }
            if (allowancesC[i] > allowancesP[i]) {
                uint256 delta = allowancesC[i] - allowancesP[i];
                if (delta >= threshold && !spenderWhitelist[spendersC[i]]) {
                    return (true, abi.encode(ownersC[i], spendersC[i], allowancesP[i], allowancesC[i]));
                }
            }
        }
        return (false, "");
    }

    function encodeSingle(address owner_, address spender_, uint256 allowance_) external pure returns (bytes memory) {
        address[] memory a = new address[](1);
        address[] memory b = new address[](1);
        uint256[] memory c = new uint256[](1);
        a[0] = owner_;
        b[0] = spender_;
        c[0] = allowance_;
        return abi.encode(a, b, c);
    }
}
