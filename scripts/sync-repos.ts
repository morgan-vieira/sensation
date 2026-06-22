#!/usr/bin/env tsx

import { spawnSync } from "node:child_process"
import { existsSync, readFileSync } from "node:fs"
import { dirname, join, resolve } from "node:path"
import { parseArgs } from "node:util"
import { fileURLToPath } from "node:url"

import { repos as allRepos, type RepoConfig } from "./lib/repos.ts"

class RepoSelectionError extends Error {
	constructor(repoId: string, validIds: string[]) {
		super(`Unknown repo "${repoId}". Valid ids: ${validIds.join(", ")}`)
		this.name = "RepoSelectionError"
	}
}

class VersionSourceError extends Error {
	constructor(repoId: string, sourcePath: string, cause: unknown) {
		super(
			`Failed to read/parse version source for "${repoId}" at ${sourcePath}`,
		)
		this.name = "VersionSourceError"
		this.cause = cause
	}
}

class VersionResolutionError extends Error {
	constructor(repoId: string, sourcePath: string, valuePath: string[]) {
		super(
			`No version found for "${repoId}" at ${sourcePath} → ${valuePath.join(".")}`,
		)
		this.name = "VersionResolutionError"
	}
}

class GitSubtreeError extends Error {
	constructor(
		repoId: string,
		action: "add" | "pull",
		exitCode: number,
		stderr: string,
	) {
		super(
			`git subtree ${action} failed for "${repoId}" (exit ${exitCode}):\n${stderr}`,
		)
		this.name = "GitSubtreeError"
	}
}

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..")

function readNestedString(obj: unknown, path: string[]): string | undefined {
	let cur = obj
	for (const key of path) {
		if (typeof cur !== "object" || cur === null || !(key in cur))
			return undefined
		cur = (cur as Record<string, unknown>)[key]
	}
	return typeof cur === "string" && cur.length > 0 ? cur : undefined
}

function resolveRef(repo: RepoConfig, latest: boolean): string {
	const fallback = repo.ref ?? "main"
	if (latest || !repo.version) return fallback

	const { sourcePath, valuePath, tagPrefix } = repo.version
	const absPath = join(root, sourcePath)

	let raw: string
	try {
		raw = readFileSync(absPath, "utf8")
	} catch (cause) {
		throw new VersionSourceError(repo.id, absPath, cause)
	}

	let parsed: unknown
	try {
		parsed = JSON.parse(raw)
	} catch (cause) {
		throw new VersionSourceError(repo.id, absPath, cause)
	}

	const version = readNestedString(parsed, valuePath)
	if (!version) throw new VersionResolutionError(repo.id, absPath, valuePath)

	return `${tagPrefix}${version}`
}

function runSubtree(
	repo: RepoConfig,
	action: "add" | "pull",
	ref: string,
	dryRun: boolean,
): void {
	const prefix = `.repos/${repo.id}`
	const args = [
		"subtree",
		action,
		`--prefix=${prefix}`,
		repo.url,
		ref,
		"--squash",
	]

	console.log(`  $ git ${args.join(" ")}`)
	if (dryRun) return

	const result = spawnSync("git", args, {
		cwd: root,
		stdio: ["inherit", "inherit", "pipe"],
	})
	if (result.status !== 0) {
		throw new GitSubtreeError(
			repo.id,
			action,
			result.status ?? 1,
			result.stderr?.toString() ?? "",
		)
	}
}

const { values } = parseArgs({
	options: {
		repo: { type: "string" },
		latest: { type: "boolean", default: false },
		"dry-run": { type: "boolean", default: false },
	},
	strict: true,
})

const filterById = values.repo
const latest = values.latest ?? false
const dryRun = values["dry-run"] ?? false

let repos = [...allRepos]

if (filterById) {
	repos = repos.filter((r) => r.id === filterById)
	if (repos.length === 0) {
		throw new RepoSelectionError(
			filterById,
			allRepos.map((r) => r.id),
		)
	}
}

if (repos.length === 0) {
	console.log("No repos configured in scripts/lib/repos.ts")
	process.exit(0)
}

for (const repo of repos) {
	const prefix = `.repos/${repo.id}`
	const action: "add" | "pull" = existsSync(join(root, prefix)) ? "pull" : "add"
	const ref = resolveRef(repo, latest)

	console.log(
		`Syncing ${repo.id} @ ${ref} (subtree ${action}${dryRun ? ", dry run" : ""})`,
	)
	runSubtree(repo, action, ref, dryRun)
	if (!dryRun) console.log(`  + ${repo.id} @ ${ref}`)
}
