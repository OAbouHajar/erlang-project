-module(project).
-export([start/0, store/2, lookup/1,prime/1]).



prime(Pr)->
    rpc({prime,Pr}).


getPrime(Pr)->
    io:format("success: ~p \n",[lists:nth(Pr, [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97])]).
    

%prime(Pr)->
%   io:format("success: ~p \n",[lists:nth(Pr, [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97])]).
    

start()->
    register(project, spawn(fun()->loop() end)).

store(Key,Value)->
    rpc({store,Key,Value}).

lookup(Key)->
    rpc({lookup,Key}).

rpc(Query)->
    project!{self(), Query},
    receive
	{project,Reply}->
	    Reply
    end.
    
loop()->
    receive
	{From, {store,Key,Value}}->
	    put(Key,{ok,Value}),
	    From!{project,true},
	    loop();
	{From,{lookup,Key}} ->
	    From!{project, get(Key)},
	    loop();
    {From,{prime,Pr}} ->
	    From!{project, getPrime(Pr)},
        loop() 
    end.

