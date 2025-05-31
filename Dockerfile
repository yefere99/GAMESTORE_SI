# Etapa 1: construir Flutter Web manualmente con versión actualizada
FROM dart:stable AS flutter_build

# Instalar Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Verifica que Flutter funcione
RUN flutter --version

# Establecer directorio de trabajo
WORKDIR /app/frontend

# Copiar archivos necesarios
COPY frontend/pubspec.yaml ./
COPY frontend/pubspec.lock ./
COPY frontend/lib ./lib
COPY frontend/assets ./assets
COPY frontend/web ./web

RUN flutter pub get
RUN flutter build web

# Etapa 2: backend con Node.js
FROM node:18

WORKDIR /app

# Crear carpeta para imágenes subidas
RUN mkdir -p /app/backend/src/uploads

# Copiar backend y frontend compilado
COPY backend/ ./backend
COPY --from=flutter_build /app/frontend/build /app/backend/src/public

# Instalar dependencias del backend
WORKDIR /app/backend
RUN npm install

EXPOSE 3000

CMD ["node", "src/index.js"]
