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
    %% Override CLI and rebar.config option for "numtests"
    [{numtests, 100}].
prop_path() ->
    ?FORALL_TARGETED(P, path(),
        begin
            {X, Y} = lists:foldl(fun move/2, {0, 0}, P),
            io:format("~p", [{X, Y}]),
            % Give feedback to PropEr: Move to upper right, maximizing X and minimizing Y
            ?MAXIMIZE(X-Y),
            true
        end).

%%%%%%%%%%%%%%%
%%% Helpers %%%
%%%%%%%%%%%%%%%
move(left, {X, Y}) -> {X-1, Y};
move(right, {X, Y}) -> {X+1, Y};
move(up, {X, Y}) -> {X, Y+1};
move(down, {X, Y}) -> {X, Y-1}.

%%%%%%%%%%%%%%%%%%
%%% Generators %%%
%%%%%%%%%%%%%%%%%%
path() -> list(oneof([left, right, up, down])).
