# Supply Chain Security Pipeline

[![CI](https://github.com/srujantata/supply-chain-security-pipeline/actions/workflows/pipeline.yml/badge.svg)](https://github.com/srujantata/supply-chain-security-pipeline/actions)
[![SLSA Level 3](https://slsa.dev/images/gh-badge-level3.svg)](https://slsa.dev)

End-to-end software supply chain security enforced on every pull request:
**SBOM generation → vulnerability gating → keyless image signing → SLSA L3 provenance.**
Nothing ships unless every gate passes.

---

## How It Works

```
PR opened
    │
    ▼
Syft  ──── generates SBOM (CycloneDX + SPDX)
    │
    ▼
Grype ──── scans SBOM for CVEs
    │       CRITICAL found? ──► PR blocked ✗
    │       Clean? ──► continue ✓
    ▼
Docker build + push to GHCR
    │
    ▼
Cosign ─── keyless signing via GitHub OIDC
    │       (no long-lived keys needed)
    ▼
slsa-github-generator ── attaches SLSA L3 provenance
    │
    ▼
PR mergeable ✓
```

---

## Tools & What They Do

| Tool | Role | Output |
|------|------|--------|
| [Syft](https://github.com/anchore/syft) | SBOM generation | `sbom.cyclonedx.json`, `sbom.spdx.json` |
| [Grype](https://github.com/anchore/grype) | Vulnerability scanning against SBOM | Fails CI on CRITICAL/HIGH |
| [Cosign](https://github.com/sigstore/cosign) | Keyless image signing via Sigstore | Signature attached to image digest |
| [slsa-github-generator](https://github.com/slsa-framework/slsa-github-generator) | SLSA Level 3 provenance | `.intoto.jsonl` attestation |

---

## Pipeline Walkthrough

### Step 1 — SBOM Generation (Syft)

Syft scans the container image and outputs a complete bill of materials listing every package,
library, and their exact versions. Two formats are generated: CycloneDX (machine-readable,
used by Grype) and SPDX (compliance-friendly for auditors).

```yaml
# .github/workflows/pipeline.yml (excerpt)
- name: Generate SBOM
  uses: anchore/sbom-action@v0
  with:
    image: ghcr.io/srujantata/my-app:${{ github.sha }}
    format: cyclonedx-json
    output-file: sbom.cyclonedx.json
```

### Step 2 — Vulnerability Scanning (Grype)

Grype scans the SBOM and blocks the pipeline if any CRITICAL severity CVEs are found.
HIGH severities generate a warning. The threshold is configurable via `.grype.yaml`.

Example blocked output:
```
NAME              INSTALLED   FIXED-IN    TYPE    VULNERABILITY   SEVERITY
libssl1.1         1.1.1f-1    1.1.1n-1    deb     CVE-2022-0778   CRITICAL
curl              7.68.0-1    7.74.0-1    deb     CVE-2021-22945  HIGH

2 vulnerabilities found
1 CRITICAL — pipeline blocked
```

### Step 3 — Keyless Image Signing (Cosign)

Images are signed using Cosign's keyless flow: the GitHub Actions OIDC token proves the
workflow's identity to Sigstore's Fulcio CA, which issues a short-lived certificate.
No long-lived signing keys are stored anywhere.

```bash
# Sign (in CI — no key needed)
cosign sign --yes ghcr.io/srujantata/my-app@${DIGEST}

# Verify (anywhere)
cosign verify \
  --certificate-identity-regexp="https://github.com/srujantata/supply-chain-security-pipeline" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/srujantata/my-app:latest
```

### Step 4 — SLSA Level 3 Provenance

The `slsa-github-generator` workflow runs in an isolated, ephemeral environment and generates
a cryptographically-signed attestation describing exactly how the image was built:
which commit, which workflow, which runner, and which inputs.

```bash
# Verify provenance
slsa-verifier verify-image ghcr.io/srujantata/my-app:latest \
  --source-uri github.com/srujantata/supply-chain-security-pipeline \
  --source-branch main
```

---

## SBOM Example (CycloneDX snippet)

```json
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.4",
  "version": 1,
  "metadata": {
    "component": {
      "name": "my-app",
      "version": "1.0.0",
      "type": "container"
    }
  },
  "components": [
    {
      "name": "openssl",
      "version": "1.1.1n-0+deb11u4",
      "type": "library",
      "purl": "pkg:deb/debian/openssl@1.1.1n-0+deb11u4"
    }
  ]
}
```

---

## Grype Severity Gate (`.grype.yaml`)

```yaml
fail-on-severity: critical
ignore:
  # Accepted risk — no fix available, tracked in issue #42
  - vulnerability: CVE-2023-44487
    reason: "HTTP/2 rapid reset — mitigated at LB layer"
```

---

## Why This Matters

| Threat | Mitigation |
|--------|-----------|
| Dependency with known CVE ships to prod | Grype blocks PR at severity threshold |
| Tampered image pushed between build and deploy | Cosign signature + digest pinning |
| Can't prove how image was built | SLSA L3 provenance attestation |
| No inventory of what's in the image | SBOM stored as release artifact |

---

## Skills Demonstrated

- Software supply chain security (SLSA framework)
- SBOM generation in CycloneDX and SPDX formats
- Vulnerability scanning with severity-gated CI
- Keyless container image signing with Sigstore/Cosign
- GitHub Actions OIDC integration for zero-secret CI
