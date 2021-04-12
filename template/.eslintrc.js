module.exports = {
	env: {
		browser: true,
		es2021: true,
		node: true,
	},
	root: true,
	parser: '@typescript-eslint/parser',
	extends: [
		'plugin:@typescript-eslint/recommended',
		'plugin:react/recommended',
		'plugin:react-hooks/recommended',
		'airbnb',
		'react-app',
		'prettier',
	],
	parserOptions: {
		ecmaFeatures: {
			jsx: true,
		},
		ecmaVersion: 2021,
		sourceType: 'module',
	},
	plugins: ['react', '@typescript-eslint', 'prettier'],
	rules: {
		"indent": [2, 2],
		'arrow-parens': ['error', 'as-needed'],
		"react-hooks/rules-of-hooks": "error",
		"react/display-name": [0],
		'prettier/prettier': 2
	},
};
