%%%-------------------------------------------------------------------
%%% @author Joseph Kehoe <joseph@joseph-Inspiron-13-5378>
%%% @copyright (C) 2020, Joseph Kehoe
%%% @doc
%%%
%%% @end
%%% Created : 12 Jan 2020 by Joseph Kehoe <joseph@joseph-Inspiron-13-5378>
%%%-------------------------------------------------------------------
-module(kvs).
-export([start/0, store/2, lookup/1]).


start()->
    register(kvs, spawn(fun()->loop() end)).

store(Key,Value)->
    rpc({store,Key,Value}).

lookup(Key)->
    rpc({lookup,Key}).

rpc(Query)->
    kvs!{self(), Query},
    receive
	{kvs,Reply}->
	    Reply
    end.
    
loop()->
    receive
	{From, {store,Key,Value}}->
	    put(Key,{theval,Value}),
	    From!{kvs,true},
	    loop();
	{From,{lookup,Key}} ->
	    From!{kvs, get(Key)},
	    loop()
    end.


