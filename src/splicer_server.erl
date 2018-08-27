-module(splicer_server).
-behaviour(gen_server).

-export([start_link/0, init/1, handle_info/2, handle_cast/2, handle_call/3]).


start_link() ->
    gen_server:start_link(?MODULE, [], []).

init([]) ->
    self() ! go,
    {ok, {}}.

handle_info(go, State) ->
    {ok, ListenSocket} = gen_tcp:listen(0, [{active, false}, {ip, {127, 0, 0, 1}}]),
    {ok, Port} = inet:port(ListenSocket),
    io:format("listening on port ~p~n", [Port]),
    {ok, SockA} = gen_tcp:accept(ListenSocket),
    {ok, SockB} = gen_tcp:accept(ListenSocket),
    {ok, FDA} = inet:getfd(SockA),
    {ok, FDB} = inet:getfd(SockB),
    splicer:splice(FDA, FDB),
    self() ! go,
    {noreply, State};
handle_info(_, State) ->
    {noreply, State}.

handle_cast(_, State) ->
    {noreply, State}.

handle_call(_, _, State) ->
    {reply, ok, State}.
