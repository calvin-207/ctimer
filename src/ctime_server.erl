%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%      ctime server
%%% @end
%%% Created : 29. 七月 2016 12:02
%%%-------------------------------------------------------------------
-module(ctime_server).
-author("calvin").

-behaviour(gen_server).

%% API
-export([start_link/1]).

-export([register/3,
    unregister/3]).


%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-define(SERVER, ?MODULE).
-include("otp.hrl").
-include("common.hrl").
-record(state, {}).

-define(SEC_LOOP, sec_loop).
-define(MIN_LOOP, min_loop).
-define(ZERO_NIGHT, zero_night).

-define(CTIMER_TYPE, [?SEC_LOOP, ?MIN_LOOP, ?ZERO_NIGHT]).
-define(ONE_SEC, 1000). %%１ｓ

%%%===================================================================
%%% API
%%%===================================================================


%% @doc 注册时间服务
-spec register(Dest, From, Type) -> ok | error_type when
    Dest :: pid()|atom(),
    From :: pid()|atom(),
    Type :: ?SEC_LOOP | ?MIN_LOOP | ?ZERO_NIGHT.
register(Dest, From, Type) ->
    ?GENSERVER_CALL(Dest, {register, From, Type}).

%% @doc 取消注册时间相关的服务
-spec unregister(Dest, From, Type) -> ok | error_type when
    Dest :: pid()|atom(),
    From :: pid()|atom(),
    Type :: ?SEC_LOOP | ?MIN_LOOP | ?ZERO_NIGHT | all.
unregister(Dest, From, Type) ->
    erlang:send(Dest, {unregister, From, Type}).

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link(ServerName :: atom()) ->
    {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link(ServerName) ->
    gen_server:start_link({local, ServerName}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
    {ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term()} | ignore).
init([]) ->
    erlang:process_flag(trap_exit, true),
    init_dest(),
    erlang:send_after(1000, self(), second),
    {ok, #state{}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
        State :: #state{}) ->
    {reply, Reply :: term(), NewState :: #state{}} |
    {reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
    {noreply, NewState :: #state{}} |
    {noreply, NewState :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
    {stop, Reason :: term(), NewState :: #state{}}).
handle_call(Request, _From, State) ->
    Res = ?HANDLE_CALL(Request, State),
    case Res of
        {Ok, NewState} when erlang:is_record(NewState, state) ->
            {reply, Ok, NewState};
        Ok ->
            {reply, Ok, State}
    end.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_cast(Request :: term(), State :: #state{}) ->
    {noreply, NewState :: #state{}} |
    {noreply, NewState :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term(), NewState :: #state{}}).
handle_cast(Request, State) ->
    ?HANDLE_CASE(Request, State),
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
-spec(handle_info(Info :: timeout() | term(), State :: #state{}) ->
    {noreply, NewState :: #state{}} |
    {noreply, NewState :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term(), NewState :: #state{}}).
handle_info(Info, State) ->
    ?HANDLE_INFO(Info, State),
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
        State :: #state{}) -> term()).
terminate(_Reason, _State) ->
    ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #state{},
        Extra :: term()) ->
    {ok, NewState :: #state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%%%===================================================================
%%% dictionary functions
%%%===================================================================
init_dest() ->
    [erlang:put({pd_dest_list, Type}, []) || Type <- ?CTIMER_TYPE].

save_dest(Type, Dest) ->
    case erlang:get({pd_dest_list, Type}) of
        [] ->
            erlang:send_after(?ONE_SEC, self(), loop),
            erlang:put({pd_dest_list, Type}, [Dest]);
        DestList when is_list(DestList) ->
            ?IF(lists:member(Dest, DestList), ignore, erlang:put({pd_dest_list, Type}, [Dest | DestList]));
        _ ->
            erlang:send_after(?ONE_SEC, self(), loop),
            erlang:put({pd_dest_list, Type}, [Dest])
    end.
erase_dest(Type, Dest) ->
    case erlang:get({pd_dest_list, Type}) of
        DestList when is_list(DestList) -> erlang:put({pd_dest_list, Type}, lists:delete(Dest, DestList));
        _ -> ignore
    end.

get_dest(Type) ->
    ?IF(lists:member(Type, ?CTIMER_TYPE), erlang:get({pd_dest_list, Type}), []).

%%%===================================================================
%%% Internal functions
%%%===================================================================

%% @doc 处理秒循环
do_handle(loop, _State) ->
    erlang:send_after(?ONE_SEC, self(), loop),
    do_sec_loop(?NOW());

%% @doc 执行函数
do_handle({func, M, F, A}, State) ->
    {erlang:apply(M, F, A), State};

do_handle({func, Func}, State) ->
    {Func(), State};

%% @doc 处理注册
do_handle({register, From, Type}, _State) ->
    io:format("register, From = ~w, Type = ~w", [From, Type]),
    save_dest(Type, From),
    ok;

%% @doc 取消时间注册
do_handle({unregister, Dest, Type}, _State) ->
    case Type of
        all ->
            [erase_dest(T, Dest) || T <- ?CTIMER_TYPE];
        _ ->
            erase_dest(Type, Dest)
    end;

do_handle(Msg, State) ->
    io:format("Msg = ~w, State = ~w", [Msg, State]).

do_sec_loop(Now) ->
    lists:foreach(fun(Dest) -> Dest ! {sec_loop, Now} end, get_dest(?SEC_LOOP)).