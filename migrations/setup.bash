#! /bin/bash
#
# script name: setup.bash
# script author: munair simpson
# script created: 20210505
# script purpose: spin up ec2 instance for deploying contracts.

# disable/enable debugging.
debug="false" && echo [$0] set debug mode to "$debug".

# step 1: update the package list and install Yarn. this also installs Node. install unzip and install NPM last.
if $debug ; then sudo apt -y update && sudo apt -y install unzip && sudo apt -y install npm && sudo apt -y install vim && sudo apt -y install awscli; fi
sudo apt -y update > /dev/null 2>&1 && echo [$0] updated APT packages.
sudo apt -y install unzip > /dev/null 2>&1 && echo [$0] installed unzip APT.
sudo apt -y install npm > /dev/null 2>&1 && echo [$0] installed NPM APT.
sudo apt -y install vim > /dev/null 2>&1 && echo [$0] installed vim APT.

# step 2: verify the installation of APTs and configure AWS Client.
nodeversion=$(nodejs --version) && echo [$0] verified the installation of nodejs version $nodeversion.
npmversion=$(npm --version) && echo [$0] verified the installation of npm version $npmversion.

# step 3: clone repository.
git clone https://github.com/usefulcoin/biopset-v4-contracts.git && echo [$0] cloned repository.
cd biopset-v4-contracts && echo [$0] repository is now the working directory.
git checkout -b master && echo [$0] checked out the master branch.

# step 4: install truffle globally and the truffle hd wallet.
sudo npm install -g truffle && echo [$0] installed truffle globally.
npm install -s truffle-hdwallet-provider-privkey && echo [$0] installed truffle hdwallet.

# step 5: review configuration files and run truffle.
vi migrations/1_erc_token_and_pool_and_options.js
vi truffle-config.js
truffle migrate --network rinkeby
