FROM phusion/passenger-ruby22
MAINTAINER Kisitu Augustine <austiine04@gmail.com>

ENV RAILS_ENV production

#bootstrap the docker container
WORKDIR /home/pneuma/scripts
ADD deployment/docker/bootstrap.sh /home/pneuma/scripts/
RUN /home/pneuma/scripts/bootstrap.sh

ENTRYPOINT ["/sbin/my_init"]
CMD ["--"]
ADD deployment/docker/migrate.sh /etc/my_init.d/04_migrate.sh

# copy source code and install dependencies
ADD . /srv/pneuma
WORKDIR /srv/pneuma
RUN bundle install --without development test --jobs 4 --path vendor/ && \
    rm -Rf vendor/ruby/2.2.2/cache
RUN npm install -g grunt-cli && npm install
RUN echo '{ "allow_root": true }' > /root/.bowerrc
RUN rake bower:install
RUN rake assets:precompile

#load the vhost file
ADD deployment/config_files/nginx/pneuma.conf /etc/nginx/sites-enabled/pneuma.conf
RUN rm /etc/nginx/sites-enabled/default

#runit config for postgres
ADD deployment/config_files/runit/postgresql/ /etc/service/postgresql/
RUN chmod +x /etc/service/postgresql/run

#turn nginx on
RUN rm -f /etc/service/nginx/down

EXPOSE 80
VOLUME ["/var/lib/postgresql", "var/log/postgresql", "var/run/postgresql"]
