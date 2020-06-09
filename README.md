# CRA Project Files

This repo is for my own personal CRA app config. If you would like to use this, you can install it and add `alias init-cra="sh ~/repos/cra-project-files/import-project-files.sh"` to your startup script (.bashrc, .zshrc, etc)

You will need to modify `origin_dir` in `import-project-files.sh` to point to your own directory.


## Options

### ***-s / --server***

Applying this flag will install `express` and `body-parser`, along with creating a server folder and a basic Express API scaffold. This will also update your `package.json` file to start the server and proxy it to your CRA app.

### ***-nc / --no-commit***

Applying this flag will skip automatically committing the files created and altered by init-cra

