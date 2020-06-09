#!/bin/sh

PURPLE='\033[0;35m'
NC='\033[0m'
SERVER_DEPS=0

# copying files
echo "${PURPLE}Copying custom settings files to $PWD${NC}"
origin_dir="/Users/$USER/repos/cra-project-files"
#client
cp $origin_dir/.eslintrc $PWD
cp $origin_dir/.prettierrc $PWD
cp $origin_dir/jsconfig.json $PWD
cp $origin_dir/.env $PWD
mkdir .vscode
cp $origin_dir/.vscode/settings.json $PWD/.vscode/settings.json


# add yarn deps
echo "${PURPLE}Adding React dependencies${NC}"
yarn add --dev babel-eslint eslint eslint-plugin-babel eslint-config-prettier eslint-plugin-html eslint-plugin-prettier eslint-plugin-react eslint-plugin-react-hooks prettier
yarn add styled-components

# check for server flag and add deps
for arg in "$@"
do
	case $arg in
		-s|--server)
		SERVER_DEPS=1

		# add json global dep
		package="json"
		if [ `npm list -g --depth=0 --silent | grep -c $package` -eq 0 ]; then
			echo "${PURPLE}Installing json package globally via npm${NC}"
			npm install -g $package --no-shrinkwrap
		fi

		echo "${PURPLE}Adding server dependencies${NC}"
		yarn add express body-parser
		mkdir server
		mkdir server/routes
		mkdir server/lib
		cp $origin_dir/server/index.js $PWD/server/index.js
		cp $origin_dir/server/routes/index.js $PWD/server/routes/index.js
		shift
		;;
	esac
done

# lock packages
sed -i '' 's/\"\^/\"/g' package.json

if [ $SERVER_DEPS -eq 1 ]; then
	echo "${PURPLE}Updating package.json for server initialization${NC}"
	json -I -f $PWD/package.json -e 'this.proxy="http://localhost:8080"'
	json -I -f $PWD/package.json -e 'this.scripts.start="nodemon server/index.js & react-scripts start"'
fi

# run prettier
echo "${PURPLE}Running Prettier${NC}"
npx prettier --loglevel error --write .

# commit files
echo "${PURPLE}Committing preference files${NC}"
git add .
git commit -m "Add preference files, install default deps, run prettier on all files (automatic commit via init-cra)"
