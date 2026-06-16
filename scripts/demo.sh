#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -f profiles.yml ]; then
  cp profiles.yml.example profiles.yml
fi

export DBT_PROFILES_DIR="$PWD"

echo "Using DBT_PROFILES_DIR=$DBT_PROFILES_DIR"

dbt seed
dbt parse
dbt-governance setup

# Run check. Exit code 2 from dbt-governance indicates runtime or contract
# compatibility diagnostics. The governance report is still produced.
# This demo uses failOnBlockingViolations: false so governance findings are
# reported without failing the script.
dbt-governance check --report-path target/governance-report.json || {
  EC=$?
  echo ""
  echo "dbt-governance check exited with code $EC."
  echo "The JSON report was written. See target/governance-report.json."
  echo "If you see 'incompatible_runtime_metadata', this is a known upstream"
  echo "packaging issue where @anarchitects/governance-runtime-dbt@0.1.0 reports"
  echo "its internal version as 0.0.1. The governance analysis still ran."
  echo ""
}

dbt-governance report --format markdown --report-path target/governance-report.md || true

echo "Generated reports:"
echo "- target/governance-report.json"
echo "- target/governance-report.md"
