-module(prop_target).
-include_lib("proper/include/proper.hrl").
-compile(export_all).

%%%%%%%%%%%%%%%%%%
%%% Properties %%%
%%%%%%%%%%%%%%%%%%
prop_path(doc) ->
  %% Docs are shown when the property fails
  "create targeted paths";
prop_path(opts) ->
  %% Override CLI and rebar.config option for "search_steps"
  [{search_steps, 100}].
prop_path() ->
  ?FORALL_TARGETED(P, path(),
    begin
      {X, Y} = lists:foldl(fun move/2, {0, 0}, P),
      % What we're minimizing
      Loss = Y - X,
      io:format("Ended at: ~p, length of path: ~w, loss: ~w\n", [{X, Y}, length(P), Loss]),
      % Give feedback to PropEr: Move to lower right, maximizing X and minimizing Y
      ?MAXIMIZE(-Loss),
      true
    end).

prop_tree_regular(opts) -> [{search_steps, 500}].
prop_tree_regular() ->
  ?FORALL_TARGETED(T, tree(),
    begin
      {Left, Right} = Weight = sides(T),
      NegLoss = Left - Right,
      io:format("Tree weight: ~p, negative loss: ~w~n", [Weight, NegLoss]),
      % io:format(" ~p", [Weight]),
      ?MAXIMIZE(NegLoss),
      true
    end).

% With custom neighbor functions, one can guide the search
% USER_NF macro takes a generator and an anonymous function taking current data
% and tuple with temperature and depth (next_tree) below.
prop_tree_neighbor(opts) -> [{search_steps, 500}].
prop_tree_neighbor() ->
  ?FORALL_TARGETED(T, ?USERNF(tree(), next_tree()),
    begin
      {Left, Right} = Weight = sides(T),
      NegLoss = Left - Right,
      io:format("Tree weight: ~p, negative loss: ~w~n", [Weight, NegLoss]),
      ?MAXIMIZE(NegLoss),
      true
    end).

% When custom neighbor functions, the whole search consists of
% variations of the initial data. To get more variation, it may be
% preferable to combine FORALL and NOT_EXISTS macros as follows:
prop_tree_search(opts) -> [{numtests, 10}, {search_steps, 10}].
prop_tree_search() ->
  ?FORALL(L, list(integer()),
    ?NOT_EXISTS(T,
      ?USERNF(
        ?LET(X, L, to_tree(X)),  % Generator of tree from the drawn list
        next_tree()  % Neighbor function
      ),
      begin
        {Left, Right} = Weight = sides(T),
        NegLoss = Left - Right,
        io:format("Tree weight: ~p, negative loss: ~w~n", [Weight, NegLoss]),
        ?MAXIMIZE(NegLoss),
        false
      end)
  ).

% Testing Quicksort without targeting long execution times
prop_quicksort_time_regular(opts) -> [{numtests, 10000}].
prop_quicksort_time_regular() ->
  ?FORALL(L, ?SUCHTHAT(L, list(integer()), length(L) < 100000),
    begin
      T0 = erlang:monotonic_time(millisecond),
      sort(L),
      T1 = erlang:monotonic_time(millisecond),
      collect(to_range(10, length(L)), T1 - T0 < 5)
    end).

% Test quicksort by targeting long execution times.
% Disable shrinking when bad cases are found
prop_quicksort_time(opts) -> [noshrink, {search_steps, 500}].
prop_quicksort_time() ->
  ?FORALL_TARGETED(L, ?SUCHTHAT(L, list(integer()), length(L) < 100000),
    begin
      T0 = erlang:monotonic_time(millisecond),
      sort(L),
      T1 = erlang:monotonic_time(millisecond),
      NegLoss = T1 - T0,
      ?MAXIMIZE(NegLoss),
      T1 - T0 < 5000
    end).

% Test "fixed" quicksort with targeted properties
prop_quicksort_time_fixed(opts) -> [noshrink, {search_steps, 500}].
prop_quicksort_time_fixed() ->
    ?FORALL_TARGETED(L, ?SUCHTHAT(L, list(integer()), length(L) < 100000),
        begin
            T0 = erlang:monotonic_time(millisecond),
            sort_fixed(L),
            T1 = erlang:monotonic_time(millisecond),
            NegLoss = T1 - T0,
            ?MAXIMIZE(NegLoss),
            T1 - T0 < 5000
        end).

%%%%%%%%%%%%%%%
%%% Helpers %%%
%%%%%%%%%%%%%%%
move(left, {X, Y}) -> {X - 1, Y};
move(right, {X, Y}) -> {X + 1, Y};
move(up, {X, Y}) -> {X, Y + 1};
move(down, {X, Y}) -> {X, Y - 1}.

% List of numbers inserted into binary tree
to_tree(L) -> lists:foldl(fun insert/2, undefined, L).

insert(N, {node, N, L, R}) -> {node, N, L, R};
insert(N, {node, M, L, R}) when N < M -> {node, M, insert(N, L), R};
insert(N, {node, M, L, R}) when N > M -> {node, M, L, insert(N, R)};
insert(N, {leaf, N}) -> {leaf, N};
insert(N, {leaf, M}) when N < M -> {node, N, undefined, {leaf, M}};
insert(N, {leaf, M}) when N > M -> {node, N, {leaf, M}, undefined};
insert(N, undefined) -> {leaf, N}.

% Helper for computing how balanced a tree is
sides({node, _, Left, Right}) ->
  {LL, LR} = sides(Left),
  {RL, RR} = sides(Right),
  {count_inner(Left) + LL + LR, count_inner(Right) + RL + RR};
sides(_) -> {0, 0}.

count_inner({node, _, _, _}) -> 1;
count_inner(_) -> 0.

% Insert a drawn integer into the tree, with the value
% scaled by temperature to encourage smaller values
% when search progresses
next_tree() ->
  fun(OldTree, {_, T}) ->
    ?LET(N, integer(), insert(trunc(N * T * 100), OldTree))
  end.

to_range(M, N) ->
  Base = N div M,
  {Base * M, (Base + 1) * M}.

% Quicksort that uses the first element as the pivot
sort([]) -> [];
sort([Pivot | Tail]) ->
  sort([X || X <- Tail, X < Pivot])
  ++ [Pivot] ++
    sort([X || X <- Tail, X >= Pivot]).

sort_fixed([]) -> [];
sort_fixed(L) ->
    N = rand:uniform(length(L)),
    Pivot = lists:nth(N, L),
    sort_fixed([X || X <- L, X < Pivot])
    ++ [X || X <- L, X == Pivot] ++
        sort_fixed([X || X <- L, X > Pivot]).

%%%%%%%%%%%%%%%%%%
%%% Generators %%%
%%%%%%%%%%%%%%%%%%
path() -> list(oneof([left, right, up, down])).
tree() -> ?LET(L, non_empty(list(integer())), to_tree(L)).
