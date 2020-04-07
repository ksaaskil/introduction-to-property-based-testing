# erlang_targeted_pbt

## Instructions

Build

    $ rebar3 compile

Run properties with [`rebar3-proper`](https://github.com/ferd/rebar3_proper/) plugin:

    $ rebar3 proper

Create new properties:

    $ rebar3 new proper foundations
    ===> Writing test/prop_foundations.erl

See rebar3-proper plugin help:

    $ rebar3 help proper

Enter test shell:

    $ rebar3 as test shell
    1> proper_types:term().
    <long output describing generator>
    2> proper_gen:pick(proper_types:number()).
    {ok, 3}
    3> proper_gen:pick(proper_types:range(-500, 500)).
    {ok, 432}
    4> proper_gen:pick({proper_types:bool(), proper_types:float()}).
    {ok,{true,-12.782946695312658}}

Run a single property:

    $ rebar3 proper -p prop_path