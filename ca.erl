%%%-------------------------------------------------------------------
%%% @author Osama Abouhajar <osama@osama>
%%% @copyright (C) 2020, Osama Abouhajar
%%% @doc
%%%
%%% @end
%%% Created : 03 Feb 2020 by Osama Abouhajar <osama@osama>
%%%-------------------------------------------------------------------

-module(ca).
-export([start/0,getNthPrime/1,getRTables/2,getRTable/2,lookUpTable/2,nList/0,rTable/0,findNighPid/2
        ,nListSam/0 ,rTableSam/0,initNList/0]).

%initiate value
initNList()->
    PJoe = spawn(fun()-> runProcess(joe,[],[]) end),
    PSam = spawn(fun()-> runProcess(sam,[],[]) end),
    PJack = spawn(fun()-> runProcess(jack,[],[]) end),
    PRad = spawn(fun()-> runProcess(rad,[],[]) end),
    NList = [{joe,PJoe},{sam,PSam},{jack,PJack},{rad,PRad}],
    NList.

nList()->
    PJoe = spawn(fun()-> runProcess(joe,[],[]) end),
    PSam = spawn(fun()-> runProcess(sam,[],[]) end),
    PJack = spawn(fun()-> runProcess(jack,[],[]) end),
    PRad = spawn(fun()-> runProcess(rad,[],[]) end),
    NList = [{joe,PJoe},{sam,PSam}],
    NList.

nListSam()->
    PJack = spawn(fun()-> runProcess(jack,[],[]) end),
    PRad = spawn(fun()-> runProcess(rad,[],[]) end),
    NList = [{jack,PJack},{rad,PRad}],
    NList.

rTable()->
    RTable = [{osama,osama,0},{sam,sam,1},{joe,joe,1},{jack,sam,2},{rad,sam,2}],
    RTable.

rTableSam()->
    RTable = [{sam,sam,0},{osama,osama,1},{jack,jack,1},{rad,rad,1},{osama,joe,2}],
    RTable.


%get the Nth Prime number 
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


getRTables([],RTable)->
    RTable;
getRTables([{Name,Pid}|Tail],RTable)->
    NewRTable = getRTable(Pid,RTable),
    getRTables(Tail,NewRTable).

getRTable(Pid,RTable)->
    Pid!{getRT,self()},
    receive
        {rt,RList}->
            NewRT = addUpdate(RTable,RList)
    end,
    NewRT.
addUpdate(RTable,RList)->
    ok.

lookUpTable(_,[])->
    notFound;
lookUpTable(X,[{D,N,_}|_]) when X == D ->
    N;
lookUpTable(X,[_|Tail]) ->
    lookUpTable(X,Tail).


findNighPid(_,[])->
    notFound;
findNighPid(X,[{D,N}|Tail]) when X == D ->
    N;
findNighPid(X,[_|Tail]) ->
    findNighPid(X,Tail).

runProcess(Name,NList,RTable)->
    receive
        {computeNthPrime,Index,Name,Sender,Hops}->
            Ans = getNthPrime(Index),
            Neigh = lookUpTable(Sender,RTable),
            NPid =  findNighPid(Neigh,NList),
            io:fwrite("the Neigh  is ~p~n", [Neigh] ),
            io:fwrite("the Name  is ~p~n", [Name] ),
            io:fwrite("the NPID  is ~p~n", [NPid] ),
            io:fwrite("the Number  is ~p~n", [getNthPrime(Index)] ),
            NPid!{receiveAnswer, Ans,Index,Name,Sender,0},
            runProcess(Name,NList,RTable);
        {computeNthPrime,_,_,_,15}->
            runProcess(Name,NList,RTable);
        {computeNthPrime,Index,Dist,Sender,Hops}->
            Neigh = lookUpTable(Dist,RTable),
            NPid =  findNighPid(Neigh,NList),
            io:fwrite("twoooo the Neigh  is ~p~n", [Neigh] ),
            io:fwrite("the Dist  is ~p~n", [Dist] ),
            io:fwrite("the NPID  is ~p~n", [NPid] ),
            io:fwrite("the Number  is ~p~n", [getNthPrime(Index)] ),
            NPid!{computeNthPrime,Index,Dist,Sender,Hops},
            runProcess(Name,NList,RTable);
        {iniNList,NewNList}->
            NRTable = getRTables(NewNList,RTable),
            runProcess(Name,NewNList,NRTable);
        {getRT,Sender}->
            Sender!{ok}, 
            runProcess(Name,NList,RTable);
        {prime,Sender,Index} ->
            io:format("the prime number requested : ~p ~n" , [Index]),
            io:format("the answerd is : ~p ~n" , [getNthPrime(Index)]),
	        Sender!{project,getNthPrime(Index)},
            runProcess(Name,NList,RTable);
        {num,Num}->
            io:fwrite("the number is ~p~n", [Num] ),
            runProcess(Name,NList,RTable)
end,
ok.


%main
start()->
    %Nl = nList(),
    %NLS = nListSam(),
    %RT = rTable(),
    %RTS = rTableSam().
    work.
     %[{Name,PID}|Tail]=Nl,
    %RTable = [{osama,osama,0},{sam,sam,1},{jack,sam,2},{rad,sam,2}],
    %PID1 = spawn(fun()-> ca:runProcess(osama,Nl,RT) end),
    %PID1 ! {prime,PID1,5}.

% PIDO = spawn(fun()-> ca:runProcess(osama,LS,RT) end)
% PIDS = spawn(fun()-> ca:runProcess(sam,LS,RT) end)
    