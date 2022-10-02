# redis-hdxpl

## Redis URL

The environment variable REDIS_URL defines the external Redis server connection. It defaults to `localhost` which never works for containers because the local host does *not* serve Redis.
