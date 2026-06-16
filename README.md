# Anarchitects dbt Governance Demo

A minimal DuckDB-backed dbt project demonstrating the published `anarchitecture-dbt-governance` Python CLI.

## What This Repo Demonstrates

- Creating dbt artifacts from a local DuckDB-backed dbt project
- Installing the `anarchitecture-dbt-governance` CLI through pip, pipx, or uv
- Running `dbt-governance setup` to install and verify the pinned Node runtime
- Running `dbt-governance check` to analyse a dbt project
- Generating human-readable, JSON, and markdown governance output
- Using dbt Governance in CI with no cloud credentials or warehouse
- Separating dbt project code from governance tooling

## Important Note

**This repository is a dbt project that uses `dbt-governance`.
`anarchitecture-dbt-governance` is not installed through `dbt deps`.
It is installed as a Python CLI through pip, pipx, or uv.**

## Architecture

```text
dbt project
  -> dbt artifacts in target/
  -> dbt-governance Python host
  -> dbt-governance-runtime process/JSON boundary
  -> governance runtime/adapter/extension/core
  -> human, JSON, and markdown reports
```

## Prerequisites

- Python 3.11+ (required — earlier Python versions are not supported by the current CLI build)
- Node.js >=20 <25 (required — the CLI manages a pinned Node runtime package; Node 24 is supported)
- pip, pipx, or uv
- No data warehouse required
- No dbt Cloud required

## Quickstart (Simple venv Path)

The simplest way to run the full demo in a single environment:

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

`requirements.txt` installs both dbt and the governance CLI together so they share the same environment.

## Generate Reports

```bash
dbt-governance check --report-path target/governance-report.json
dbt-governance report --format markdown --report-path target/governance-report.md
```

Report files are written to `target/`. They are listed in `.gitignore` and are not committed to the repository.

## Alternative: Run Parse During Check

```bash
dbt-governance check --parse
```

This calls `dbt parse` internally when `manifest.json` is not yet present.

## pipx / uv Tool Install Paths

You may also install the CLI globally, separate from the dbt project environment:

```bash
# pipx
pipx install anarchitecture-dbt-governance

# uv
uv tool install anarchitecture-dbt-governance
```

> When using pipx or uv tool, `dbt-governance` runs in its own isolated environment.
> You still need `dbt`, `dbt-duckdb`, and a compatible Python environment available
> in your project to run `dbt seed`, `dbt parse`, and other dbt commands.
> For demo simplicity, `requirements.txt` installs everything in one venv.

## Demo Script

Activate your venv first, then run:

```bash
source .venv/bin/activate
./scripts/demo.sh
```

The script is safe to re-run and will:

- Copy `profiles.yml.example` to `profiles.yml` if not already present
- Export `DBT_PROFILES_DIR` to the repository root
- Run `dbt seed` and `dbt parse`
- Run `dbt-governance setup` to install or verify the pinned runtime
- Run `dbt-governance check`
- Write JSON report to `target/governance-report.json`
- Write markdown report to `target/governance-report.md`

To clean generated artifacts before re-running:

```bash
./scripts/clean.sh
```

## CI

The GitHub Actions workflow is at [.github/workflows/governance.yml](.github/workflows/governance.yml).

The workflow:
- runs on push and pull requests
- uses Python 3.11 and Node 22
- installs dependencies from `requirements.txt`
- copies `profiles.yml.example` to `profiles.yml`
- sets `DBT_PROFILES_DIR` to the workspace root
- runs `dbt seed`, `dbt parse`
- runs `dbt-governance setup` and `dbt-governance check`
- generates a markdown report
- uploads both reports as artifacts
- uses no secrets and no cloud services

`governance.yml` sets `failOnBlockingViolations: false` so the public demo CI stays green while still producing the full governance report.

## Enforcing Governance in Real Projects

This demo keeps CI green by setting `failOnBlockingViolations: false` in `governance.yml`.
Real projects should set it to `true` so that blocking violations cause a non-zero exit code and fail the CI pipeline:

```yaml
host:
  ci:
    failOnBlockingViolations: true
```

## Intentional Governance Issue

`models/intentionally_problematic/unowned_customer_summary.sql` is intentionally documented
without `owner`, `domain`, or `criticality` metadata in `models/intentionally_problematic/problematic.yml`.

This produces a visible governance smell in the report so demos can show how the tooling surfaces metadata quality gaps.
The exact diagnostics depend on the active governance profile and runtime version.

## Troubleshooting

- **dbt profile not found**: ensure `profiles.yml` exists and `DBT_PROFILES_DIR` is set to the repository root.
- **dbt_project.yml not found**: run all commands from the repository root directory.
- **manifest.json not found**: run `dbt parse` first, or use `dbt-governance check --parse`.
- **dbt fails with mashumaro / Python 3.14 stack traces**: recreate `.venv` with Python 3.11 (`rm -rf .venv && python3.11 -m venv .venv`).
- **ModuleNotFoundError: tomllib**: use Python 3.11+.
- **Unsupported Node version**: use Node.js 20, 22, or 24 (`>=20 <25`).
- **Runtime package cannot be installed**: check network access to npm and verify the package name `@anarchitects/governance-runtime-dbt`.
- **incompatible_runtime_metadata error**: the published runtime package may self-report a different version in its internal metadata. This is a known packaging gap in early releases. The governance report is still generated; run `dbt-governance doctor` to inspect the environment state.
- **DuckDB adapter missing**: run `pip install -r requirements.txt` inside the active venv.
- **Blocking violations / exit code 1**: set `host.ci.failOnBlockingViolations: false` in `governance.yml` for demo or exploratory runs.

## Public Packages Used

| Package | Type | Link |
|---|---|---|
| `anarchitecture-dbt-governance` | Python CLI | [PyPI](https://pypi.org/project/anarchitecture-dbt-governance/) |
| `@anarchitects/governance-runtime-dbt` | Node runtime (managed by CLI) | [npm](https://www.npmjs.com/package/@anarchitects/governance-runtime-dbt) |

- CLI command: `dbt-governance`
- Runtime executable: `dbt-governance-runtime`
- Runtime version pinned by host: `0.1.0`
- Required Node range: `>=20 <25`

## Links

- PyPI: https://pypi.org/project/anarchitecture-dbt-governance/
- npm: https://www.npmjs.com/package/@anarchitects/governance-runtime-dbt
- Anarchitects community repo: https://github.com/anarchitects/anarchitecture-community
