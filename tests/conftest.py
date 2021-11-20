#!/usr/bin/python3

import pytest


@pytest.fixture(scope="function", autouse=True)
def isolate(fn_isolation):
    # perform a chain rewind after completing each test, to ensure proper isolation
    # https://eth-brownie.readthedocs.io/en/v1.10.3/tests-pytest-intro.html#isolation-fixtures
    pass


@pytest.fixture(scope="module")
def token(Token, accounts):
    return Token.deploy("Test Token", "TST", 18, 1e21, {'from': accounts[0]})

@pytest.fixture(scope="module")
def sgt(SGT, accounts):
    return SGT.deploy(accounts[1], {'from': accounts[1]})

@pytest.fixture(scope="module")
def optionsLM(OptionsLM, token, sgt, accounts):
    #token = Token.deploy("Test Token", "TST", 18, 1e21, {'from': accounts[0]})
    #sgt = SGT.deploy(accounts[1], {'from': accounts[1]})
    #    address _reward,
    #    address _stake,
    #    address _buyWith,
    #    address _treasury,
    #    string memory _name,
    #    string memory _symbol
    optionsLM = OptionsLM.deploy(sgt.address, token.address, token.address, accounts[1], "redeemable SGT", "rSGT",  {'from': accounts[0]})
    print("options lm deployed with: " +sgt.address + " and " + token.address)
    sgt.approve(optionsLM, 10000000*(10**18), {'from': accounts[1]})
    optionsLM.notify(7*(10**18), {'from': accounts[1]})

    return optionsLM
