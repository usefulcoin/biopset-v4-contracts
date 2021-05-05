## Testing Setup

1. Clone repository:

```bash
git clone https://github.com/usefulcoin/biopset-v4-contracts.git
```

2. Install Truffle:

```bash
sudo npm install -g truffle
```

2. Install Ganache-CLI:

```bash
sudo npm install -g ganache-cli
```

4. Install Packages

```bash
cd biopset-v4-contracts
git checkout -b master
npm install
```

5. Start Ganache-CLI

```bash
ganache-cli
```

6. Make sure to set to "**true**" for local testing.

https://github.com/BIOPset/v4-contracts/blob/master/migrations/1_erc_token_and_pool_and_options.js#L55

7. Run Truffle Test

```bash
truffle test
```
