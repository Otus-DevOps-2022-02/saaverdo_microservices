FROM fluent/fluentd:v1.15
USER root
RUN gem uninstall -I elasticsearch && gem install elasticsearch -v 7.17.0
RUN apk add --no-cache --update --virtual .build-deps \
        sudo build-base ruby-dev \
        && sudo gem install fluent-plugin-elasticsearch -v 5.1.5 \
        && sudo gem install fluent-plugin-grok-parser -v 2.6.2 \
        && sudo gem sources --clear-all \
        && apk del .build-deps \
        && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem
ADD fluent.conf /fluentd/etc
USER fluent
