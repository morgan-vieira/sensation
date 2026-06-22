export interface RepoVersion {
	sourcePath: string
	valuePath: string[]
	tagPrefix: string
}

export interface RepoConfig {
	id: string
	url: string
	ref?: string
	version?: RepoVersion
}

export const repos: ReadonlyArray<RepoConfig> = [
	{
		id: "LibStudioElttob",
		url: "https://github.com/Elttob/LibStudioElttob.git",
		ref: "main",
	},
]
