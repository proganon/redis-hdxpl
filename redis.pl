:- setting(redis_url, atom, env('REDIS_URL', 'redis://localhost:6379'), '').

:- load_files(address, [if(not_loaded)]).

redis_address(Address) :-
    setting(redis_url, URL),
    url_address(URL, redis, Address).

:- redis_address(Address), redis_server(hdx, Address, []).
