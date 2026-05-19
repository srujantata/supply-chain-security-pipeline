#!/bin/bash

SBOM_FILE=$1

# Check if SBOM_FILE is provided
if [ -z "$SBOM_FILE" ]; then
  echo "Usage: $0 <path_to_sbom_file>"
  exit 1
fi

# Run Grype and output results in table format
echo "Running Grype with table output:"
grype sbom:$SBOM_FILE -o table

# Run Grype and save JSON results to file
grype sbom:$SBOM_FILE -o json > grype-results.json

# Count vulnerabilities by severity using jq
CRITICAL=$(jq '.Vulnerabilities[] | select(.Severity == "CRITICAL") | .VulnerabilityID' grype-results.json | wc -l)
HIGH=$(jq '.Vulnerabilities[] | select(.Severity == "HIGH") | .VulnerabilityID' grype-results.json | wc -l)
MEDIUM=$(jq '.Vulnerabilities[] | select(.Severity == "MEDIUM") | .VulnerabilityID' grype-results.json | wc -l)
LOW=$(jq '.Vulnerabilities[] | select(.Severity == "LOW") | .VulnerabilityID' grype-results.json | wc -l)

# Print summary table
echo "Summary of Vulnerabilities:"
printf "%-10s %-10s %-10s %-10s\n" "CRITICAL" "HIGH" "MEDIUM" "LOW"
printf "%-10d %-10d %-10d %-10d\n" $CRITICAL $HIGH $MEDIUM $LOW

# Exit with 1 if any CRITICAL vulnerabilities found, otherwise exit 0
if [ "$CRITICAL" -gt 0 ]; then
  echo "Critical vulnerabilities found. Exiting with status 1."
  exit 1
else
  echo "No critical vulnerabilities found. Exiting with status 0."
  exit 0
fi