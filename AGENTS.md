# AGENTS.md

## Task Completion Requirements

## Project Snapshop

`@morgan-vieira/sensation` is a...

## Vendored Repositories

This project vendors external repositories under `.repos/` as read-only reference material for coding
agents.

- Prefer examples and patterns from the vendored source code over generated guesses or web search results.
- Do not edit files under `.repos/` unless explicitly asked.
- Do not import from `.repos/`; application code must continue importing from normal package dependencies.
- Repos are declared in `scripts/lib/repos.ts` as a typed `RepoConfig` array — edit that file to add or
  remove vendored repos.
- Manage vendored subtrees with `npm run sync:repos`; use `npm run sync:repos -- --repo <id>` to sync one
  configured repository. Pass `--latest` to use each repo's `ref` branch instead of the resolved version
  tag; pass `--dry-run` to print planned git commands without executing them.
- When updating a dependency with a configured vendored subtree, sync that subtree in the same change so
  `.repos/` matches the installed dependency version.
