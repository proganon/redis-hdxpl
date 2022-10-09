/*  File:    srv/tcp.pl
    Author:  Roy Ratcliffe
    Created: Oct  2 2022
    Purpose: Pools TCP Streams by Address

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

tcp_command(Address, Command) :-
    check_out_tcp(Address, StreamPair),
    hdx_command(StreamPair, Command),
    check_in_tcp(Address, StreamPair).

tcp_query(Address, Query, Reply) :-
    check_out_tcp(Address, StreamPair),
    hdx_query(StreamPair, Query, Reply),
    check_in_tcp(Address, StreamPair).

		 /*******************************
		 *           TCP Pool           *
		 *******************************/

:- volatile tcp_pool/2.
:- dynamic tcp_pool/2.

check_in_tcp(A, B) :- assertz(tcp_pool(A, B)).

check_out_tcp(A, B) :- retract(tcp_pool(A, B)), !.
check_out_tcp(A, B) :- tcp_connect(A, B, [nodelay(true)]).
