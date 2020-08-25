FROM chrisortman/ruby-25-on-rails:1.0
LABEL maintainer="chris-ortman@uiowa.edu"

#Or else bundler 2.1.x wont load
RUN gem update --system
RUN gem install bundler -v 2.1.2
# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir /app
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN bundle install --deployment

COPY . /app
COPY config/database.yml.example /app/config/database.yml
COPY config/faye.yml.example /app/config/faye.yml
COPY dotenv.example /app/.env

RUN SECRET_KEY_BASE='b5b57bb7d19a59231f09d44bf72d9456bd9b45ca6ceaf770d0ef2a5e7d2997feb6a4fbe2e885616900f1afab9bf8a90c0cf2844b33f481b811c1c644e2ce06bd' RAILS_ENV=production bundle exec rails assets:precompile

COPY config/database.yml.docker /app/config/database.yml
RUN mkdir -p /var/www/html
VOLUME ["/var/www/html", "/app/public/system"]

EXPOSE 3000

RUN chmod +x /app/script/entrypoint.sh
ENTRYPOINT ["/app/script/entrypoint.sh"]
ENV RAILS_ENV production
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV RAILS_LOG_TO_STDOUT=1
CMD ["server"]
