%%%-------------------------------------------------------------------
%%% @author calvin
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%      时间公用接口
%%% @end
%%% Created : 29. 七月 2016 12:01
%%%-------------------------------------------------------------------
-module(ctime).
-author("calvin").

%% API
-export([now/0,
    midnight/0,
    diff/2,
    string_to_sec/1]).

%% @doc 当前秒时间戳
now() ->
    {S1, S2, _S3} = os:timestamp(),
    S1 * 1000000 + S2.

%% @doc 获取当天的0点时间戳
midnight() ->
    pass.

%% @doc 跟进两个时间获取到之间的时间差以sec为单位
diff(_Old, _New) ->
    pass.

%% @doc 时间字符串转秒时间戳
%% Time = "2016-5-6" | 2016:05:20
string_to_sec(_Time) ->
    pass.