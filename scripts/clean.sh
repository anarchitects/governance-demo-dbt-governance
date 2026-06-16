#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

rm -rf target logs dbt_packages .anarchitecture profiles.yml
rm -f demo.duckdb

echo "Cleaned generated artifacts."
