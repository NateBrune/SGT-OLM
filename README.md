# SGT-OLM

Based on https://andrecronje.medium.com/liquidity-mining-rewards-v2-50896e44f259

In this repo is contracts for an options liquidity mining program. The way an options liquidity mining contract works is similar to a normal staking contract where tokens are given pn a pro-rata basis to depositors as time goes on. The primary difference is this contract distributes options which cost money to excercise. The money collected in the process is directed to the community multisig in the case of SharedStake.


## Configuration

1. Create a .env file that looks like this
```
WEB3_INFURA_PROJECT_ID='...'
PRIVATE_KEY='ETHEREUM_PRIVATE_KEY'
```


## Testing

To run the tests with coverage reports

> brownie test --coverage

To view the reports you can use the brownie GUI

> brownie gui

## Resources

To get started with Brownie:

* ["Getting Started with Brownie"](https://medium.com/@iamdefinitelyahuman/getting-started-with-brownie-part-1-9b2181f4cb99) is a good tutorial to help you familiarize yourself with Brownie.
* For more in-depth information, read the [Brownie documentation](https://eth-brownie.readthedocs.io/en/stable/).

## License

This project is licensed under the [MIT license](LICENSE).
