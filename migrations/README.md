## Rinkeby Deployment Instructions

1. Clone repository:

```bash
git clone https://github.com/usefulcoin/biopset-v4-contracts.git
cd biopset-v4-contracts
git checkout -b master
```

2. Install Truffle:

```bash
sudo npm install -g truffle
```

3. Make yourself the contract owner (where ever such roles exist).

For example, change the variable value to your private key in the repository here:

https://github.com/usefulcoin/biopset-v4-contracts/blob/main/truffle-config.js#L24

4. Confirm the hardcoded oracle address is for Rinkeby on line 32:

https://github.com/BIOPset/v4-contracts/blob/master/migrations/1_erc_token_and_pool_and_options.js#L32

Here is a ETH/USD oracle address for Rinkeby:

```bash
0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
```

5. Make sure to set to "**false**"

https://github.com/BIOPset/v4-contracts/blob/master/migrations/1_erc_token_and_pool_and_options.js#L55


6. Migrate contracts to Rinkeby:

```bash
truffle migrate --network rinkeby
```

 - or -

 ```bash
 truffle deploy --network rinkeby --reset
 ```
### Note:

If you get the following error:

```bash
Error: Cannot find module 'truffle-hdwallet-provider-privkey'
```

Then run:

```bash
npm install -s truffle-hdwallet-provider-privkey
```
