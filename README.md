# Anarchitects dbt Governance Demo

This is a local DuckDB-backed dbt project that demonstrates how the companion dbt package and the `anarchitecture-dbt-governance` Python CLI work together.

## What This Demo Shows

Currently active in this demo:

- `dbt deps` installs the companion dbt package `anarchitects_governance`.
- dbt model, source, and seed properties use the nested `meta.anarchitects.governance` convention.
- `dbt test` can run dbt-native tests, including companion package generic metadata tests.
- `dbt-governance check` remains the authoritative governance evaluator and report generator.

Planned or optional beyond this demo:

- additional companion package helpers, templates, and docs blocks as the package evolves
- future distribution options such as dbt Hub when published

## Architecture

```text
dbt deps
  -> installs companion dbt package
dbt seed / dbt parse / dbt run / dbt test
  -> builds artifacts and validates dbt-native metadata and tests
dbt-governance check
  -> reads dbt artifacts and evaluates governance
dbt-governance report
  -> renders report output
```

Boundary reminder:

- `dbt deps` installs dbt packages. It does not install `dbt-governance`.
- Install `dbt-governance` separately with `pip`, `pipx`, or `uv`.
- The companion dbt package helps author metadata and optional local checks.
- The Python CLI remains authoritative for governance evaluation and reporting.

## Prerequisites

- Python 3.11
- Node.js 24
- local filesystem access only; no cloud warehouse or credentials are required

This demo uses DuckDB and local CSV seeds.

## Install The Python CLI

Virtualenv workflow used by this repo:

```bash
python3.11 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Alternative CLI installation examples:

```bash
pipx install anarchitecture-dbt-governance
```

```bash
uv tool install anarchitecture-dbt-governance
```

## Companion dbt Package

The active install in [packages.yml](/Users/johanvrolix/Anarchitects/governance-demo/dbt/packages.yml:1) uses the community repo Git/subdirectory layout:

```yaml
packages:
  - git: "https://github.com/anarchitects/anarchitecture-community.git"
    revision: "governance-dbt-package@0.0.1"
    subdirectory: "packages/governance/dbt-package"
```

Local sibling checkout option for package development:

```yaml
packages:
  - local: ../anarchitecture-community/packages/governance/dbt-package
```

Do not treat dbt Hub installation as active here. If dbt Hub publication happens later, that should be documented separately.

## Governance Metadata Convention

This demo uses the companion package's recommended nested metadata convention:

```yaml
meta:
  anarchitects:
    governance:
      layer: marts
      domain: ecommerce
      owner:
        team: analytics
      criticality: high
      publicInterface: true
      crossDomainApproved: false
```

Concrete examples in this repo:

- [models/marts/marts.yml](/Users/johanvrolix/Anarchitects/governance-demo/dbt/models/marts/marts.yml:4)
- [models/staging/staging.yml](/Users/johanvrolix/Anarchitects/governance-demo/dbt/models/staging/staging.yml:4)
- [models/sources.yml](/Users/johanvrolix/Anarchitects/governance-demo/dbt/models/sources.yml:3)
- [seeds/seeds.yml](/Users/johanvrolix/Anarchitects/governance-demo/dbt/seeds/seeds.yml:1)

## Run The Demo Locally

```bash
cp profiles.yml.example profiles.yml
export DBT_PROFILES_DIR=$PWD
dbt deps
dbt seed
dbt parse
dbt run
dbt test
dbt-governance setup
dbt-governance check
dbt-governance check --report-path target/governance-report.json
dbt-governance report --format markdown --report-path target/governance-report.md
```

Or run the repo script:

```bash
source .venv/bin/activate
./scripts/demo.sh
```

## Companion Package Examples

These are active with the currently installed package:

```bash
dbt run-operation anarchitects_governance.governance_print_metadata_template --args '{model_name: fct_orders, layer: marts, domain: ecommerce, owner_team: analytics}'
```

```bash
dbt run-operation anarchitects_governance.governance_validate_metadata --args '{allowed_layers: [raw, staging, intermediate, marts], allowed_criticality_values: [low, medium, high, critical], required: [layer, domain, owner], fail_on_error: false}'
```

This demo also wires companion generic metadata tests onto `fct_orders` in [models/marts/marts.yml](/Users/johanvrolix/Anarchitects/governance-demo/dbt/models/marts/marts.yml:22).

## Expected Governance Findings

This demo intentionally keeps one primary metadata problem:

- [models/intentionally_problematic/problematic.yml](/Users/johanvrolix/Anarchitects/governance-demo/dbt/models/intentionally_problematic/problematic.yml:3) leaves `unowned_customer_summary` without nested governance metadata.

That intentional smell is useful because:

- the companion package metadata checks can flag the missing nested fields locally
- `dbt-governance check` can still surface ownership and metadata findings in the final report

The current runtime and rule pack also emit additional findings in this demo, including raw-to-staging layer dependency feedback and some graph-level domain-context diagnostics. Those are active runtime findings, not companion package validation failures.

## Generated Reports

Reports are written to `target/`:

- `target/governance-report.json`
- `target/governance-report.md`

These artifacts are generated from dbt artifacts plus the governance runtime. They are not produced by dbt generic tests alone.

## CI Workflow

The GitHub Actions workflow is [governance.yml](/Users/johanvrolix/Anarchitects/governance-demo/dbt/.github/workflows/governance.yml:1).

It is secret-free and runs:

- `dbt deps`
- `dbt seed`
- `dbt parse`
- `dbt run`
- `dbt test`
- `dbt-governance setup`
- `dbt-governance check --report-path target/governance-report.json`
- `dbt-governance report --format markdown --report-path target/governance-report.md`

[governance.yml](/Users/johanvrolix/Anarchitects/governance-demo/dbt/governance.yml:1) keeps `failOnBlockingViolations: false` so the demo can publish reports while still containing intentional findings.

## Boundaries

- This repo consumes the companion dbt package. It does not implement it.
- This repo consumes `anarchitecture-dbt-governance`. It does not implement the Python host or Node runtime.
- The demo is local, DuckDB-backed, and secret-free.
- The companion dbt package is not a replacement for `dbt-governance check`.
