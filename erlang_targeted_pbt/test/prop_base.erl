-module(prop_base).

-include_lib("proper/include/proper.hrl").

%%%%%%%%%%%%%%%%%%
%%% Properties %%%
%%%%%%%%%%%%%%%%%%
prop_biggest() ->
    ?FORALL(List, non_empty(list(integer())),
        begin
            biggest(List) =:= lists:last(lists:sort(List))
        end).

%%%%%%%%%%%%%%%
%%% Helpers %%%
%%%%%%%%%%%%%%%
biggest([Head | Tail]) ->
    biggest(Tail, Head).

biggest([], Biggest) -> Biggest;
biggest([Head | Tail], Biggest) when Head >= Biggest -> biggest(Tail, Head);
biggest([Head | Tail], Biggest) when Head < Biggest -> biggest(Tail, Biggest).
%%%%%%%%%%%%%%%%%%
%%% Generators %%%
%%%%%%%%%%%%%%%%%%

