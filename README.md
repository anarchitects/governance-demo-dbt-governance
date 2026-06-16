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
- A stricter dbt layer architecture: `staging -> intermediate -> marts`

## Important Note

**This repository is a dbt project that uses `dbt-governance`.
`anarchitecture-dbt-governance` is not installed through `dbt deps`.
It is installed as a Python CLI through pip, pipx, or uv.**

## Demo Architecture

```text
sources
  -> staging
  -> intermediate
  -> marts
```

Marts should depend on intermediate models, not directly on staging models. The intentionally problematic model is kept separate so the report can still demonstrate metadata-quality feedback.
