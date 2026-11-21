# EcoConecta · Villas de San Pablo

Plataforma comunitaria para conectar hogares y unidades productivas de Villas de San Pablo, Barranquilla, con huerteros y recicladores.

## Descargar el proyecto
En GitHub, selecciona el botón verde **Code** y luego **Download ZIP**. También puedes clonar el repositorio:
```bash
git clone https://github.com/kannermoreu13-cmd/EcoConecta.git
```

## Tecnología
- Frontend: HTML, CSS y JavaScript.
- Backend: Python 3.12, FastAPI.
- Base de datos: PostgreSQL 16.
- Infraestructura: Docker Compose.
- Integración opcional: WhatsApp Business Cloud API.

## Funcionalidades
- Registro de ciudadanos e inicio de sesión con teléfono y contraseña.
- Roles: administrador, coordinadores de orgánicos/reciclables, huerteros, recicladores y comunidad.
- Solicitudes, asignaciones, programación, seguimiento y evidencias.
- Historial y puntos de participación.
- EcoBot de orientación ambiental.
- Notificaciones internas y conexión opcional con WhatsApp, sujeta a credenciales y plantillas aprobadas de Meta.

## Ejecutar en Windows
1. Instala Docker Desktop e inicia Docker.
2. Copia `.env.example` como `.env`.
3. Configura `SECRET_KEY` (mínimo 32 caracteres aleatorios) y `POSTGRES_PASSWORD`. La contraseña de `DATABASE_URL` debe coincidir con `POSTGRES_PASSWORD`.
4. Ejecuta:
   ```powershell
   docker compose -p ecoconecta up --build -d
   ```
5. Abre http://localhost:8000

## Crear el primer administrador
Con el contenedor web iniciado:
```powershell
docker compose -p ecoconecta exec web python scripts/create_staff.py
```
El asistente solicita rol, nombre, teléfono y una contraseña propia de al menos 12 caracteres. No hay usuarios ni contraseñas predeterminadas.

## WhatsApp
La integración está desactivada por defecto. Para enviar mensajes reales se requiere una cuenta de WhatsApp Business Platform, token de Meta, ID del número, plantilla aprobada y consentimiento del destinatario. Consulta `INTEGRACIONES_CHATBOT_WHATSAPP.md`.

## Documentación
Consulta `docs/`, `README.md` del paquete y `SEGURIDAD_FASE_1.md` para arquitectura, análisis, modelo de datos, pruebas y guía de operación.

## Seguridad
No subas el archivo `.env`, tokens, contraseñas ni datos personales al repositorio. El archivo `.env` está excluido por `.gitignore`.
