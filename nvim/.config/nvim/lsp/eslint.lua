-- eslint: -32603: Request textDocument/diagnostic failed with message: The "path" argument must be
--  of type string. Received undefined
return {
	cmd = { "vscode-eslint-language-server", "--stdio" },
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
		"vue",
		"svelte",
		"astro",
	},
	root_markers = {
		".eslintrc",
		".eslintrc.js",
		".eslintrc.cjs",
		".eslintrc.yaml",
		".eslintrc.yml",
		".eslintrc.json",
		"eslint.config.js",
		"eslint.config.mjs",
		"eslint.config.cjs",
		"eslint.config.ts",
		"eslint.config.mts",
		"eslint.config.cts",
	},
	settings = {
		codeActionsOnSave = {
			enable = true,
			mode = "all",
		},
		experimental = {
			useFlatConfig = true,
		},
		format = true,
		nodePath = "",
		quiet = false,
		problems = { shortenToSingleLine = true },
		validate = "on",
	},
}
