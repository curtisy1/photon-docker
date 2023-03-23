FROM openjdk:11-slim

ARG PHOTON_LANGUAGES
ENV PHOTON_LANGUAGES ${PHOTON_LANGUAGES:-"de,en,fr"}

# If photon-db does not exist in /photon/photon_data, the following properties
# will be used to import json dump file (if existant) or create index from nominatim
ENV NOMINATIM_DB_HOST nominatim
ENV NOMINATIM_DB_PORT 5432
ENV NOMINATIM_DB_USER nominatim
ENV NOMINATIM_DB_PASSWORD qaIACxO6wMR3
ENV AUTOMATIC_UPDATES true
ENV JSON_DUMP_FILE /photon/photon_data/photon_db.json

# run the update every day at 5 o'clock
ADD ./nominatim-update /usr/local/bin/nominatim-update
RUN chmod g+w,o-rw,a+x /usr/local/bin/nominatim-update
ADD ./crontab /etc/cron.d/nominatim-update
RUN chmod 0644 /etc/cron.d/nominatim-update
RUN touch /var/log/nominatim-update.log
RUN apt-get update && apt-get -y --no-install-recommends install cron curl && rm -rf /var/lib/apt/lists/*

WORKDIR /photon
ADD https://github.com/komoot/photon/releases/download/0.4.2/photon-0.4.2.jar /photon/photon.jar
COPY entrypoint.sh ./entrypoint.sh

# Expose Photon Webservice and Elastic Search (ES)
EXPOSE 2322 9200

# To mount external folder supply -v /path/on/host:/photon/photon_data to docker run
VOLUME /photon/photon_data
ADD ./entrypoint.sh /photon/entrypoint.sh
RUN chmod ugo+x /photon/entrypoint.sh

ENTRYPOINT /photon/entrypoint.sh
