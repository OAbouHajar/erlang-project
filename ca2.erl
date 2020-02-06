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

initNList(Name)->
    NList = [],
    NList.

nListOsama()->
    PJoe = spawn(fun()-> loop(joe,[],[]) end),
    NList = [{joe,PJoe},{sam,xxx}],
    NList.

rTableOsama()->
    RTable = [{osama,osama,0},{sam,sam,1},{joe,joe,1},{jack,sam,2},{rad,sam,2}],
    RTable.

nListSam()->
    PJack = spawn(fun()-> loop(jack,[],[]) end),
    PRad = spawn(fun()-> loop(rad,[],[]) end),

    NList = [{jack,PJack},{rad,PRad},{osama,xxx}],
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
    [{Name,PID}|Tail];
updateNL(Name,[Head|Tail],PID)->
    [Head|updateNL(Name,Tail,PID)].
    



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          Project Main section              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


hello(N)->
    self() ! {sendHello,N}.

%% start the project and return the process ID started
uNL(Name,RTable,NList)->
    PID = spawn(fun()->loop(Name,RTable,NList) end),
    NewNL = updateNL(Name,NList,PID),
    %uNL(Name,RTable,NList,PID, NewNL),
    PID.


start(PName)->
    RT = ca2:rTableOsama(),
    PID = spawn(fun()->ca2:loop(PName,RT,[]) end),
    PID ! {updateNL,PName,PID},
    PID.


loop(Name,RTable,NList)->
    receive
        {updateNL,SenderName,PID} ->
            NewNL = updateNL(SenderName,NList,PID),
            io:fwrite(" *********** Update the neighbours List by : ~p~n", [SenderName]),
            io:fwrite(" >>>>>>>  the NEW neighbours List  is ~p~n ", [NewNL] ),
                loop(Name,RTable,NewNL);
        {receiveAnswer,Ans,Index,DistNname,Sender}->
            io:fwrite("the Ans  is ~p~n", [Ans] ),
            io:fwrite("the Index  is ~p~n", [Index] ),
            io:fwrite("the DistNname  is ~p~n", [DistNname] ),
            io:fwrite("the Sender  is ~p~n", [Sender] ),
                loop(Name,NList,RTable);
        {computeNthPrime,_,_,_,15}->
                loop(Name,NList,RTable);
        {computeNthPrime,Index,Dist,Sender,Hops}->
            Ans = getNthPrime(Index),
            Neigh = lookUpTable(Dist,RTable),
            NPid =  findNighPid(Neigh,NList),
            NPid!{receiveAnswer,Ans,Index,Dist,Sender},
                loop(Name,NList,RTable);
        {sendHello,DistNname}->
            NPid =  findNighPid(DistNname,NList),
            self()! io:fwrite("Hello Sent To  ~p~n", [DistNname]),
            NPid ! {helloMsg, Name},
                loop(Name,RTable,NList);
        {helloMsg, SenderName}->
            io:fwrite("Hello From  ~p~n", [SenderName]),
                loop(Name,RTable,NList)
end.





%%%%%%%%%%%%%%%%%%%%%%%%% TSETING 
% ****      start the processes ********

%         c(ca2). PID = ca2:start(osama). register(otest,PID).
%         c(ca2). PID = ca2:start(sam). register(stest,PID).
% 
%       ******************* send NL to each others ***********
%       {stest,sam@osama}!{updateNL,osama,PID}. 
%       {otest,osama@osama}!{updateNL,sam,PID}.

%       {stest,sam@osama}!{computeNthPrime,5,sam,osama,1}. 



% c(ca2). RT = ca2:rTableOsama(). LN =ca2:nListOsama(). PID = spawn(fun()->ca2:loop(osama,RT,LN) end). register(otest ,PID).  ca2:uNNL(osama,RT,LN,PID).

%{sam,sam@osama}!{updateNL,osama,RT,LN,self(),xxx}.
% otest ! {updateNL,osama,RT,LN,PID}.

%  {stest,sam@osama}!{updateNL,osama,PID}. 

%  {stest,sam@osama}!{computeNthPrime,5,sam,osama,1}. 

% c(ca2). RT = ca2:rTableSam(). LN =ca2:nListSam(). PIDS = spawn(fun()->ca2:loop(sam,RT,LN) end). register(stest,PIDS). {osama,osama@osama}!{updateNL,sam,RTS,LNS,self(),xxx}.
% {otest,osama@osama}!{updateNL,sam,PIDS}.

