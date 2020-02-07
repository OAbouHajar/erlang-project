%%%-------------------------------------------------------------------
%%% @author Osama Abouhajar <osama@osama>
%%% @copyright (C) 2020, Osama Abouhajar
%%% @doc
%%%
%%% @end
%%% Created : 03 Feb 2020 by Osama Abouhajar <osama@osama>
%%%-------------------------------------------------------------------



%***************************** Project node map Structure

%                       rad                      joe
%                       *                       *
%                       *                     *
%                       *                   *
%        jack  ******  sam ************ osama
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%***********************************  TSETING steps

%%%%%%%%    Strting two shell sam and osama
%           1-          erl -sname osama
%           2-          erl -sname sam


%%%%%%%%    Start the processes and register them as (otest, stest)  *******
%           3- run the below line on the shells as decriped
%           osama >     c(ca2). PID = ca2:start(osama). register(otest,PID).
%           sam >       c(ca2). PID = ca2:start(sam). register(stest,PID).



%%%%%%%%    4- Send neighbours List to each others 
%           osama >     {stest,sam@osama}!{updateNL,osama,PID}. 
%           sam >       {otest,osama@osama}!{updateNL,sam,PID}.


%%%%%%%%    Send compute Msg to from (osama -> sam) to get the Nth prim to (sam) distination
%           osama >     {stest,sam@osama}!{computeNthPrime,5,sam,osama,1}. 


%% ******   check sam shell to see the results



 %%%%%% to test the update Route Table msg

%        osama >        RTable = [{osama,osama,0},{sam,sam,1},{joe,joe,1},{jack,sam,2},{rad,sam,2}].
%        osama >        NewRTable = [{sam,sam,0},{osama,osama,1},{jack,jack,1},{rad,rad,1},{joe,osama,2}].
%        osama >        {stest,sam@osama}!{updateRT,RTable,NewRTable,osama}. 


%%%%%%%%%%%%% DONE %%%%%%%%%%%%


-module(ca2).
-compile(export_all).




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          Project init values section      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% ****************** two process will be created for testing
initOsama()->
    RTable = [{osama,osama,0},{sam,sam,1},{joe,joe,1},{jack,sam,2},{rad,sam,2}],
    PID = spawn(fun()->ca2:loop(osama,RTable,[]) end),
    PID ! {updateNL,osama,PID},
    PID.

initSam()->
    RTable = [{sam,sam,0},{osama,osama,1},{jack,jack,1},{rad,rad,1},{joe,osama,2}],
    PID = spawn(fun()->ca2:loop(sam,RTable,[]) end),
    PID ! {updateNL,sam,PID},
    PID.

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
updateNL(Name,[],PID)->
    [{Name,PID}];
updateNL(Name,[{Name,_}|Tail],PID)->
    [{Name,PID}|Tail];
updateNL(Name,[Head|Tail],PID)->
    [Head|updateNL(Name,Tail,PID)].

        %********************         Find neighbours PID               ***************%
findNighPid(_,[])->
    notFound;
findNighPid(X,[{D,N}|_]) when X == D ->
    N;
findNighPid(X,[_|Tail]) ->
    findNighPid(X,Tail).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          Project Main section              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hello(N)->
    self() ! {sendHello,N}.


start(PName)->
case PName of
    osama ->
        PID  = ca2:initOsama();
    sam -> 
        PID  = ca2:initSam();
    _ -> 
        PID  = spawn(fun()->ca2:loop(PName,[],[]) end),
        PID ! {updateNL,PName,PID}
    end,
    PID.

loop(Name,RTable,NList)->
    receive
        {updateNL,SenderName,PID} ->
            NewNL = updateNL(SenderName,NList,PID),
            io:fwrite(" *********** Update the neighbours List by : ~p~n", [SenderName]),
            io:fwrite(" >>>>>>>  the NEW neighbours List  is ~p~n ", [NewNL] ),
                loop(Name,RTable,NewNL);
        {updateRT,RT,NewRTable,Sender} ->
            NewRT = updateRT(RT,NewRTable,Sender),
            io:fwrite(" *********** Update the Route Table by : ~p~n", [Sender]),
            io:fwrite(" >>>>>>>>>>  The NEW Route Table is    : ~p~n ", [NewRT] ),
                loop(Name,NewRTable,NewRT);
        {receiveAnswer,Ans,Index,DistNname,Sender}->
            io:fwrite("********* message received from ******** ~p~n" , [Sender] ),
            io:fwrite("the Index requested        is ~p~n", [Index] ),
            io:fwrite("the Answer                 is ~p~n", [Ans] ),
            io:fwrite("the destination Nickname   is ~p~n", [DistNname] ),
                loop(Name,NList,RTable);
        {computeNthPrime,_,_,_,15}->
                loop(Name,NList,RTable);
        {computeNthPrime,Index,Dist,Sender,_}->
            Ans = getNthPrime(Index),
            Neigh = lookUpTable(Dist,RTable),
            NPid =  findNighPid(Neigh,NList),
            NPid!{receiveAnswer,Ans,Index,Dist,Sender},
                loop(Name,NList,RTable);
        {getRT,Sender}->
            Pid =  findNighPid(Sender,NList),
            Pid ! RTable,             
                loop(Name,NList,RTable);
        {getNl,Sender}->
            Pid =  findNighPid(Sender,NList),
            Pid ! NList, 
                loop(Name,NList,RTable);    
        {sendHello,DistNname}->
            NPid =  findNighPid(DistNname,NList),
            self()! io:fwrite("Hello Sent for test To  ~p~n", [DistNname]),
            NPid ! {helloMsg, Name},
                loop(Name,RTable,NList);
        {helloMsg, SenderName}->
            io:fwrite("Hello test From  ~p~n", [SenderName]),
                loop(Name,RTable,NList)
end.


%***************************** Project node map Structure

%                       rad                      joe
%                       *                       *
%                       *                     *
%                       *                   *
%        jack  ******  sam ************ osama
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%***********************************  TSETING steps

%%%%%%%%    Strting two shell sam and osama
%           1-          erl -sname osama
%           2-          erl -sname sam


%%%%%%%%    Start the processes and register them as (otest, stest)  *******
%           3- run the below line on the shells as decriped
%           osama >     c(ca2). PID = ca2:start(osama). register(otest,PID).
%           sam >       c(ca2). PID = ca2:start(sam). register(stest,PID).



%%%%%%%%    4- Send neighbours List to each others 
%           osama >     {stest,sam@osama}!{updateNL,osama,PID}. 
%           sam >       {otest,osama@osama}!{updateNL,sam,PID}.


%%%%%%%%    Send compute Msg to from (osama -> sam) to get the Nth prim to (sam) distination
%           osama >     {stest,sam@osama}!{computeNthPrime,5,sam,osama,1}. 


%% ******   check sam shell to see the results



 %%%%%% to test the update Route Table msg

%        osama >        RTable = [{osama,osama,0},{sam,sam,1},{joe,joe,1},{jack,sam,2},{rad,sam,2}].
%        osama >        NewRTable = [{sam,sam,0},{osama,osama,1},{jack,jack,1},{rad,rad,1},{joe,osama,2}].
%        osama >        {stest,sam@osama}!{updateRT,RTable,NewRTable,osama}. 


%%%%%%%%%%%%% DONE %%%%%%%%%%%%