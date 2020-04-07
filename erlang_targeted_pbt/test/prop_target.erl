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
            LOSS = Y - X,
            io:format("Ended at: ~p, length of path: ~w, loss: ~w\n", [{X, Y}, length(P), LOSS]),
            % Give feedback to PropEr: Move to lower right, maximizing X and minimizing Y
            ?MAXIMIZE(-LOSS),
            true
        end).

prop_tree_regular(opts) -> [{numtests, 100}].
prop_tree_regular() ->
    ?FORALL_TARGETED(T, tree(),
        begin
            {Left, Right} = Weight = sides(T),
            io:format(" ~p", [Weight]),
            ?MAXIMIZE(Left-Right),
            true
        end).

% With custom neighbor functions, one can guide the search
% USER_NF macro takes a generator and an anonymous function taking current data
% and tuple with temperature and depth (next_tree) below.
prop_tree_neighbor(opts) -> [{numtests, 100}].
prop_tree_neighbor() ->
    ?FORALL_TARGETED(T, ?USERNF(tree(), next_tree()),
        begin
            {Left, Right} = Weight = sides(T),
            io:format(" ~p", [Weight]),
            ?MAXIMIZE(Left-Right),
            true
        end).

%%%%%%%%%%%%%%%
%%% Helpers %%%
%%%%%%%%%%%%%%%
move(left, {X, Y}) -> {X-1, Y};
move(right, {X, Y}) -> {X+1, Y};
move(up, {X, Y}) -> {X, Y+1};
move(down, {X, Y}) -> {X, Y-1}.

% List of numbers inserted into binary tree
to_tree(L) -> lists:foldl(fun insert/2, undefined, L).

insert(N, {node, N, L, R}) -> {node, N, L, R};
insert(N, {node, M, L, R}) when N < M -> {node, M, insert(N, L), R};
insert(N, {node, M, L, R}) when N > M -> {node, M, L, insert(N, R)};
insert(N, {leaf, N}) -> {leaf, N };
insert(N, {leaf, M}) when N < M -> {node, N, undefined, {leaf, M}};
insert(N, {leaf, M}) when N > M -> {node, N, {leaf, M}, undefined};
insert(N, undefined) -> {leaf, N}.

% Helper for computing how balanced a tree is
sides({node, _, Left, Right}) ->
    {LL, LR} = sides(Left),
    {RL, RR} = sides(Right),
    {count_inner(Left) + LL + LR, count_inner(Right)+RL + RR};
sides(_) -> {0, 0}.

count_inner({node, _, _, _}) -> 1;
count_inner(_) -> 0.

% Insert a drawn integer into the tree, with the value
% scaled by temperature to encourage smaller values
% when search progresses
next_tree() ->
    fun(OldTree, {_, T}) ->
        ?LET(N, integer(), insert(trunc(N*T*100), OldTree))
    end.

%%%%%%%%%%%%%%%%%%
%%% Generators %%%
%%%%%%%%%%%%%%%%%%
path() -> list(oneof([left, right, up, down])).
tree() -> ?LET(L, non_empty(list(integer())), to_tree(L)).
