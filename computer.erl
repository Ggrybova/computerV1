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
    case solve_equation(Map) of
        Sols when is_list(Sols) ->
            io:format("The solution is:~n"),
            [io:format("~p~n", [Sol]) || Sol <- Sols];
        Sols -> io:format(Sols)
    end.

solve_equation(#{degree := Degree}) when Degree > 2 ->
    io:format("Degree: ~p~n", [Degree]),
    io:format("The polynomial degree is stricly greater than 2, I can't solve.~n");

solve_equation(#{degree := Degree, a := A, b := B, c := C} = Map) ->
    D = B*B-4*A*C,
    Map2 = Map#{d => D},
    io:format("Degree: ~p~n", [Degree]),
    io:format("Map: ~p~n", [Map2]),
    case D of
        D when D < 0 -> "No solution.";
        D when D == 0 ->
            [-1*B/2/A];
        D when D > 0 andalso Degree == 1 ->
            [(-1*C)/B];
        D when D > 0 andalso Degree == 1 ->
            [(-1*B+sq(D))/A];
        D when D > 0 andalso Degree == 2 ->
            [(-1*B+sq(D))/A, (-1*B-sq(D))/A];
        D -> "What a fuck&?"
    end;

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
                    io:format("Format error: ~p", [Bin]),
                    halt()
            end
    end.

fill_map([], [], Acc) ->
    io:format(": Acc: ~p~n", [Acc]),
    print_reduce(lists:reverse(Acc)),
    Len = length(Acc),
    Map = case  Len of
        1 ->
            [C] = Acc,
            #{a => 0, b => 0, c => C};
        2 ->
            [B, C] = Acc,
            #{a => 0, b => B, c => C};
        3 ->
            [A, B, C] = Acc,
            #{a => A, b => B, c => C};
        _ ->
            #{}
    end,
    Res = maps:put(degree, Len - 1, Map),
    io:format(": Map: ~p~n", [Res]),
    Res;

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
                    _ when Coef == 0 -> io:format("");
                    0 when Coef > 0 -> io:format("~p", [Coef]);
                    0 when Coef < 0 -> io:format("- ~p ", [Coef * -1]);
%%                    1 when Coef > 0 -> io:format(" + ~p * X", [Coef]);
%%                    1 when Coef < 0 -> io:format(" - ~p * X", [Coef * -1]);
                    _ when Coef > 0 -> io:format(" + ~p * X^~p", [Coef, Acc]);
                    _  -> io:format(" - ~p * X^~p", [Coef * -1, Acc])
                end,
            Acc + 1
        end, 0, List),
    io:format(" = 0~n").

sq(0) -> 0;

sq(1) -> 1;

sq(X) when X >= 0 ->
    R = X div 2,
    sq(X div R, R, X).

sq(Q,R,X) when Q < R ->
    R1 = (R+Q) div 2,
    sq(X div R1, R1, X);

sq(_, R, _) -> R.
