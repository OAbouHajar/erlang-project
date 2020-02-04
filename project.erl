-module(project).
-export([start/2 , store/2, lookup/1, prime/1, sendTo/2, 
hasNoDivisor/2,isPrime/1, nList/0,
getNthPrime/1,getNextPrime/1, routTable/0,routTableKey/1,routTableHops/1 ,
update/2,findN/2,updateRT/3,addIfBetter/3,senderName/1,urT/3,cNP/4
,rTable/0,nListSam/0 ,rTableSam/0,initNList/0,computeNthPrime/4 ]).




%Mine to get the prime
prime(Pr)->
    rpc({prime,Pr}).

getPrime(Pr)->
    io:format("the prime is : ~p \n",[lists:nth(Pr, [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97])]).
 

%Joe code for getting the prime number
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


 %update the table 
update(X,[])->
    [X];
update({Dest,N,Hops},[{Dest,Q,R}|TAIL])->
    [{Dest,N,Hops}|TAIL];
update({Dest,N,Hops},[X|TAIL])->
    NewTAIL = update({Dest,N,Hops},TAIL),
    [X|NewTAIL].


    
%findN(Dest,RList)->
findN(Dest,[])-> 
    not_ok ;
findN(Dest,[{Dest,N,_}|TAIL])->
    N;
findN(Dest,[H|T])->
    findN(Dest,T).

%updateRT(RTable, NRTable , Sender) -> 
urT(RTable, NRT, Send)->
    rpc({urT,RTable,NRT,Send}).
updateRT(RTable, [] , Sender)->
    RTable;
updateRT(RTable, [H|T] , Sender)->
    RT2 = addIfBetter(RTable,H,Sender),
    updateRT(RT2,T,Sender).



addIfBetter([],NewEntry,_)->
    [NewEntry];
addIfBetter([{D,N,Hops}|TAIL],{D,N2,H2},S)->
    case ( Hops > H2 ) of
    true ->
            [{D,S,H2}|TAIL];
    false -> 
            [{D,N,Hops}|TAIL]
    end;
addIfBetter([H|T],N,S)->
    [H|addIfBetter(T,N,S)].



%find the distnation for the nickname
routTable() ->
    RTable = [{osama,c00220135,0},{colnth,c00220111,1},{brenden,c00220222,1},{holly,joe@osama,2},{martin,c00220444,3}],
    [RTable].

routTableKey(Dist) ->
    RtableD = [{osama,c00220135,0},{colnth,c00220111,1},{brenden,c00220222,1},{holly,joe@osama,2},{martin,c00220444,3}],
    routTableKey(Dist,RtableD).

routTableKey(_,[])->
    notFound;
routTableKey(X,[{D,N,_}|_]) when X == D ->
    N;
routTableKey(X,[_|Tail]) ->
    routTableKey(X,Tail).

%get the hpos 
routTableHops(Dist) ->
    RtableD = [{osama,c00220135,0},{colnth,c00220111,1},{brenden,c00220222,1},{holly,sam@osama,2},{martin,c00220444,3}],
    routTableHops(Dist,RtableD).

routTableHops(_,[])->
    notFound;
routTableHops(X,[{D,N,H}|_]) when X == D ->
    H;
routTableHops(X,[_|Tail]) ->
    routTableHops(X,Tail).


%project call
cNP(N,DistNname,SenderNname,Hops)->
    rpc({cNP,N,DistNname,SenderNname,Hops}).

computeNthPrime(N,DistNname,SenderNname,Hops)->
    rpc({computeNthPrime,N,DistNname,SenderNname,Hops}).

%sender details
senderName(From)->
    io:format("the sender : ~p " , From ," send a prime request  ~p \n" ).

%to send to the table key
sendTo(Key,Pr)->
    rpc({sendTo,Key,Pr}).

store(Key,Value)->
    rpc({store,Key,Value}).

lookup(Key)->
    rpc({lookup,Key}).




%joe code old one
start(RTable,NList)->
    register(project, spawn(fun()->loop(RTable,NList) end)).


initNList()->
    PJoe = spawn(fun()-> loop([],[]) end),
    PSam = spawn(fun()-> loop([],[]) end),
    PJack = spawn(fun()-> loop([],[]) end),
    PRad = spawn(fun()-> loop([],[]) end),
    NList = [{joe,PJoe},{sam,PSam},{jack,PJack},{rad,PRad}],
    NList.

nList()->
    PJoe = spawn(fun()-> loop([],[]) end),
    PSam = spawn(fun()-> loop([],[]) end),
    NList = [{joe,PJoe},{sam,PSam}],
    NList.

rTable()->
    RTable = [{osama,osama,0},{sam,sam,1},{joe,joe,1},{jack,sam,2},{rad,sam,2}],
    RTable.

nListSam()->
    PJack = spawn(fun()-> loop([],[]) end),
    PRad = spawn(fun()-> loop([],[]) end),
    POsama = spawn(fun()-> loop([],[]) end),

    NList = [{jack,PJack},{rad,PRad},{osama,POsama}],
    NList.

rTableSam()->
    RTable = [{sam,sam,0},{osama,osama,1},{jack,jack,1},{rad,rad,1},{joe,osama,2}],
    RTable.


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


rpc(Query)->
    project!{self(), Query},
    receive
	{project,Reply}->
	    Reply
    end.
    
loop(RTable,NList)->
    receive
	{From, {store,Key,Value}}->
	    put(Key,Value),
	    From!{project,true},
	    loop(RTable,NList);
	{From,{lookup,Key}} ->
	    From!{project, get(Key)},
	    loop(RTable,NList);
    {From,{urT,N,NW,S}} ->
        io:format("the sender : ~p ~n" , [S]),
        io:format("the old Table : ~p ~n" , [N]),
        io:format("the sender table : ~p ~n" , [NW]),
        From!{project,updateRT(N,NW,S)},
        loop(RTable,NList);
    {From, {prime,Pr}} ->
        io:format("the sender : ~p ~n" , [From]),
        io:format("the prime number requested : ~p ~n" , [Pr]),
        io:format("the answerd is : ~p ~n" , [getNthPrime(Pr)]),
	    From!{project,getNthPrime(Pr)},
        loop(RTable,NList);
    {From, {cNP,N,DistNname,SenderNname,Hops}} ->
        io:format("the N Number request     : ~p ~n" , [N]),
        io:format("the Distnation Nickname  : ~p ~n" , [routTableKey(DistNname)]),
        io:format("the sender Nickname      : ~p ~n" , [routTableKey(SenderNname)]),
        io:format("the Number returned      : ~p ~n" , [getNthPrime(N)]),
        io:format("the Hops                 : ~p ~n" , [Hops]),
	    From!{project,[N,getNthPrime(N),routTableKey(DistNname),routTableKey(SenderNname),Hops]},
            loop(RTable,NList);
        {From, {computeNthPrime,N,DistNname,SenderNname,Hops}} ->
            Ans = getNthPrime(N),
            Neigh = lookUpTable(SenderNname,RTable),
            NPid =  findNighPid(Neigh,NList),
            io:fwrite("the Neigh  is ~p~n", [Neigh] ),
            io:fwrite("the Name  is ~p~n", [DistNname] ),
            io:fwrite("the NPID  is ~p~n", [NPid] ),
            From!{project,[N,Ans,DistNname,SenderNname,Hops]},
            NPid!{project,[N,Ans,DistNname,SenderNname,Hops]},
                loop(RTable,NList)
end.

%  c(project). RT = project:rTable(). LN =project:nList(). project:start(RT,LN).
%  c(project). RTS = project:rTableSam(). LNS =project:nListSam().   project:start(RTS,LNS).
%   
%  rpc:call(joe@osama,project,computeNthPrime,[5,osama,sam,2]).
