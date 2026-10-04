# ADR 0001: Use Poetry for dependency and environment management

- Status: Accepted
- Date: 2026-10-04

## Context

The project has several kinds of Python code with different needs:
an ingestion CLI (runtime deps), tests (moto, pytest), local-only PySpark
for transform tests, and an AWS Lambda that should ship almost nothing.
Glue provides PySpark at runtime, so it must never be packaged.
We want reproducible installs locally, in Docker, and in CI.

## Decision

Use Poetry 2.x with `pyproject.toml` as the single config file and a committed
`poetry.lock`. Dependencies are split into groups: `main`, `dev`, `test`,
`local` (optional), and `lambda` (optional). The virtualenv lives in `./.venv`
(`virtualenvs.in-project = true` in the committed `poetry.toml`).
Python is pinned to 3.11 to match Glue 5.0 and the Lambda runtime.

## Consequences

Good:
- One lock file gives identical dependency versions on every machine and in CI.
- Groups keep PySpark out of the runtime image and the Lambda package.
- `poetry check --lock` in pre-commit and CI catches drift between
  `pyproject.toml` and `poetry.lock`.

Trade-offs:
- Poetry cannot install into a target directory by itself. Packaging the Lambda
  needs an export step (`poetry-plugin-export`) plus `pip install --target`.
- Poetry 2.x removed `poetry lock --check`; `poetry check --lock` replaces it.
  Older tutorials still show the old command.
- Contributors need Poetry installed. CI and Docker pin the version.

## Alternatives considered

- **uv:** faster, with a standard lock file and good group support. It is a
  reasonable choice for a new project today. Poetry was chosen here for its
  mature dependency groups and wide adoption in existing data engineering teams.
  uv is still used locally to install Python 3.11.
- **pip + requirements files:** simplest, but no lock resolution across groups
  and no single config file.
- **pip-tools:** good locking, but multiple files per group and no environment
  management.
