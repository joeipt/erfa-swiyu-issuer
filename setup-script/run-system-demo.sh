#!/usr/bin/env bash
set -euo pipefail

# System Demo Script
# This script demonstrates the full flow of:
# 1. Getting identifier information for a business partner
# 2. Creating an identifier entry (DID space) if it does not exist
# 3. Generating and uploading a DID log
# 4. Creating and uploading proof of possession

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check dependencies
check_dependencies() {
    local missing_deps=0

    if ! command -v curl &> /dev/null; then
        log_error "curl is not installed"
        missing_deps=1
    fi

    if ! command -v jq &> /dev/null; then
        log_error "jq is not installed. Please install jq for JSON parsing."
        missing_deps=1
    fi

    if ! command -v java &> /dev/null; then
        log_error "java is not installed"
        missing_deps=1
    fi

    if [[ ! -f "didtoolbox-1.3.1-jar-with-dependencies.jar" ]]; then
        log_error "didtoolbox-1.3.1-jar-with-dependencies.jar not found in current directory"
        missing_deps=1
    fi

    if [[ $missing_deps -eq 1 ]]; then
        exit 1
    fi
}

# Configuration
IDENTIFIER_API_URL="https://identifier-reg-api.trust-infra.swiyu-int.admin.ch"
IDENTIFIER_URL="https://identifier-reg.trust-infra.swiyu-int.admin.ch"
SWIYU_PARTNER_ID="e0c0aebe-2e25-424b-a368-4695bc6b16c1"
TOKEN="eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJKTDFNMS1NQjMwQVQ0VjhIQkI0X2V6M3M0YWpRc0NiN2ZZcmRRbnFlMUlzIn0.eyJleHAiOjE3NzY5MzQ1NDksImlhdCI6MTc3Njg0NDU0OSwianRpIjoib2ZydGNjOjJiOTNlY2Y3LWQxY2ItNGQxOC1iMDFkLWM0OGZkZmViYWJhZiIsImlzcyI6Imh0dHBzOi8va2V5bWFuYWdlci1wcmQuYXBpLmFkbWluLmNoL2tleWNsb2FrL3JlYWxtcy9BUElHVyIsInN1YiI6InByb2RfdGVzdF8xLXBhbXNfZTBjMGFlYmUtMmUyNS00MjRiLWEzNjgtNDY5NWJjNmIxNmMxIiwidHlwIjoiQmVhcmVyIiwiYXpwIjoiMzQ5YzU2YmEtNWY3ZS00MzlkLWJiMzQtNjdmODY2ODQxZTQ0Iiwic2lkIjoiMDFjMDMwNjItYjgxNC00ZDdhLThiM2ItOTE2OWI1YmU4ZTg1Iiwic2NvcGUiOiJvZmZsaW5lX2FjY2VzcyIsImVudmlyb25tZW50IjoicHJvZCIsImJwcm9sZXMiOnsiZTBjMGFlYmUtMmUyNS00MjRiLWEzNjgtNDY5NWJjNmIxNmMxIjpbInRpX0BzdGF0dXNfI3JlYWQiLCJ0aV9Ac3RhdHVzXyN3cml0ZSIsInRpX0BpZGVudGlmaWVyXyNyZWFkIiwidGlfQGlkZW50aWZpZXJfI3dyaXRlIiwidGlfQHRydXN0b25ib2FyZGluZ3N1Ym1pc3Npb25fI3JlYWQiLCJ0aV9AdHJ1c3RvbmJvYXJkaW5nc3VibWlzc2lvbl8jd3JpdGUiLCJ0aV9AdmNzY2hlbWFzdWJtaXNzaW9uXyNyZWFkIiwidGlfQHZjc2NoZW1hc3VibWlzc2lvbl8jd3JpdGUiXX0sImNsaWVudEhvc3QiOiIxMC4xNzcuMjcuNzkiLCJjdHgiOiJCMkIiLCJzdWJzY3JpYmVkQVBJcyI6W3sibmFtZSI6InN3aXl1Y29yZWJ1c2luZXNzX3N0YXR1cyIsInZlcnNpb24iOiIwLjAuMSJ9LHsibmFtZSI6InN3aXl1Y29yZWJ1c2luZXNzX2lkZW50aWZpZXIiLCJ2ZXJzaW9uIjoiMC4wLjEifSx7Im5hbWUiOiJzd2l5dWNvcmVidXNpbmVzc190cnVzdCIsInZlcnNpb24iOiIwLjAuMSJ9XSwiY2xpZW50QWRkcmVzcyI6IjEwLjE3Ny4yNy43OSIsImNsaWVudF9pZCI6IjM0OWM1NmJhLTVmN2UtNDM5ZC1iYjM0LTY3Zjg2Njg0MWU0NCJ9.cdzbozFCFz6w5c1RcgdM7KCP7zgD6J2QyJnDvW3QZcyD3Adu5PStJJIX0UnN3e07DbTPYQkpzlRv8qb-5HA0aijh2PerEJh0QN84IOl1xHsB5dzqmmnzt050AYZchEHVwQAh0gLn1FYOfK5yJ1LnsTOfDWcrBtlm277r0zLCh--_0tg2aY6wTzZUOgj0zSxNKI5DMnDW-4CdaL9N6YwS1taFeT-zMBvTe9cgT7vim_ERySON5cejtWMugRRuhIyx8ZVB_tybKAk4Z33U_KWg-wtBI2ZcP3qObeuRwOjOlMgUUTBbh81eimPvrvyJKFc5J1tAjSw1Z4LSwXBlMO3ocg"


log_info "Checking dependencies..."
check_dependencies
log_success "All dependencies found"

echo ""
log_info "Configuration:"
echo "  SWIYU_PARTNER_ID: $SWIYU_PARTNER_ID"
echo "  IDENTIFIER_API_URL: $IDENTIFIER_API_URL"
echo ""

# Step 1: Get identifier information
log_info "Step 1: Fetching identifier information for business partner..."
IDENTIFIER_RESPONSE=$(curl -v -s -X GET \
  -H "Authorization: Bearer $TOKEN" \
  "$IDENTIFIER_API_URL/api/v1/identifier/business-entities/$SWIYU_PARTNER_ID/identifier/")

if [[ -z "$IDENTIFIER_RESPONSE" ]]; then
    log_error "Failed to get identifier information"
    exit 1
fi

# Extract the first identifier ID and status
IDENTIFIER_REGISTRY_ID=$(echo "$IDENTIFIER_RESPONSE" | jq -r '.content[0].id // empty')
IDENTIFIER_STATUS=$(echo "$IDENTIFIER_RESPONSE" | jq -r '.content[0].status // empty')

# Step 2: Create identifier entry (DID Space) if it does not exist
if [[ -z "$IDENTIFIER_REGISTRY_ID" ]]; then
    log_info "No identifier found. Creating a new identifier entry (DID space)..."
    
    CREATE_RESPONSE=$(curl -s -X POST \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      "$IDENTIFIER_API_URL/api/v1/identifier/business-entities/$SWIYU_PARTNER_ID/identifier-entries")

    IDENTIFIER_REGISTRY_ID=$(echo "$CREATE_RESPONSE" | jq -r '.id // empty')

    if [[ -z "$IDENTIFIER_REGISTRY_ID" ]]; then
        log_error "Failed to create identifier entry"
        echo "$CREATE_RESPONSE"
        exit 1
    fi
    
    log_success "Created new identifier entry: $IDENTIFIER_REGISTRY_ID"
    IDENTIFIER_STATUS="CREATED"
else
    log_success "Found existing identifier: $IDENTIFIER_REGISTRY_ID"
    log_info "Current identifier status: $IDENTIFIER_STATUS"
fi

echo ""

# Step 3: Generate and Upload DID log if not already initialized
if [[ "$IDENTIFIER_STATUS" == "INITIALIZED" ]]; then
    log_success "Identifier is already INITIALIZED. Skipping DID log generation and upload."
else
    # Generate DID log with didtoolbox
    log_info "Step 3a: Generating DID log with didtoolbox..."
    DID_URL="$IDENTIFIER_URL/api/v1/did/$IDENTIFIER_REGISTRY_ID"

    if ! java -jar didtoolbox-1.3.1-jar-with-dependencies.jar create --identifier-registry-url "$DID_URL" > didlog.jsonl; then
        log_error "Failed to generate DID log"
        exit 1
    fi

    log_success "DID log generated: didlog.jsonl"
    echo ""

    # Upload DID log to endpoint
    log_info "Step 3b: Uploading DID log..."
    UPLOAD_RESPONSE=$(curl -s -w "\n%{http_code}" --data-binary @didlog.jsonl \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/jsonl+json" \
      -X PUT "$IDENTIFIER_API_URL/api/v1/identifier/business-entities/$SWIYU_PARTNER_ID/identifier-entries/$IDENTIFIER_REGISTRY_ID")

    HTTP_CODE=$(echo "$UPLOAD_RESPONSE" | tail -n1)
    RESPONSE_BODY=$(echo "$UPLOAD_RESPONSE" | sed '$d')

    if [[ "$HTTP_CODE" =~ ^2[0-9]{2}$ ]]; then
        log_success "DID log uploaded successfully (HTTP $HTTP_CODE)"
    else
        log_error "Failed to upload DID log (HTTP $HTTP_CODE)"
        echo "$RESPONSE_BODY"
        exit 1
    fi
fi

log_success "System demo flow completed successfully!"
echo ""