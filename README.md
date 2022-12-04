# redis-hdxpl

## Example

Each listener in the nominal `hdx` group listens to commands and queries. Set up the name of the group using the environment variable `REDIS_GROUP`. The stream keys must terminate with colon-command and colon-query and they must appear in the `REDIS_KEYS` environment variable formatted as a Prolog list term where members are atoms identifying stream keys. Finally, the group requires a Redis hash key in the environment variable `ADDRESS_KEY` for mapping TCP addresses to some actual TCP host-name and port-number URLs.

Run like this, for example:
```bash
docker run --rm -it -e REDIS_GROUP=hdx -e REDIS_KEYS="['hdx:command','hdx:query']" -e ADDRESS_KEY="hdx:tcp" $(docker build -q .)
```
Once running, add a query using:
```prolog
?- xadd(default, hdx:query, A, _{tcp:localhost, query:"hello world?"}).
A = 1665333237268-0.
```
Variable `A` unifies with the new stream identifier. Add a command using:
```prolog
 xadd(default, hdx:command, A, _{tcp:localhost, command:"hello world"}).
A = 1665333095023-0.
```
Note that the command and query streams require command and query fields respectively.

## Redis URL

The environment variable REDIS_URL defines the external Redis server connection. It defaults to `localhost` which never works for containers because the local host does *not* serve Redis.
