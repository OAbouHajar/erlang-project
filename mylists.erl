%%%-------------------------------------------------------------------
%%% @author Joseph Kehoe <joseph@joseph-Inspiron-13-5378>
%%% @copyright (C) 2019, Joseph Kehoe
%%% @doc
%%%
%%% @end
%%% Created :  2 Dec 2019 by Joseph Kehoe <joseph@joseph-Inspiron-13-5378>
%%%-------------------------------------------------------------------
-module(mylists).
-author('joseph@joseph-Inspiron-13-5378').
-export([sum/1,prod/1,joemember/2,del/2,append/2,insert/2,zipper/2]).

zipper([],[])->
    [];
zipper([Shep|Rest],[Rover|Tail]) ->
[{Shep,Rover}|zipper(Rest,Tail)].


sum([])->
    0;
sum([X|List]) ->
    X+sum(List).

prod([])->
    1;
prod([X|Tail]) ->
    X*prod(Tail).

% member(Element,List) returns true if Element is in List otherwise false
joemember(_,[])->
    false;
joemember(X,[X|_]) ->
    true;
joemember(X,[_|Tail]) ->
    joemember(X,Tail).

%del(X,List) returns List with X removed!

del(_,[])->
    [];
del(X,[X|Tail]) ->
    Tail;
del(X,[Y|Tail]) ->
    [Y|del(X,Tail)].

insert(X,List)->
    [X|List].

%append(X,List) returns a new list where X is the first element and List is the rest
append(X,[])->
    [X];
append(X, [First|Rest]) ->
    [First|append(X,Rest)].











