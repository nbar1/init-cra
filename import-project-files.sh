#!/bin/sh

# copying files
echo "Copying custom settings files to $PWD"
origin_dir="/Users/$USER/repos/cra-project-files"
cp $origin_dir/.eslintrc $PWD
cp $origin_dir/.prettierrc $PWD
cp $origin_dir/jsconfig.json $PWD
mkdir .vscode
cp $origin_dir/.vscode/settings.json $PWD/.vscode/settings.json


# add yarn deps
echo "Adding Yarn dependencies"
yarn add --dev babel-eslint eslint eslint-plugin-babel eslint-config-prettier eslint-plugin-html eslint-plugin-prettier eslint-plugin-react eslint-plugin-react-hooks prettier
yarn add styled-components

# lock packages
sed -i '' 's/\"\^/\"/g' package.json

# run prettier
echo "Running Prettier"
npx prettier --loglevel error --write .

# commit files
echo "Committing preference files"
git add .
git commit -m "Add preference files, install default deps, run prettier on all files (automatic commit via init-cra)"
