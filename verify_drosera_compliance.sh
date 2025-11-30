#!/bin/bash

echo "========================================="
echo "Drosera Compliance Verification"
echo "========================================="
echo ""

# Check 1: Verify artifact path exists
echo "1. Checking artifact path..."
if [ -f "out/SuspiciousAllowanceTrapMainnet.sol/SuspiciousAllowanceTrapMainnet.json" ]; then
    echo "   ✅ Artifact exists"
else
    echo "   ❌ Artifact missing - run: forge build"
    exit 1
fi

# Check 2: Verify zero-arg constructor
echo ""
echo "2. Checking constructor..."
CONSTRUCTOR=$(cat out/SuspiciousAllowanceTrapMainnet.sol/SuspiciousAllowanceTrapMainnet.json | jq '.abi[] | select(.type=="constructor")')
if [ -z "$CONSTRUCTOR" ]; then
    echo "   ✅ No explicit constructor (default zero-arg)"
else
    CONSTRUCTOR_INPUTS=$(echo "$CONSTRUCTOR" | jq '.inputs | length')
    if [ "$CONSTRUCTOR_INPUTS" == "0" ]; then
        echo "   ✅ Zero-arg constructor confirmed"
    else
        echo "   ❌ Constructor has arguments - MUST be zero-arg"
        exit 1
    fi
fi

# Check 3: Verify collect() is view
echo ""
echo "3. Checking collect() function..."
COLLECT_STATE=$(cat out/SuspiciousAllowanceTrapMainnet.sol/SuspiciousAllowanceTrapMainnet.json | jq -r '.abi[] | select(.name=="collect") | .stateMutability')
if [ "$COLLECT_STATE" == "view" ]; then
    echo "   ✅ collect() is view"
else
    echo "   ⚠️  collect() stateMutability: $COLLECT_STATE"
fi

# Check 4: Verify shouldRespond() is pure
echo ""
echo "4. Checking shouldRespond() function..."
RESPOND_STATE=$(cat out/SuspiciousAllowanceTrapMainnet.sol/SuspiciousAllowanceTrapMainnet.json | jq -r '.abi[] | select(.name=="shouldRespond") | .stateMutability')
if [ "$RESPOND_STATE" == "pure" ]; then
    echo "   ✅ shouldRespond() is pure"
else
    echo "   ⚠️  shouldRespond() stateMutability: $RESPOND_STATE"
fi

# Check 5: Verify response function signature matches
echo ""
echo "5. Checking response function signature..."
TOML_SIG=$(grep "response_function" drosera.toml | cut -d'"' -f2)
echo "   drosera.toml: $TOML_SIG"

# Check if ResponseContract has matching function
if grep -q "function executeAllowance" src/ResponseContract.sol; then
    echo "   ✅ ResponseContract has executeAllowance function"
else
    echo "   ❌ ResponseContract missing executeAllowance"
fi

# Check 6: Verify drosera.toml has required fields
echo ""
echo "6. Checking drosera.toml configuration..."

if grep -q "path = " drosera.toml; then
    echo "   ✅ path defined"
else
    echo "   ❌ path missing"
fi

if grep -q "response_contract = " drosera.toml; then
    echo "   ✅ response_contract defined"
else
    echo "   ❌ response_contract missing"
fi

if grep -q "response_function = " drosera.toml; then
    echo "   ✅ response_function defined"
else
    echo "   ❌ response_function missing"
fi

if grep -q "whitelist = " drosera.toml; then
    echo "   ✅ whitelist defined"
else
    echo "   ❌ whitelist missing"
fi

echo ""
echo "========================================="
echo "Verification Complete"
echo "========================================="
echo ""
echo "Your trap is deployed at: $(grep 'address = ' drosera.toml | cut -d'"' -f2)"
echo "Response contract: $(grep 'response_contract = ' drosera.toml | cut -d'"' -f2)"
