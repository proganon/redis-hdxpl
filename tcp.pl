:- volatile tcp_pool/2.
:- dynamic tcp_pool/2.

check_in_tcp(A, B) :- assertz(tcp_pool(A, B)).

check_out_tcp(A, B) :- retract(tcp_pool(A, B)), !.
check_out_tcp(A, B) :- tcp_connect(A, B, [nodelay(true)]).
