#!/usr/bin/python3
import brownie

import time

def test_deposit_claim(accounts, optionsLM, sgt, token, chain):
    INTERVAL = 60 * 60 * 24 * 7
    tx1 = token.approve(optionsLM, 100*(10**18))
    assert token.allowance(accounts[0], optionsLM) == 100*(10**18)
    assert token.balanceOf(accounts[0]) >= 100*(10**18)
    tx2 = optionsLM.deposit(7*(10**18), accounts[0], {'from': accounts[0]})
    assert optionsLM.balanceOf(accounts[0]) == 0
    assert optionsLM.earned(accounts[0]) == 0
    chain.sleep(int(INTERVAL))
    chain.mine()
    earned = optionsLM.earned(accounts[0])
    assert earned > (6.99*(10**18))
    claim = optionsLM.getReward()
    assert optionsLM.balanceOf(accounts[0]) == 1
    chain.sleep(int(INTERVAL))
    chain.mine()
    balanceBefore = token.balanceOf(accounts[0])
    optionsLM.redeem(optionsLM.tokenOfOwnerByIndex(accounts[0], 0))
    balanceAfter = token.balanceOf(accounts[0])
    assert earned * 3 == balanceBefore-balanceAfter



    #optionsLM.getReward()