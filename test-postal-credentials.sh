#!/bin/bash

# Test Postal API Credentials
# Replace with your actual values

ORG_ID="otto"
SERVER_ID="otto-01"
API_KEY="B9xJLydfxV96pn2n5GFWT57p"
POSTAL_URL="https://postal.ottomatik.ai"

echo "🧪 Testing Postal API Credentials..."
echo "=================================="

# Test 1: Get Routes
echo "1. Testing Routes endpoint:"
curl -s -X GET "${POSTAL_URL}/api/v1/organizations/${ORG_ID}/servers/${SERVER_ID}/routes" \
  -H "X-Server-API-Key: ${API_KEY}" \
  -H "Content-Type: application/json" | jq '.' || echo "❌ Routes test failed"

echo ""

# Test 2: Get Statistics 
echo "2. Testing Statistics endpoint:"
curl -s -X GET "${POSTAL_URL}/api/v1/organizations/${ORG_ID}/servers/${SERVER_ID}/statistics/outgoing" \
  -H "X-Server-API-Key: ${API_KEY}" \
  -H "Content-Type: application/json" | jq '.' || echo "❌ Statistics test failed"

echo ""
echo "✅ If you see JSON responses above, your credentials are working!"
echo "❌ If you see errors, double-check your ORG_ID, SERVER_ID, and API_KEY"
