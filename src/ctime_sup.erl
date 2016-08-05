%%%-------------------------------------------------------------------
%%% @author calvin
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%      ctime server sup
%%% @end
%%% Created : 29. 七月 2016 12:01
%%%-------------------------------------------------------------------
-module(ctime_sup).
-author("calvin").
-behaviour(supervisor).


%% API
-export([start_link/0,start_child/1]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).


start_child(ChildName) ->
    supervisor:start_child(?MODULE, [ChildName]).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    {ok, {{simple_one_for_one, 5, 10}, [?CHILD(ctime_server, worker)]}}.

