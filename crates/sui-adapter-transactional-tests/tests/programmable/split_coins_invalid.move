// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// tests various invalid operations involving SplitCoins


//# init --addresses test=0x0 --accounts A B C

//# publish
module test::m1 {
    use std::vector;
    use sui::coin;
    use sui::transfer;

    public fun ret_one_amount(): address {
        @42
    }

    public fun transfer(v: vector<coin::Coin<sui::sui::SUI>>, r: address) {
        while (!vector::is_empty(&v)) {
            let c = vector::pop_back(&mut v);
            transfer::public_transfer(c, r);
        };
        vector::destroy_empty(v);
    }
}

// let's get ourselves a coin worth 1000
//# run sui::pay::split_and_transfer --type-args sui::sui::SUI --args object(100) 1000 @A --sender A

//# view-object 109

// split off more than it's available
//# programmable --sender A --inputs object(109) 10001 @B
//> 0: SplitCoins(Input(0), [Input(1)]);

// split off more than it's available using vector of amounts
//# programmable --sender A --inputs object(109) 333 333 335
//> 0: SplitCoins(Input(0), [Input(1), Input(2), Input(3)]);

// use incorrect amount type for split
//# programmable --sender A --inputs object(109) @C
//> 0: SplitCoins(Input(0), [Input(1)]);

// use incorrect amount type for split with the first one being correct
//# programmable --sender A --inputs object(109) 100 @C
//> 0: SplitCoins(Input(0), [Input(1), Input(2)]);

// use incorrect arg type for split coming from a Move function
//# programmable --sender A --inputs object(109)
//> 0: test::m1::ret_one_amount();
//> 1: SplitCoins(Input(0), [Result(0)]);

// use incorrect arg type for split by creating a vector of u64s
//# programmable --sender A --inputs object(109) 100
//> 0: MakeMoveVec<u64>([Input(1), Input(1), Input(1)]);
//> 1: SplitCoins(Input(0), [Result(0)]);

// pass result of SplitCoins directly as another function argument without creating and intermediate
// vector first
//# programmable --sender A --inputs object(109) 100 100 @B
//> 0: SplitCoins(Input(0), [Input(1), Input(2)]);
//> test::m1::transfer(Result(0), Input(3));
