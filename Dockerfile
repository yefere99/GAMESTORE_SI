# Etapa 1: construir Flutter Web
FROM cirrusci/flutter:stable AS flutter_build
WORKDIR /app/frontend

COPY frontend/pubspec.yaml ./
COPY frontend/pubspec.lock ./
COPY frontend/lib ./lib
COPY frontend/web ./web
COPY frontend/assets ./assets
RUN ls -la && ls pubspec.yaml

RUN flutter pub get --verbose

RUN flutter build web

# Etapa 2: Backend con Node.js
FROM node:18

WORKDIR /app
RUN mkdir -p /app/backend/src/uploads
COPY backend/ ./backend
COPY --from=flutter_build /app/frontend/build /app/backend/src/public

WORKDIR /app/backend
RUN npm install

EXPOSE 3000
CMD ["npm", "start"]
