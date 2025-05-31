# 🕹️ GameStore

GameStore es una aplicación web de comercio electrónico enfocada en la venta de videojuegos, consolas y periféricos. Desarrollada con **Flutter (frontend)**, **Node.js + Express (backend)** y **MongoDB (base de datos)**. El proyecto simula un proceso completo de compra con carrito, checkout y administración de productos.

## 📦 Tecnologías utilizadas

- **Frontend**: Flutter (Material Design, navegación dinámica, responsive)
- **Backend**: Node.js + Express (API REST)
- **Base de datos**: MongoDB
- **Contenedores**: Docker + Docker Compose
- **Orquestación (opcional)**: Kubernetes
- **Simulación de pagos**: Checkout mock y confirmación visual

## 🧰 Estructura del proyecto

```
gamestore/
├── backend/
│   ├── models/
│   ├── routes/
│   ├── controllers/
│   └── server.js
├── frontend/
│   ├── lib/
│   │   ├── views/
│   │   ├── services/
│   │   ├── models/
│   │   └── widgets/
├── uploads/
├── docker-compose.yml
├── Dockerfile.backend
├── Dockerfile.frontend
```

## 🚀 Funcionalidades

### 👤 Usuario
- Navegación por catálogo de productos
- Vista detallada de producto
- Agregar productos al carrito
- Simulación de compra
- Confirmación de pedido

### 🔐 Administrador
- Login de administrador
- Agregar, editar y eliminar productos
- Visualización de pedidos
- Panel de administración completo

## ⚙️ Instalación local

### Requisitos
- Docker y Docker Compose instalados
- Flutter instalado si deseas ejecutar el frontend sin contenedor

### 1. Clonar el repositorio
```bash
git clone https://github.com/tuusuario/gamestore.git
cd gamestore
```

### 2. Levantar con Docker
```bash
docker-compose up --build
```

### 3. Acceso
- **Frontend**: `http://localhost:8080`
- **Backend API**: `http://localhost:3000/api`

## 📂 Variables de entorno

```env
MONGO_URL=mongodb://mongo:27017/gamestore
PORT=3000
```
## 📌 Posibles mejoras

- Integración con pasarela de pagos real (ej. Stripe, PayU)
- Registro y autenticación de usuarios
- Historial de compras
- Valoraciones y reseñas de productos
- Dashboard con métricas y estadísticas
- Soporte multi-idioma
- Migración a base de datos SQL como alternativa

## 🧑‍💻 Autores

Desarrollado por: Sharon Melissa Trujillo Duran - Yefersson Stiven Zuluaga Zuluaga