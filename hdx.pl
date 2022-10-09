/*  File:    srv/hdx.pl
    Author:  Roy Ratcliffe
    Created: Oct  2 2022
    Purpose: Streams Half-Duplex TCP

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
:- setting(nl_flush, boolean, env('NL_FLUSH', true), '').

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

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Some protocols may require a newline before the flush. Two options
exist in such cases. First, include a new-line terminator in all
outbound messages. That will work but clutters up the command and query
streams with redundant newlines. The second option implies the
terminating newline for all transmissions. The protocol always adds a
newline before a flush, even if streaming includes a newline in the
transmission command or query; in those instances the TCP server sees a
double newline. For this reason, the newline flushing step depends on a
setting `nl_flush` which writes a newline in whatever form the stream
defines before it flushes the output stream.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

hdx(Out, Term) :-
    write(Out, Term),
    (   setting(nl_flush, true)
    ->  nl(Out)
    ;   true
    ),
    flush_output(Out).

hdx(In, Codes, TimeOut) :-
    wait_for_input([In], [Ready], TimeOut),
    fill_buffer(Ready),
    read_pending_codes(Ready, Codes, []).
