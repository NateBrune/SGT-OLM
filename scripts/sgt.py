#!/usr/bin/python3

from brownie import SGT, accounts


def main():
    return SGT.deploy(accounts[0], {'from': accounts[0]})
