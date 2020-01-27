-module(project).
-export([start/0, store/2, lookup/1,prime/1,sendTo/2,hasNoDivisor/2,isPrime/1,getNthPrime/1,getNextPrime/1]).


%to get the prime
prime(Pr)->
    rpc({prime,Pr}).

getPrime(Pr)->
    io:format("the prime is : ~p \n",[lists:nth(Pr, [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97])]).
 


isPrime(Number)->
    hasNoDivisor(Number,2).

hasNoDivisor(N,Count) when Count > N div 2 ->
    true;
hasNoDivisor(N,Count) when N rem Count == 0 ->
    false;
hasNoDivisor(N,Count) ->
    hasNoDivisor(N,Count+1).



getNthPrime(Index) ->
    getNthPrime(Index,1,2).

getNthPrime(1,1,2) -> 
    2;    
getNthPrime(N,N,CP) -> 
    CP;
getNthPrime(Index,Count,CP) -> 
    NextPrime = getNextPrime(CP+1),
    getNthPrime(Index,Count+1,NextPrime).

getNextPrime(N) ->
    case isPrime(N) of
        true ->  N;    
        false -> getNextPrime(N+1)
end.


    
    

%to send to the table key
sendTo(Key,Pr)->
    rpc({sendTo,Key,Pr}).



%joe code old one
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
	    put(Key,Value),
	    From!{project,true},
	    loop();
	{From,{lookup,Key}} ->
	    From!{project, get(Key)},
	    loop();
    {From,{prime,Pr}} ->
	    From!{project, getPrime(Pr)},
        loop();
    {From,{sendTo,Pr}} ->
	    
        From!{project,getPrime(Pr)},
        loop()
    end.

