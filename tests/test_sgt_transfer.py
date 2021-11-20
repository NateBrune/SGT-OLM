#!/usr/bin/python3
import brownie


def test_sender_balance_decreases(accounts, sgt):
    sender_balance = sgt.balanceOf(accounts[0])
    amount = sender_balance // 4

    sgt.transfer(accounts[1], amount, {'from': accounts[0]})

    assert sgt.balanceOf(accounts[0]) == sender_balance - amount


def test_receiver_balance_increases(accounts, sgt):
    receiver_balance = sgt.balanceOf(accounts[1])
    amount = sgt.balanceOf(accounts[0]) // 4

    sgt.transfer(accounts[1], amount, {'from': accounts[0]})

    assert sgt.balanceOf(accounts[1]) == receiver_balance + amount


def test_total_supply_not_affected(accounts, sgt):
    total_supply = sgt.totalSupply()
    amount = sgt.balanceOf(accounts[0])

    sgt.transfer(accounts[1], amount, {'from': accounts[0]})

    assert sgt.totalSupply() == total_supply


def test_returns_true(accounts, sgt):
    amount = sgt.balanceOf(accounts[0])
    tx = sgt.transfer(accounts[1], amount, {'from': accounts[0]})

    assert tx.return_value is True


def test_transfer_full_balance(accounts, sgt):
    amount = sgt.balanceOf(accounts[0])
    receiver_balance = sgt.balanceOf(accounts[1])

    sgt.transfer(accounts[1], amount, {'from': accounts[0]})

    assert sgt.balanceOf(accounts[0]) == 0
    assert sgt.balanceOf(accounts[1]) == receiver_balance + amount


def test_transfer_zero_sgts(accounts, sgt):
    sender_balance = sgt.balanceOf(accounts[0])
    receiver_balance = sgt.balanceOf(accounts[1])

    sgt.transfer(accounts[1], 0, {'from': accounts[0]})

    assert sgt.balanceOf(accounts[0]) == sender_balance
    assert sgt.balanceOf(accounts[1]) == receiver_balance


def test_transfer_to_self(accounts, sgt):
    sender_balance = sgt.balanceOf(accounts[0])
    amount = sender_balance // 4

    sgt.transfer(accounts[0], amount, {'from': accounts[0]})

    assert sgt.balanceOf(accounts[0]) == sender_balance


def test_insufficient_balance(accounts, sgt):
    balance = sgt.balanceOf(accounts[0])

    with brownie.reverts():
        sgt.transfer(accounts[1], balance + 1, {'from': accounts[0]})


def test_transfer_event_fires(accounts, sgt):
    amount = sgt.balanceOf(accounts[0])
    tx = sgt.transfer(accounts[1], amount, {'from': accounts[0]})

    assert len(tx.events) == 1
    assert tx.events["Transfer"].values() == [accounts[0], accounts[1], amount]
