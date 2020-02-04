%%%-------------------------------------------------------------------
%%% @author Osama Abouhajar <osama@osama>
%%% @copyright (C) 2020, Osama Abouhajar
%%% @doc
%%%
%%% @end
%%% Created : 03 Feb 2020 by Osama Abouhajar <osama@osama>
%%%-------------------------------------------------------------------


-module(ca2).
-compile(export_all).




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          Project init values section      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

initNList()->
    PJoe = spawn(fun()-> loop(joe,[],[]) end),
    PJack = spawn(fun()-> loop(jack,[],[]) end),
    PRad = spawn(fun()-> loop(rad,[],[]) end),
    NList = [{osama,xx},{joe,PJoe},{jack,PJack},{rad,PRad}],
    NList.

nListOsama()->
    PJoe = spawn(fun()-> loop(joe,[],[]) end),
    PSam = spawn(fun()-> loop(sam,[],[]) end),
    NList = [{osama,xxx},{joe,PJoe},{sam,PSam}],
    NList.

rTableOsama()->
    RTable = [{osama,osama,0},{sam,sam,1},{joe,joe,1},{jack,sam,2},{rad,sam,2}],
    RTable.

nListSam()->
    PJack = spawn(fun()-> loop(jack,[],[]) end),
    PRad = spawn(fun()-> loop(rad,[],[]) end),
    POsama = spawn(fun()-> loop(osama,[],[]) end),

    NList = [{sam,xx},{jack,PJack},{rad,PRad},{osama,POsama}],
    NList.

rTableSam()->
    RTable = [{sam,sam,0},{osama,osama,1},{jack,jack,1},{rad,rad,1},{joe,osama,2}],
    RTable.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    Getting the Prime number section      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          Route Table section             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %********************         Update the Route Table              ***************%
updateRT(RTable, [] , _)->
    RTable;
updateRT(RTable, [H|T] , Sender)->
    RT2 = addIfBetter(RTable,H,Sender),
    updateRT(RT2,T,Sender).

addIfBetter([],NewEntry,_)->
    [NewEntry];
addIfBetter([{D,N,Hops}|TAIL],{D,_,H2},S)->
    case ( Hops > H2 ) of
    true ->
            [{D,S,H2}|TAIL];
    false -> 
            [{D,N,Hops}|TAIL]
    end;
addIfBetter([H|T],N,S)->
    [H|addIfBetter(T,N,S)].


        %********************         Search in the Route Table              ***************%
lookUpTable(_,[])->
    notFound;
lookUpTable(X,[{D,N,_}|_]) when X == D ->
    N;
lookUpTable(X,[_|Tail]) ->
    lookUpTable(X,Tail).
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          neighbours List section         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %********************         Update neighbours List               ***************%





        %********************         Find neighbours PID               ***************%
findNighPid(_,[])->
    notFound;
findNighPid(X,[{D,N}|_]) when X == D ->
    N;
findNighPid(X,[_|Tail]) ->
    findNighPid(X,Tail).

updateNL(Name,[],PID)->
    [{Name,PID}];
updateNL(Name,[{Name,_}|Tail],PID)->
    PID ! [{Name,PID}|Tail];
updateNL(Name,[Head|Tail],PID)->
    [Head|updateRT(Name,Tail,PID)].
    
uNNL (Name,RTable,NList,PID)->
    PID! {updateNL,Name,RTable,NList,PID}.




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          Project RPC section              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %********************         RPC CALLS               ***************%
computeNthPrime(N,DistNname,SenderNname,Hops)->
    rpc({computeNthPrime,N,DistNname,SenderNname,Hops}).
    



        %********************         RPC Function               ***************%
rpc(Query)->
    ca2!{self(), Query},
    receive
	{ca2,Reply}->
	    Reply
    end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          Project Main section              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% start the project and return the process ID started
uNL(Name,RTable,NList)->
    PID = spawn(fun()->loop(Name,RTable,NList) end),
    NewNL = updateNL(Name,NList,PID),
    %uNL(Name,RTable,NList,PID, NewNL),
    PID.


start()->
    peojectStarted.


loop(Name,RTable,NList)->
    receive
        {updateNL,Name,RTable,NList,PID} ->
            NewNL = updateNL(Name,NList,PID),
            io:fwrite("the Mine PID  is ~p~n", [PID] ),
            io:fwrite("the NEW LN  is ~p~n", [NewNL] ),
            PID! {updateNL,Name,RTable,NList},
                loop(Name,RTable,NewNL);
        {From, {computeNthPrime,N,DistNname,SenderNname,Hops}} ->
            Ans = getNthPrime(N),
            Neigh = lookUpTable(DistNname,RTable),
            NPid =  findNighPid(Neigh,NList),
            io:fwrite("the Neigh  is ~p~n", [Neigh] ),
            io:fwrite("the Name  is ~p~n", [DistNname] ),
            io:fwrite("the NPID  is ~p~n", [NPid] ),
            From!{ca2,[N,Ans,DistNname,SenderNname,Hops]},
            NPid!{ca2,[N,Ans,DistNname,SenderNname,Hops]},
                loop(Name,RTable,NList)
end.













%  c(ca2). RT = ca2:rTableOsama(). LN =ca2:nListOsama(). ca2:uNL(osama,RT,LN).
%  c(ca2). RTS = ca2:rTableSam(). LNS =ca2:nListSam().   ca2:uNL(sam,RTS,LNS).
%   
%      PID = spawn(fun()-> ca2:uNL(osama,RT,LN) end),

%  rpc:call(joe@osama,ca2,computeNthPrime,[5,osama,sam,2]).

%  {project,sam@osama}!{project, self()}.




%%%%%%%%%%%%%%%%%%%%%%%%% TSETING 

% c(ca2). RT = ca2:rTableOsama(). LN =ca2:nListOsama(). PID = spawn(fun()->ca2:loop(osama,RT,LN) end). register(osama,PID).  ca2:uNNL(osama,RT,LN,PID).

%{sam,sam@osama}!{updateNL,osama,RT,LN,self(),xxx}.

% register(osama,PID).

% c(ca2). RTS = ca2:rTableSam(). LNS =ca2:nListSam(). PID = spawn(fun()->ca2:loop(sam,RTS,LNS) end). register(sam,PID). {osama,osama@osama}!{updateNL,sam,RTS,LNS,self(),xxx}.


