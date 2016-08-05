%%%-------------------------------------------------------------------
%%% @author calvin
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%      ctime application
%%% @end
%%% Created : 29. 七月 2016 12:02
%%%-------------------------------------------------------------------
-module(ctime_app).
-author("calvin").

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    ctime_sup:start_link().

stop(_State) ->
    ok.
