import style from "@isentinel/eslint-config";

export default style({
	package: true,
	roblox: false,
	rules: {
		"unicorn/filename-case": [
			"error",
			{
				case: "kebabCase",
				ignore: ["^[A-Z0-9]+\.md$", "mcp_servers.json"],
				multipleFileExtensions: true,
			},
		],
	},
});
