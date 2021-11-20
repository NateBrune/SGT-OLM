#!/usr/bin/python3

from brownie import SGT, OptionsLM, Token, accounts


def main():
    #oldbot = accounts.load('oldbot')
    token = Token.deploy("Test Token", "TST", 18, 1e21, {'from': accounts[0]})
    sgt = SGT.deploy(accounts[1], {'from': accounts[0]})
    optionsLM = OptionsLM.deploy(sgt.address, token.address, token.address, accounts[1], "redeemable SGT", "rSGT",  {'from': accounts[0]})
    sgt.approve(optionsLM, 10000000*(10**18), {'from': accounts[1]})
    