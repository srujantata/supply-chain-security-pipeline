# supply-chain-security-pipeline

![Cosign](https://img.shields.io/badge/Cosign-Sigstore-2962FF)
![SLSA](https://img.shields.io/badge/SLSA-Level%202-brightgreen)
![Syft](https://img.shields.io/badge/SBOM-Syft-orange)
![Grype](https://img.shields.io/badge/Scan-Grype-red)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?logo=github-actions)
![Rekor](https://img.shields.io/badge/Transparency-Rekor-blue)

> Software supply chain security — SBOM, Cosign image signing, SLSA provenance, GitHub Actions

---

## What This Does

End-to-end software supply chain security pipeline in GitHub Actions. Generates SBOMs with Syft, signs container images with Cosign against Sigstore's Rekor transparency log, enforces SLSA Level 2 provenance, and scans for vulnerabilities with Grype before any image reaches production.

---

## Pipeline Stages

1. **Build** — Docker buildx, multi-platform
2. **SBOM** — Syft generates CycloneDX JSON
3. **Scan** — Grype checks SBOM against CVE databases
4. **Sign** — Cosign keyless signing via GitHub OIDC → Sigstore
5. **Attest** — SLSA provenance attestation stored in Rekor
6. **Gate** — Policy: block if CRITICAL CVEs found

## What's Inside

- `.github/workflows/supply-chain.yml` — full pipeline
- `policy/` — OPA policies for CVE severity gating
- `verify.sh` — verify any image signature + provenance
- `sbom/` — example SBOM outputs (CycloneDX JSON)
- Admission controller config for Cosign verification at deploy time

## Verify an Image

```bash
# Verify signature
cosign verify ghcr.io/srujantata/app:latest \
  --certificate-identity-regexp 'https://github.com/srujantata' \
  --certificate-oidc-issuer 'https://token.actions.githubusercontent.com'

# Verify SLSA provenance
cosign verify-attestation --type slsaprovenance ghcr.io/srujantata/app:latest
```

---

## Skills Demonstrated

`Syft` · `Cosign` · `Sigstore` · `SLSA` · `Grype` · `Rekor` · `GitHub Actions`
