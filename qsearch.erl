-module(qsearch).
-export([score/2]).

score(S, A) ->
  if 
    (length(A) > length(S)) -> 0;
    true -> scan(S, A, "")
  end.
  
scan(_, "", _) ->
  0.9;
scan(S, A, "") ->
  case regexp:match(S, A) of
    {match,Index,_} ->
      (subtract_score(S, Index, Index + length(A)) + 0.9 * length(A)) / length(S);
    nomatch ->
      scan(S, string:left(A, length(A) - 1), string:right(A, 1));
    {error,Why} ->
      Why
  end;
scan(S, A, Next) ->
  case regexp:match(S, A) of
    {match,Index,_} ->
      New = score(string:substr(S, Index + length(A)), Next),
      Score = subtract_score(S, Index, Index + length(A)),
      (Score + New * (length(S) - Index + 1 - length(A))) / length(S);
    nomatch ->
      scan(S, string:left(A, length(A) - 1), string:right(A, 1) ++ Next);
    {error,Why} ->
      Why
  end.
  
subtract_score("", _, Score) ->
  Score;
subtract_score(_, 1, Score) ->
  Score - 1;
subtract_score(S, Index, Score) ->
  Substring = string:substr(S, 1, (Index - 1)),
  case lists:last(Substring) of
    9 -> Score - (add_characters(Substring));
    32 -> Score - (add_characters(Substring));
    _ -> Score - Index
  end.

add_characters(Substring) ->
  lists:sum([is_space(C) || C <- Substring]).

is_space(C) ->
  case C of
    9 -> 1;
    32 -> 1;
    _ -> 0.15
  end.