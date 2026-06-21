#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -f profiles.yml ]; then
  cp profiles.yml.example profiles.yml
fi

export DBT_PROFILES_DIR="$PWD"

echo "Using DBT_PROFILES_DIR=$DBT_PROFILES_DIR"

dbt deps
dbt seed
dbt parse
dbt run
dbt test
dbt-governance setup

dbt-governance check
dbt-governance check --report-path target/governance-report.json

dbt-governance report --format markdown --report-path target/governance-report.md

echo "Generated reports:"
echo "- target/governance-report.json"
echo "- target/governance-report.md"
