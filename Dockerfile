FROM ghcr.io/swipl/redis-group:v1.1.0
COPY *.pl ./
RUN find . -name \*.pl -exec chmod -x \{\} \;
