# Anarchitects dbt Governance Demo

A DuckDB-backed dbt project demonstrating the published `anarchitecture-dbt-governance` Python CLI.

## What This Repo Demonstrates

- Creating dbt artifacts from a local DuckDB-backed dbt project
- Installing the CLI through pip, pipx, or uv
- Running `dbt-governance setup`
- Running `dbt-governance check`
- Generating human-readable, JSON, and markdown output
- Using the tooling in CI without cloud credentials
- A stricter dbt layer architecture: `staging -> intermediate -> marts`

## Important Note

This repository is a dbt project that uses `dbt-governance`. The package is installed as a Python CLI, not through `dbt deps`.

## Demo Architecture

```text
sources
  -> staging
  -> intermediate
  -> marts
```

Marts should depend on intermediate models, not directly on staging models. The intentionally problematic model is kept separate so the report can still show metadata quality feedback.

## Quickstart

```bash
python3.11 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp profiles.yml.example profiles.yml
export DBT_PROFILES_DIR=$PWD
dbt seed
dbt parse
dbt-governance setup
dbt-governance check
```

## Reports

```bash
dbt-governance check --report-path target/governance-report.json
dbt-governance report --format markdown --report-path target/governance-report.md
```

Report files are written to `target/` and are not committed.

## Demo Script

```bash
source .venv/bin/activate
./scripts/demo.sh
```

To clean generated artifacts before re-running:

```bash
./scripts/clean.sh
```

## CI

The GitHub Actions workflow is at `.github/workflows/governance.yml`. It runs dbt artifact generation, the governance check, markdown report generation, and uploads reports as artifacts.

`governance.yml` sets `failOnBlockingViolations: false` so the public demo CI stays green while still producing the full report.

## Real Projects

Real projects should set blocking violations to fail CI.

## Intentional Governance Issue

`models/intentionally_problematic/unowned_customer_summary.sql` is intentionally incomplete. This keeps one visible metadata smell in the demo.

## Public Packages Used

| Package | Type |
|---|---|
| `anarchitecture-dbt-governance` | Python CLI |
| `@anarchitects/governance-runtime-dbt` | Node runtime managed by CLI |
