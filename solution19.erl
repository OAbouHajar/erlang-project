%%% @author Joseph Kehoe <joseph@itcarlow.ie>
%%% @copyright (C) 2019, Joseph Kehoe
%%% @doc
%%% Solution for a simple expression parser
%%% 
%%% @end
%%% Created : 28 May 2019 by Joseph <joseph@joseph-OptiPlex-5050>

-module(solution19).
-export([tokeniser/1,getNum/1,parser/1,evalTree/1,doAll/1]).
-include_lib("eunit/include/eunit.hrl").


% tokeniser takes in a string and returns a list of tokens.
% Each token is a pair (tuple) containing the type of token and its value
% Allowed types are:
% * Braces - left or right brackets
% * Numbers - integers
% * Binary operators (+,-,/,*)
% * Unary Operator minus (represented using a tilda ~ to make parsing easier)
% All other characters are ignored (see final clause)
% e.g. "(123+2)" --> [{brace,left},{num,123},{binOp,plus},{num,2},{brace,right}]
tokeniser([])->
    [];
tokeniser([$(|Tail]) ->
    [{brace,left}|tokeniser(Tail)];
tokeniser([$)|Tail]) ->
    [{brace,right}|tokeniser(Tail)];
tokeniser([$+|Tail]) ->
    [{binOp,plus}|tokeniser(Tail)];
tokeniser([$-|Tail]) ->
    [{binOp,sub}|tokeniser(Tail)];
tokeniser([$*|Tail]) ->
    [{binOp,mult}|tokeniser(Tail)];
tokeniser([$/|Tail]) ->
    [{binOp,divide}|tokeniser(Tail)];
tokeniser([$~|Tail]) ->
    [{unOp,minus}|tokeniser(Tail)];
tokeniser([Digit|Tail]) when Digit>=$0,Digit=<$9->
    {Num,Rest}=getNum([Digit|Tail]),
    [{num,Num}|tokeniser(Rest)];
%last clause to ignore all other characters
tokeniser([_|Tail])->
    tokeniser(Tail).


% getNum/1 pulls a sequence of digits from the front of a list and turns it into an integer
% It does this by calling getNum/2 to do the work
% getNum/2 has a second argument which contains the total of all the digits so far
% Initially we pass in a value of 0 to this argument
% It returns the integer and the remainder of the list
% e.g. "123+2)" --> {123, "+2)"}
getNum([],Total)->
    {Total,[]};
getNum([Digit|Rest],SumSoFar) when Digit>=$0,Digit=<$9->
    DigitAsNum=Digit-$0,
    NewSumSoFar=SumSoFar*10+DigitAsNum,
    getNum(Rest,NewSumSoFar);
getNum(List,SumSoFar) ->
    {SumSoFar,List}.

getNum(List)->
    getNum(List,0).

%Parser starts parsing the list of tokens into a syntax tree for evaluation
% Returns a tuple containing the tree and the rest of the list it did not parse
% Once complete the entire list should be turned into a tree and
% it should return a tree and an empty list (i.e. nothing is left over)
% we ensure this by calling it as follows {Tree,[]}=parser(TokenList)
% In other words if when we finish there are bits left over in the token list 
% then we done something wrong!
%Basic Grammar rules are:
% PARSER --> Number | '(', EXPR, ')' | '~', PARSER
% EXPR --> Number, binOp, PARSER |'~', PARSER | PARSER, BinOp, PARSER
% 
%e.g.[{brace,left},{num,123},{binOp,plus},{num,2},{brace,right}] --> {plus,123,2} 
parser([{num,Value}|Rest])->
    {Value,Rest};
parser([{brace,left}|Rest]) ->
    {Tree,[{brace,right}|Remainder]}=getExpression(Rest),
    {Tree,Remainder};
parser([{unOp,Op}|Rest]) ->
    {Expression,Remainder}=parser(Rest),
    {{Op,Expression},Remainder}.

getExpression([{num,Value},{binOp,Op}|Rest])->
    {Expression,Remainder}=parser(Rest),
    {{Op,Value,Expression},Remainder};
getExpression([{unOp,Op}|Rest]) ->
    {Expression,Remainder}=parser(Rest),
    {{Op,Expression},Remainder};
getExpression(TokenList) ->
     {LeftExpression,[{binOp,Op}|Remainder]}=parser(TokenList),
     {RightExpression,LeftOvers}=parser(Remainder),
     {{Op,LeftExpression,RightExpression},LeftOvers}.


%evalTree just computes the answer
% This is the easy part
% e.g. {plus,123,2} --> 125
evalTree({minus,Expr})->
    Ans=evalTree(Expr),
    -Ans;
evalTree({plus,LeftExpr,RightExpr}) ->
    Left=evalTree(LeftExpr),
    Right=evalTree(RightExpr),
    Left+Right;
evalTree({sub,LeftExpr,RightExpr}) ->
    Left=evalTree(LeftExpr),
    Right=evalTree(RightExpr),
    Left-Right;
evalTree({mult,LeftExpr,RightExpr}) ->
    Left=evalTree(LeftExpr),
    Right=evalTree(RightExpr),
    Left*Right;
evalTree({divide,LeftExpr,RightExpr}) ->
    Left=evalTree(LeftExpr),
    Right=evalTree(RightExpr),
    Left/Right;
evalTree(Value) -> Value.

%Put everything together
doAll(Input)->
    TokenList=tokeniser(Input),
    {SyntaxTree,[]}=parser(TokenList),
    Answer=evalTree(SyntaxTree),
    Answer.

first_test()->
    2=doAll("(1+1)").
second_test()->
    1=doAll("((2+3)-4)").
third_test()->
   -9=doAll("(1-(2*(6-1)))").
fourth_test()->
   0.25=doAll("(1/4)").
fifth_test()->
   -24=doAll("~(4*6)").
sixth_test()->
    -24=doAll("((~4)*6)").
sneaky1_test()->
    0=doAll("0").
sneaky2_test()->
    0=doAll(" (1 - 1)  ").
sneaky3_test()->
    -2=doAll("(1+(~(1+2)))").
