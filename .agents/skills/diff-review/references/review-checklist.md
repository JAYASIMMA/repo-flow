# Review Checklist

Prompts to run against a diff once the main pass is done. Do not read all of it; open the section that matches the change.

## By change type

**Dependency or lockfile touched** — is the lockfile change consistent with the manifest? Any new package with a postinstall script, a version jump crossing a major, or a package name close to a popular one?

**Schema or migration** — can it run on a live table without a long lock? Is there a rollback, and does the old code path still work while deploys roll out? Added a required column without a default on a populated table?

**Configuration** — is a new key defaulted safely? Does a value hardcode an environment, a region, or a machine path?

**Error handling** — is the error swallowed, logged and continued, or converted into a misleading success? Does a wrapped error keep enough context to debug the original?

**Concurrency** — what is shared, and who else mutates it? Timeouts and cancellation propagated? Idempotent retries?

**Deletion or rewrite** — is history or data destroyed that cannot be recovered? Any force-push or hard reset in the change?

## By language

**Go** — `err` checked on every return path; `defer` for cleanup; context as the first parameter and actually propagated; loop variable captured by reference in goroutines; slice or map aliased across a package boundary; comparison that ignores wrapped cause.

**TypeScript / JavaScript** — `==` instead of `===`; unhandled promise rejection and missing `await` in loops; `any` widening into a typed boundary; optional chaining hiding a real null; mutable module-level state shared across requests; `catch {}` with an empty body.

**Python** — mutable default arguments; bare `except:`; equality comparisons against `None`; reading files without a context manager; `assert` used for runtime validation that vanishes under `-O`.

**SQL** — unindexed predicate on a large table; `SELECT *` feeding a strict mapper; missing partition or shard key on a distributed query; implicit transaction around multiple statements.

## Security pass

Input reaching a shell, database, filesystem, template, or deserialiser without escaping. Secrets anywhere in the diff, including fixtures and tests. Authz checked in the UI but not the handler. Object IDs taken from the client without an ownership check. Log statements that print tokens or personal data. Broadened CORS, wildcard IAM, or a policy that grants `*`.
