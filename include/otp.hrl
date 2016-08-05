%%%-------------------------------------------------------------------
%%% @author calvin
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%      封装otp服务相关的一些接口
%%% @end
%%% Created : 29. 七月 2016 12:01
%%%-------------------------------------------------------------------

-define(DEFAULT_CALL_TIMEOUT, 5 * 1000). %% 5 sec
-define(GENSERVER_CALL(Dest, Message),
    gen_server:call(Dest, {'_time', ?NOW() + ?DEFAULT_CALL_TIMEOUT, Message}, ?DEFAULT_CALL_TIMEOUT)).

-define(GENSERVER_CALL(Dest, Message, TimeOut),
    begin
        case TimeOut of
            infinity ->
                gen_server:call(Dest, {'_time', ?NOW() + ?DEFAULT_CALL_TIMEOUT, Message}, infinity);
            _ ->
                gen_server:call(Dest, {'_time', ?NOW() + TimeOut, Message}, TimeOut)
        end

    end).

-define(GENSERVER_CAST(Dest, Message), gen_server:cast(Dest, Message)).

-define(NOW(),
    begin
        {S1, S2, _S3} = os:timestamp(),
        S1 * 1000000 + S2
    end).

-define(HANDLE_CALL(Message, State),
    begin
        try {
            case Message of
                {'_time', infinity, Msg} ->
                    do_handle(Msg, State);
                {'_time', Time, Msg} ->
                    case Time >= ?NOW() of
                        true ->
                            do_handle(Msg, State);
                        false ->
                            io:format("timeout message  = ~w", [Msg]),
                            {ok, State}
                    end;
                _ ->
                    do_handle(Message, State)
            end}
        catch
            T:R ->
                io:format("error  type = ~w, reason = ~w", [T, R]),
                {ok, State}
        end
    end).

-define(HANDLE_INFO(Message, State),
    begin
        try {
            do_handle(Message, State)
        }
        catch
            T:R ->
                io:format("error  type = ~w, reason = ~w", [T, R])
        end
    end).

-define(HANDLE_CASE(Message, State),
    begin
        try {
            do_handle(Message, State)
        }
        catch
            T:R ->
                io:format("error  type = ~w, reason = ~w", [T, R])
        end
    end).
