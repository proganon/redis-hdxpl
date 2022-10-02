/*  File:    srv/consume.pl
    Author:  Roy Ratcliffe
    Created: Oct  2 2022
    Purpose: Consume Redis Streams

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

:- load_files([key, tcp, hdx], [if(not_loaded)]).

:- listen(redis_consume(Key, Data, Context), consume(Key, Data, Context)).

consume(Key, Data, Context) :-
    sub_atom(Key, _, _, 0, ':command'),
    !,
    command(Data, Context.put(key, Key)).
consume(Key, Data, Context) :-
    sub_atom(Key, _, _, 0, ':query'),
    !,
    query(Data, Context.put(key, Key)).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

The cut is significant for the behaviour of the consumer group. It
delineates between retrying and discarding the incoming command or
query. Failure before the cut discards the incoming event. Failure
*after* the cut retries the event, by this or some other consumer within
the same group.

Notice that the consumer can access the same connection alias. The
context carries the Redis connection ready for re-use.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

command(Data, Context) :-
    get_dict(command, Data, Command),
    get_dict(key, Data, Key),
    key_address(Key, Address),
    !,
    check_out_tcp(Address, StreamPair),
    hdx_command(StreamPair, Command),
    check_in_tcp(Address, StreamPair),
    xadd(Context.redis, Key, _, _{key:Context.key,
                                  id:Context.message,
                                  group:Context.group,
                                  consumer:Context.consumer}).
command(_, _).

query(Data, Context) :-
    get_dict(query, Data, Query),
    get_dict(key, Data, Key),
    key_address(Key, Address),
    !,
    check_out_tcp(Address, StreamPair),
    hdx_query(StreamPair, Query, Reply),
    check_in_tcp(Address, StreamPair),
    xadd(Context.redis, Key, _, _{reply:Reply,
                                  key:Context.key,
                                  id:Context.message,
                                  group:Context.group,
                                  consumer:Context.consumer}).
query(_, _).
