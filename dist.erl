%%%-------------------------------------------------------------------
%%% @author Joseph <joseph@joseph-OptiPlex-5050>
%%% @copyright (C) 2020, Joseph
%%% @doc
%%%
%%% @end
%%% Created :  3 Feb 2020 by Joseph <joseph@joseph-OptiPlex-5050>
%%%-------------------------------------------------------------------
-module(dist).
-export([ping/1,pong/1]).

ping(N)->
    receive
	{ping,Sender}->
	    io:format("ping number: ~p from ~p",[N,Sender]),
	    Sender!{pong,self()},
	    ping(N+1)
    end.

pong(N)->
    receive
	{pong,Sender}->
	    io:format("pong number: ~p from ~p",[N,Sender]),
	    Sender!{ping,self()},
	    pong(N+1)
    end.


