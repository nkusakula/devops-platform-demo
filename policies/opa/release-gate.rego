package platform.release

import future.keywords.if
import future.keywords.in

# Deny if any CRITICAL CVEs are found
deny[msg] if {
  vuln := input.Results[_].Vulnerabilities[_]
  vuln.Severity == "CRITICAL"
  msg := sprintf("CRITICAL CVE %v found in %v – remediate before release",
    [vuln.VulnerabilityID, vuln.PkgName])
}

# Deny if HIGH CVEs exceed threshold
deny[msg] if {
  high_cves := [v | v := input.Results[_].Vulnerabilities[_]; v.Severity == "HIGH"]
  count(high_cves) > 5
  msg := sprintf("Too many HIGH CVEs (%v) – threshold is 5", [count(high_cves)])
}

# Deny if base image is not in the approved list
deny[msg] if {
  image := input.ArtifactName
  not startswith(image, "gcr.io/distroless/")
  not startswith(image, "registry.access.redhat.com/ubi9-minimal/")
  not startswith(image, "ghcr.io/nkusakula/runner-base-")
  msg := sprintf("Base image '%v' is not in the approved list", [image])
}

# Deny if SBOM is missing
deny[msg] if {
  not input.SBOM
  msg := "SBOM is required but was not found in build artifacts"
}

# Allow if no deny rules triggered
allow if {
  count(deny) == 0
}
