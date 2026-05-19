#!/bin/bash
set -e

# Check if IMAGE argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <IMAGE>"
  exit 1
fi

IMAGE=$1

# Function to generate SBOM and print component count
generate_sbom() {
  local format=$1
  local output_file="sbom-$format.json"
  
  # Generate SBOM
  syft packages "$IMAGE" -o "$format-json" > "$output_file"
  
  # Check if SBOM generation was successful
  if [ $? -eq 0 ]; then
    echo "Generated $output_file"
    
    # Count components in the SBOM
    component_count=$(jq '.components | length' "$output_file")
    echo "Component count: $component_count"
  else
    echo "Failed to generate $output_file"
    exit 1
  fi
}

# Generate SBOMs in different formats
generate_sbom cyclonedx-json
generate_sbom spdx-json
generate_sbom syft-json

echo "All SBOMs generated and component counts printed."