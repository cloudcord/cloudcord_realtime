FROM bitwalker/alpine-elixir:1.7.4 as build

COPY . .

#Install dependencies and build Release
RUN export MIX_ENV=prod SECRET_KEY_BASE=pcrCHNT2c/0F1hGQcbm/JYAimM99mcF8jzggHVh4mETi/Kg4AtHyhB3j1/uDHRQk && \
    rm -Rf _build && \
    mix deps.get && \
    mix release --env=prod

#Extract Release archive to /rel for copying in next stage
RUN APP_NAME="cloudcord_realtime" && \
    RELEASE_DIR=`ls -d _build/prod/rel/$APP_NAME/releases/*/` && \
    mkdir /export && \
    tar -xf "$RELEASE_DIR/$APP_NAME.tar.gz" -C /export

#================
#Deployment Stage
#================
FROM pentacent/alpine-erlang-base:latest

#Set environment variables and expose port
ENV REPLACE_OS_VARS=true

#Copy and extract .tar.gz Release file from the previous stage
COPY --from=build /export/ .

USER default

ENTRYPOINT ["/opt/app/bin/cloudcord_realtime"]
CMD ["foreground"]
