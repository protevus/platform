# Use latest stable channel SDK.
FROM dart:stable AS base

# Resolve app dependencies.
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get
COPY . .

# build for production
RUN dart run build_runner build --delete-conflicting-outputs
RUN dart compile exe bin/server.dart -o bin/server

FROM base as development
RUN dart pub global activate dox
CMD ["dox", "s"]

# Build minimal serving image from AOT-compiled `/server`
# and the pre-built AOT-runtime in the `/runtime/` directory of the base image.
FROM scratch as production
COPY --from=base /runtime/ /
COPY --from=base /app/.env /
COPY --from=base /app/bin/server /bin/
COPY --from=base /app/db/migration /db/migration
CMD ["/bin/server"]
