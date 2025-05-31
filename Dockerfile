# Etapa 1: Construir Flutter Web
FROM dart:stable AS flutter_build

# Instalar Flutter manualmente (última versión)
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"
RUN flutter --version

# Directorio del frontend
WORKDIR /app/frontend

# Copiar solo lo necesario
COPY frontend/pubspec.yaml ./
COPY frontend/pubspec.lock ./
COPY frontend/lib ./lib
COPY frontend/assets ./assets
COPY frontend/web ./web

# Instalar dependencias y compilar
RUN flutter pub get
RUN flutter build web

# Etapa 2: Backend con Node.js
FROM node:18

# Crear estructura de directorios
WORKDIR /app
RUN mkdir -p /app/backend/src/uploads

# Copiar backend
COPY backend/ ./backend

# Copiar build del frontend al backend (donde se sirve)
COPY --from=flutter_build /app/frontend/build /app/backend/src/public

# Instalar dependencias del backend
WORKDIR /app/backend
RUN npm install

# Puerto expuesto (Railway)
EXPOSE 3000

# Ejecutar backend
CMD ["node", "src/index.js"]
