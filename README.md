# Supply Chain Security Pipeline

[![GitHub Actions](https://github.com/yourusername/supply-chain-security-pipeline/workflows/Main%20Pipeline/badge.svg)](https://github.com/yourusername/supply-chain-security-pipeline/actions)
[![CodeQL](https://github.com/yourusername/supply-chain-security-pipeline/security/code-scanning/overview)](https://github.com/yourusername/supply-chain-security-pipeline/security/code-scanning)

This repository demonstrates a comprehensive software supply chain security pipeline using Syft, Grype, Cosign/Sigstore, and SLSA Level 3 provenance. The pipeline enforces security gates on every pull request to ensure that only secure code is merged into the main branch.

## Architecture Diagram

+-------------------+
| GitHub Pull Request|
+---------^---------+
          |
          v
+---------+---------+
| Syft: SBOM Generation (CycloneDX + SPDX) |
+---------^---------+
          |
          v
+---------+---------+
| Grype: Vulnerability Scanning (severity gates) |
+---------^---------+
          |
          v
+---------+---------+
| Cosign/Sigstore: Keyless Image Signing with OIDC |
+---------^---------+
          |
          v
+---------+---------+
| SLSA Level 3 Provenance via slsa-github-generator |
+---------^---------+
          |
          v
+-------------------+
| GitHub Actions Pipeline |
+-------------------+

## Full Pipeline Explanation

1. **GitHub Pull Request**: A developer submits a pull request to the main branch.
2. **Syft: SBOM Generation (CycloneDX + SPDX)**: Syft generates Software Bill of Materials (SBOMs) in both CycloneDX and SPDX formats for the code changes in the PR.
3. **Grype: Vulnerability Scanning (severity gates)**: Grype scans the images built from the code changes for known vulnerabilities. The pipeline fails if any critical vulnerabilities are detected.
4. **Cosign/Sigstore: Keyless Image Signing with OIDC**: Cosign signs the images using keyless signing with OIDC, ensuring that only authorized users can push signed images to the repository.
5. **SLSA Level 3 Provenance via slsa-github-generator**: SLSA Level 3 provenance is generated for the build process, providing a tamper-proof record of how the image was built.
6. **GitHub Actions Pipeline**: The pipeline enforces all security gates on every PR. If any gate fails, the PR cannot be merged.

## Example Grype Output Showing Blocked CVEs

+-------------------+-------------------+
| Vulnerability ID  | Severity          |
+-------------------+-------------------+
| CVE-2021-43798     | CRITICAL          |
| CVE-2021-45046     | HIGH              |
+-------------------+-------------------+

The pipeline will block the PR if any critical vulnerabilities are detected.

## How to Verify a Signed Image

To verify a signed image, you can use Cosign:

cosign verify --key cosign.pub <image-url>

This command will check that the image is signed by a trusted key and has not been tampered with.

## SBOM Example Snippet

Here's an example snippet from a generated SBOM in CycloneDX format:

{
  "bomFormat": "CycloneDX",
  "specVersion": "1.4",
  "version": 1,
  "components": [
    {
      "name": "example-library",
      "version": "1.0.0",
      "type": "library"
    }
  ]
}

## Skills Demonstrated

- Software supply chain security
- Syft for SBOM generation
- Grype for vulnerability scanning
- Cosign/Sigstore for keyless image signing
- SLSA Level 3 provenance
- GitHub Actions pipeline automation