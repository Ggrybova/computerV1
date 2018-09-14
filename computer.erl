%%%-------------------------------------------------------------------
%%% @author ggrybova
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. Sep 2018 17:44
%%%-------------------------------------------------------------------
-module(computer).
-author("ggrybova").

%%====================================================================
%% API
%%====================================================================
-export([
    main/1,
    solve_equation/1,
    get_equation/1
]).

main(Arg) ->
    Map = get_equation(Arg),
    solve_equation(Map).

solve_equation(#{}) ->
    ok;

solve_equation(#{degree := Degree}) when Degree > 2 ->
    io:format("The polynomial degree is stricly greater than 2, I can't solve.");

solve_equation(Map) when is_map(Map) ->
    io:format("Map: ~p~n", [Map]);

solve_equation(_) ->
    io:format("Fuck you!").

get_equation(Arg) ->
    Arg1 = binary:replace(Arg, [<<" ">>], <<"">>, [global]),
    case binary:split(Arg1, [<<"=">>], []) of
        [Left, Right] ->
            MonomialsL = split(Left, [<<"*">>], []),
            MonomialsR = split(Right, [<<"*">>], []),
            fill_map(MonomialsL, MonomialsR, []);
        E -> io:format("Error. Program exit. Reason: ~p~n", [E]),
            #{}
    end.

%%====================================================================
%% Internal functions
%%====================================================================

split(Arg, Sep, Acc) ->
    case binary:split(Arg, Sep) of
        [Coef , Rest] ->
            case Coef of
                <<_, "^", _, Y/binary>> ->
                    split(Rest, Sep, [convert_to_float(Y) | Acc]);
                Bin ->
                    split(Rest, Sep, [convert_to_float(Bin) | Acc])
            end;
        _ -> lists:reverse(Acc)
    end.

convert_to_float(Bin) ->
    try
        binary_to_float(Bin)
    catch
        _:_ ->
            try
                binary_to_integer(Bin)
            catch
                _:_ ->
                    exit(format_error, Bin)
            end
    end.

fill_map([], [], Acc) ->
    print_reduce(lists:reverse(Acc)),
    case length(Acc) of
        1 ->
            [C] = Acc,
            #{a => 0, b => 0, c => C, degree => 0};
        2 ->
            [B, C] = Acc,
            #{a => 0, b => B, c => C, degree => 1};
        3 ->
            [A, B, C] = Acc,
            #{a => A, b => B, c => C, degree => 2};
        _ ->
            #{degree => 3}
end;

fill_map([], [H2 | T2], Acc) ->
    fill_map([], T2, [ -1*H2 | Acc]);

fill_map([H1 | T1], [], Acc) ->
    fill_map(T1, [], [H1 | Acc]);

fill_map([H1 | T1], [H2 | T2], Acc) ->
    fill_map(T1, T2, [H1 - H2 | Acc]).

print_reduce(List) ->
    io:format("Reduced form: "),
    lists:foldl(
        fun(Coef, Acc) ->
                case Acc of
                    0 when Coef >= 0 -> io:format("~p", [Coef]);
                    0 -> io:format("- ~p ", [Coef * -1]);
                    1 when Coef >= 0 -> io:format(" + ~p * X", [Coef]);
                    1 -> io:format(" - ~p * X", [Coef * -1]);
                    _ when Coef >= 0 -> io:format(" + ~p * X^~p", [Coef, Acc]);
                    _  -> io:format(" - ~p * X^~p", [Coef * -1, Acc])
                end,
            Acc + 1
        end, 0, List),
    io:format(" = 0~n").
