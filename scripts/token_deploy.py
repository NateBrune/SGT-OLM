#!/usr/bin/python3

from brownie import Token, accounts


def main():
    oldbot = accounts.load('oldbot')
    return Token.deploy("SGT Test Token", "STST", 18, 1e21, {'from': oldbot})
