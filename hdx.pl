/*  File:    srv/hdx.pl
    Author:  Roy Ratcliffe
    Created: Oct  2 2022
    Purpose: Half-Duplex Streaming

Copyright (c) 2022, Roy Ratcliffe, Northumberland, United Kingdom

Permission is hereby granted, free of charge,  to any person obtaining a
copy  of  this  software  and    associated   documentation  files  (the
"Software"), to deal in  the   Software  without  restriction, including
without limitation the rights to  use,   copy,  modify,  merge, publish,
distribute, sublicense, and/or sell  copies  of   the  Software,  and to
permit persons to whom the Software is   furnished  to do so, subject to
the following conditions:

    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT  WARRANTY OF ANY KIND, EXPRESS
OR  IMPLIED,  INCLUDING  BUT  NOT   LIMITED    TO   THE   WARRANTIES  OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR   PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS  OR   COPYRIGHT  HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY,  WHETHER   IN  AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM,  OUT  OF   OR  IN  CONNECTION  WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

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
