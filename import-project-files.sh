#!/bin/sh

PURPLE='\033[0;35m'
NC='\033[0m'
SERVER_DEPS=0
NO_COMMIT=0
ORIGIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Check for server flag and add deps
for arg in "$@"
do
	case $arg in
		-s|--server)
			SERVER_DEPS=1
			shift
			;;

		-nc|--no-commit)
			NO_COMMIT=1
			shift
			;;
	esac
done

# Copy config files
echo "${PURPLE}Copying custom settings files to $PWD${NC}"
cp $ORIGIN_DIR/.eslintrc $PWD
cp $ORIGIN_DIR/.prettierrc $PWD
cp $ORIGIN_DIR/jsconfig.json $PWD
cp $ORIGIN_DIR/.env $PWD
mkdir .vscode
cp $ORIGIN_DIR/.vscode/settings.json $PWD/.vscode/settings.json


# Add front-end deps
echo "${PURPLE}Adding React dependencies${NC}"
yarn add --dev babel-eslint eslint eslint-plugin-babel eslint-config-prettier eslint-plugin-html eslint-plugin-prettier eslint-plugin-react eslint-plugin-react-hooks prettier
yarn add styled-components

# Lock packages
sed -i '' 's/\"\^/\"/g' package.json

if [ $SERVER_DEPS -eq 1 ]; then
	# Add json global dep
	package="json"
	if [ `npm list -g --depth=0 --silent | grep -c $package` -eq 0 ]; then
		echo "${PURPLE}Installing json package globally via npm${NC}"
		npm install -g $package --no-shrinkwrap
	fi

	# Add server deps
	echo "${PURPLE}Adding server dependencies${NC}"
	yarn add express body-parser
	mkdir server
	mkdir server/routes
	mkdir server/lib
	cp $ORIGIN_DIR/server/index.js $PWD/server/index.js
	cp $ORIGIN_DIR/server/routes/index.js $PWD/server/routes/index.js

	# Update package.json for server config
	echo "${PURPLE}Updating package.json for server initialization${NC}"
	json -I -f $PWD/package.json -e 'this.proxy="http://localhost:8080"'
	json -I -f $PWD/package.json -e 'this.scripts.start="nodemon server/index.js & react-scripts start"'
fi

# Run prettier
echo "${PURPLE}Running Prettier${NC}"
npx prettier --loglevel error --write .

# Commit files
if [ $NO_COMMIT -eq 0 ]; then
	echo "${PURPLE}Committing preference files${NC}"
	git add .
	git commit -m "Add preference files, install default deps, run prettier on all files (automatic commit via init-cra)"
else
	echo "${PURPLE}No Commit flag found, skipping automatic commit${NC}"
fi
