# Etapa 1: instalar Flutter desde fuente (Flutter 3.22 compatible con Dart 3.2.0)
FROM debian:bullseye-slim AS flutter_build

RUN apt-get update && \
    apt-get install -y curl git unzip xz-utils zip libglu1-mesa && \
    git clone https://github.com/flutter/flutter.git -b stable /flutter && \
    /flutter/bin/flutter doctor

ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"

WORKDIR /app

# Copiar el frontend por partes
COPY frontend/pubspec.yaml ./pubspec.yaml
COPY frontend/pubspec.lock ./pubspec.lock
COPY frontend/lib ./lib
COPY frontend/web ./web
COPY frontend/assets ./assets

RUN flutter pub get
RUN flutter build web

# Etapa 2: Backend con Node.js
FROM node:18

WORKDIR /app
RUN mkdir -p /app/backend/src/uploads
COPY backend/ ./backend
COPY --from=flutter_build /app/build /app/backend/src/public

WORKDIR /app/backend
RUN npm install

EXPOSE 3000
CMD ["npm", "start"]
