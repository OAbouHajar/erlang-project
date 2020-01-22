%%%-------------------------------------------------------------------
%%% @author Joseph Kehoe <joseph@joseph>
%%% @copyright (C) 2020, Joseph Kehoe
%%% @doc
%%%
%%% @end
%%% Created : 20 Jan 2020 by Joseph Kehoe <joseph@joseph>
%%%-------------------------------------------------------------------
-module(nspace).

-export([runAll/0,sendMsg/2]).
startns()->
    register(ns,spawn(fun()->namespace(top) end)).

namespace(State)->
    receive
	{From,[Head|Tail],MSG}->
	    %deal with it!
	    NextNSPid=get(Head),
	    NextNSPid!{From,Tail,MSG},
	    namespace(State);
	{From,[],{regNS,Pid,Name}} ->
            %Deal with it
	    put(Name,Pid),
	    From!{ok},
	    namespace(State);
	{From,[],getPid} ->
	    From!{getPid,self()},
	    namespace(State)
end.

reg(NamesSpace,Pid,Name)->
    ns!{self(),NamesSpace,{regNS,Pid,Name}},
    receive
	{ok}->
	    io:format("success: ~p \n",[Name])
    end.

hello(SecretKey)->
    receive
	{From,[],getKey}->
	    From!{key,SecretKey},
	    hello(SecretKey)
    end.

sendMsg(NameSpaces,MSG)->
    ns!{self(),NameSpaces,MSG},
	receive
	    {key,Answer}->
		io:format("Secret key is:~p",[Answer])
	end.

runAll()->    
    startns(),
    PidOpen=spawn(fun()->namespace(theopenspace) end),
    PidProp=spawn(fun()->namespace(thepropspace) end),
    reg([],PidOpen,open),
    reg([],PidProp,prop),
    PidSware1=spawn(fun()->namespace(anotherspace) end),
    PidSware2=spawn(fun()->namespace(fred) end),
    reg([open],PidSware1,sware),
    reg([prop],PidSware2,sware),
    PidKey1=spawn(fun()->hello(josIsCool) end),
    PidKey2=spawn(fun()->hello(erlangAlsoCool) end),
    reg([open,sware],PidKey1,key),
    reg([prop,sware],PidKey2,key).
    
    


