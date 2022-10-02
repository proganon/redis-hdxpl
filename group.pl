:- setting(group, atom, env('GROUP', tcp), '').
:- setting(consumer, atom, env('HOSTNAME'), '').
:- setting(key, atom, env('KEY', hdx), '').

:- load_files(redis, [if(not_loaded)]).

:- initialization(up, main).

up :-
    setting(group, Group),
    catch(setting(consumer, Consumer),
          error(existence_error(setting, _), _),
          gethostname(Consumer)),
    setting(key, Key),
    atomic_concat(Key, ':command', CommandKey),
    atomic_concat(Key, ':query', QueryKey),
    xgroup_create(CommandKey, Group),
    xgroup_create(QueryKey, Group),
    xlisten_group(hdx, Group, Consumer, [CommandKey, QueryKey],
                  [ block(0.1)
                  ]).

xgroup_create(Key, Group) :-
    catch(redis(hdx, xgroup(create, Key, Group, $, mkstream), status(ok)),
          error(redis_error(busygroup, _), _), true).
