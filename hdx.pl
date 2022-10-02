:- setting(query_time_out, number, env('QUERY_TIME_OUT', 3.0), '').

hdx_command(StreamPair, Command) :-
    stream_pair(StreamPair, _, Out),
    hdx(Out, Command).

hdx_query(StreamPair, Query, Reply) :-
    setting(query_time_out, TimeOut),
    hdx(StreamPair, Query, Codes, TimeOut),
    string_codes(Reply, Codes).

hdx(StreamPair, Term, Codes, TimeOut) :-
    stream_pair(StreamPair, In, Out),
    hdx(Out, Term),
    hdx(In, Codes, TimeOut).

hdx(Out, Term) :-
    write(Out, Term),
    nl(Out),
    flush_output(Out).

hdx(In, Codes, TimeOut) :-
    wait_for_input([In], [Ready], TimeOut),
    fill_buffer(Ready),
    read_pending_codes(Ready, Codes, []).
