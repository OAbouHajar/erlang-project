%%%-------------------------------------------------------------------
%%% @author Joseph <joseph@joseph-Inspiron-13-5378>
%%% @copyright (C) 2018, Joseph
%%% @doc
%%%
%%% @end
%%% Created :  9 Apr 2018 by Joseph <joseph@joseph-Inspiron-13-5378>
%%%-------------------------------------------------------------------
-module(examples).

-export([count/1,complexCount/1,split/1,sum/1,append/2,joe/0,member/2,
         delete/2,binarySearch/2,quicksort/1,factorial/1,ping/0,pong/0]).

%this is a comment!
count([])->
    0;
count([_|Tail]) ->
    1+count(Tail).
sum([])->
    0;
sum([H|T]) ->
    H+sum(T).
member(_,[])->
    false;
member(X,[X|Tail]) ->
    true;
member(X,[Head|Tail]) ->
    member(X,Tail).

complexCount([])->
    0;
complexCount([[]|Tail]) ->
    complexCount(Tail);
complexCount([[Head|Tail]|Rest]) ->
    complexCount([Head|Tail])+complexCount(Rest);
complexCount([_|Tail]) ->
    1+complexCount(Tail);
complexCount(_)->
    0.

%sum([])->
%    0;
%sum([H|T]) ->
%    H+sum(T).
%member(_,[])->
%    false;
%member(X,[X|_]) ->
%    true;
%member(X,[_|T]) ->
%    member(X,T).

delete(_,[])->
    [];
delete(X,[X|T]) ->
    T;
delete(X,[H|T]) ->
    [H|delete(X,T)].


binarySearch(_,[])->
    false;
binarySearch(X,List) ->
    {Left,Mid,Right}=split(List),
    if
	Mid<X ->
	    binarySearch(X,Left);
	Mid>X ->
	    binarySearch(X,Right);
	Mid==X -> true
    end.

qsort([])->
    [];
qsort([Head|Tail]) ->
    [X||X<-Tail,
	X =< Head]++
    [Head]++
    [X||X<-Tail,
	    X > Head].

quicksort([])->[];
quicksort([X])->
    [X];
quicksort([X,Y])when X<Y ->[X,Y];
quicksort([X,Y]) ->[Y,X];
quicksort([Head|Tail]) ->
    {Lower,Higher}=pivotSplit(Tail,Head,[],[]),
    quicksort(Lower)++[Head]++quicksort(Higher).

pivotSplit([],_,L,H)->
    {L,H};
pivotSplit([Head|Tail],Pivot,L,H)when Head<Pivot->
    pivotSplit(Tail,Pivot,[Head|L],H);
pivotSplit([Head|Tail],Pivot,L,H) ->
    pivotSplit(Tail,Pivot,L,[Head|H]).



split(List)->
    Length=count(List),
    split(List,Length div 2).

split(List,N)->
    splitAcc(List,N,[]).

splitAcc([Mid|Right],0,Left)->
    {Left,Mid,Right};
splitAcc([H|T],N,Acc) ->
    splitAcc(T,N-1,append(H,Acc)).

append(X,[])->
    [X];
append(X,[H|T]) ->
    [H|append(X,T)].


%for(Start,End,Function)
%for(1,4,pfft())==
%pfft(1),pfft(2),pfft(3),pfft(4)
for(X,X,Fun)->
    [Fun(X)];
for(Start,End,Fun) ->
    [Fun(Start)|for(Start+1,End,Fun)].

%map(Fun,List)
map(Fun,[])->
    [];
map(Fun,[Head|Tail]) ->
    [Fun(Head)|map(Fun,Tail)].

map2(Fun,List)->
    [Fun(H) || H<-List].

perms([])->
    [];
perms(List) ->
    [[H|T] || H<-List,
	      T<-perms(List--[H])].


filter(Filter,[])->
    [];


filter(Filter,[Head|Tail]) ->
    X=Filter(Head),
    if
	X==true ->
	    [Head|filter(Filter,Tail)];
	true ->
	    filter(Filter,Tail)
    end.




joe()->
    receive
	{Pid,X}   ->
	    Y=X*X,
	    io:format("the square is: ~p~n",[Y]),
	    Pid!{self(),Y};
	{Pid,X,Y} -> 
	    Pid!{tooManyArgs,[X,Y]};
	_         -> 
	    flush()
    end,
    joe().

ping()->
    receive
	{SenderID,ping}->
	      SenderID!{self(),pong},
	      io:format("pinged...\n"),
	      ping();
	_ ->
	      ping()
end.
pong()->
    receive
	{PiD,pong}->
	    PiD!{self(),ping},
	      io:format("ponged...\n"),
	    pong();
	_ ->
	    pong()
end.


%X=spawn(fun examples:joe/0),
%Y=spawn(fun()->
%		dostuff(a,s,d,h) end).

%X!{self(),7}


%% Rpc= fun(Pid,Request)->
%%     Pid!{self(),Request},
%%     receive
%% 	{Pid,Answer}->
%% 	    Answer;
%% 	end.
    
sleep(Time)->
    receive
after Time->
	true
end.

flush()->
    receive
	_->
	    flush()%;
	%after 0 ->
	%	true
end.

factorial(0) -> 1;
factorial(1) -> 1;
factorial(N) -> N*factorial(N-1).
