#!/bin/sh

PURPLE='\033[0;35m'
NC='\033[0m'
SERVER_DEPS=0
NO_COMMIT=0
NO_LOCK=0
ORIGIN_DIR="$(npm list -g --depth=0 --silent | head -1)/node_modules/init-cra"

# Dependencies
DEPENDENCIES=("styled-components")
DEV_DEPENDENCIES=("babel-eslint" "eslint" "eslint-plugin-babel" "eslint-config-prettier" "eslint-plugin-html" "eslint-plugin-prettier" "eslint-plugin-react" "eslint-plugin-react-hooks" "prettier")
SERVER_DEPENDENCIES=("express" "body-parser")
SERVER_DEV_DEPENDENCIES=()

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

		-nl|--no-Lock)
			NO_LOCK=1
			shift
			;;
	esac
done

# Copy config files
echo "${PURPLE}Copying custom settings files to $PWD${NC}"
cp $ORIGIN_DIR/template/.eslintrc $PWD
cp $ORIGIN_DIR/template/.prettierrc $PWD
cp $ORIGIN_DIR/template/jsconfig.json $PWD
cp $ORIGIN_DIR/template/.env $PWD
mkdir .vscode
cp $ORIGIN_DIR/template/.vscode/settings.json $PWD/.vscode/settings.json


# Add front-end deps
S_DEPENDENCIES=$( IFS=$' '; echo "${DEPENDENCIES[*]}" )
S_DEV_DEPENDENCIES=$( IFS=$' '; echo "${DEV_DEPENDENCIES[*]}" )
echo "${PURPLE}Adding React dependencies${NC}"
yarn add $S_DEPENDENCIES
echo "${PURPLE}Adding React dev dependencies${NC}"
yarn add --dev $S_DEV_DEPENDENCIES

if [ $SERVER_DEPS -eq 1 ]; then
	# Add json global dep
	package="json"
	if [ `npm list -g --depth=0 --silent | grep -c $package` -eq 0 ]; then
		echo "${PURPLE}Installing json package globally via npm${NC}"
		npm install -g $package --no-shrinkwrap
	fi

	# Add server deps
	S_SERVER_DEPENDENCIES=$( IFS=$' '; echo "${SERVER_DEPENDENCIES[*]}" )
	S_SERVER_DEV_DEPENDENCIES=$( IFS=$' '; echo "${SERVER_DEV_DEPENDENCIES[*]}" )
	echo "${PURPLE}Adding server dependencies${NC}"
	yarn add $S_SERVER_DEPENDENCIES
	echo "${PURPLE}Adding server dev dependencies${NC}"
	yarn add $S_SERVER_DEV_DEPENDENCIES
	mkdir server
	mkdir server/routes
	mkdir server/lib
	cp $ORIGIN_DIR/template/server/index.js $PWD/server/index.js
	cp $ORIGIN_DIR/template/server/routes/index.js $PWD/server/routes/index.js

	# Update package.json for server config
	echo "${PURPLE}Updating package.json for server initialization${NC}"
	json -I -f $PWD/package.json -e 'this.proxy="http://localhost:8080"'
	json -I -f $PWD/package.json -e 'this.scripts.start="nodemon server/index.js & react-scripts start"'
fi

# Lock packages
if [ $NO_LOCK -eq 0 ]; then
	echo "${PURPLE}Locking Packages${NC}"
	sed -i '' 's/\"\^/\"/g' package.json
else
	echo "${PURPLE}No Lock flag found, not locking packages${NC}"
fi

# Run prettier
echo "${PURPLE}Running Prettier${NC}"
npx prettier --loglevel error --write .

# Commit files
if [ $NO_COMMIT -eq 0 ]; then
	echo "${PURPLE}Committing init-cra changes${NC}"
	git add .
	git commit -m "Add preference files, install default deps, run prettier on all files (automatic commit via init-cra)"
else
	echo "${PURPLE}No Commit flag found, skipping automatic commit${NC}"
fi
