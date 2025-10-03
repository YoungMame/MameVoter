# MameVoter

MameVoter is a simple voting smart contract that allows users to vote for candidates. The contract owner can withdraw the accumulated funds (corrupted votes feature).
This project aims to show how blockchain could be used in a corrupted government.
Smart contracts are decentralized and immutable, making them a great fit for voting systems.

## Features
- Vote for candidates
- Corrupted votes (pay to vote, just for the ether transfer example)
- Owner can withdraw funds from corrupted votes
- Get the current owner


## Requirements
- [Foundry]

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge test
```

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
