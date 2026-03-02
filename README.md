# 🚀 My Custom Retail Store Build v1.3.0

Esta carpeta contiene tu versión personalizada del **Retail Store Sample App v1.3.0** para construir tus propias imágenes Docker.

---

## 📁 Estructura del Proyecto

```
My-Custom-Build-v1.3.0/
├── README.md                    # Este archivo
├── docker-compose.yaml          # Para pruebas locales (sección 04)
├── kubernetes.yaml              # Para despliegues K8s (sección 08+)
├── build-all-images.sh          # Script para construir TODAS las imágenes
├── push-to-dockerhub.sh         # Script para subir a Docker Hub
├── migrate-to-ecr.sh            # Script para migrar a Amazon ECR
├── samples/                     # Datos de ejemplo
│   ├── data/                    # JSON con productos y tags
│   └── images/                  # Imágenes de productos
└── src/                         # Código fuente de microservicios
    ├── ui/                      # Frontend (Java Spring Boot)
    ├── catalog/                 # Catálogo (Go)
    ├── cart/                    # Carrito (Java Spring Boot)
    ├── checkout/                # Checkout (Node.js NestJS)
    ├── orders/                  # Órdenes (Java Spring Boot)
    └── load-generator/          # Generador de carga (Node.js)
```

---

## 🎯 Versión y Compatibilidad

- **Versión Base:** 1.3.0 (Septiembre 2025)
- **Compatibilidad:** Secciones 1-13 del curso
- **Features:** EventBridge, CloudWatch Agent, 5 temas UI
- **Imágenes Base:** `public.ecr.aws/aws-containers/retail-store-sample-*:1.3.0`

---

## 🔧 Requisitos Previos

### Software Necesario:
```bash
✅ Docker Desktop (o Docker Engine)
✅ Git (opcional)
✅ Cuenta Docker Hub (gratis)
✅ AWS CLI (para ECR - opcional)
```

### Verificar Instalación:
```bash
docker --version      # Docker 20.10+
docker compose version # v2.0+
git --version         # Git 2.x+ (opcional)
aws --version         # AWS CLI 2.x+ (opcional)
```

---

## 🚀 Quick Start: 3 Pasos

### **PASO 1: Configurar Tu Usuario**

Edita los scripts de build con tu usuario de Docker Hub:

```bash
# En build-all-images.sh, línea 7:
export DOCKER_USER="tu_usuario_dockerhub"

# En push-to-dockerhub.sh, línea 7:
export DOCKER_USER="tu_usuario_dockerhub"

# En migrate-to-ecr.sh (opcional), línea 7:
export DOCKER_USER="tu_usuario_dockerhub"
```

### **PASO 2: Construir Imágenes (30-60 min)**

```bash
# Dar permisos de ejecución
chmod +x *.sh

# Construir TODAS las imágenes
./build-all-images.sh

# ☕ Ve por un café mientras compila
```

### **PASO 3: Subir a Docker Hub (5-10 min)**

```bash
# Subir todas las imágenes
./push-to-dockerhub.sh

# Se te pedirá tu contraseña de Docker Hub
```

---

## 📦 Microservicios Incluidos

| Servicio | Lenguaje | Puerto | Dockerfile | Descripción |
|----------|----------|--------|------------|-------------|
| **UI** | Java (Spring Boot) | 8080 | ✅ | Frontend web de la tienda |
| **Catalog** | Go | 8080 | ✅ | API de catálogo de productos |
| **Cart** | Java (Spring Boot) | 8080 | ✅ | API de carrito de compras |
| **Checkout** | Node.js (NestJS) | 8080 | ✅ | API de proceso de checkout |
| **Orders** | Java (Spring Boot) | 8080 | ✅ | API de gestión de órdenes |

---

## 🎨 Personalización: Antes del Build

### Opción 1: Cambio Simple - Título

```bash
cd src/ui/src/main/resources

# Editar messages.properties
# Buscar: application.title=Retail Store Sample
# Cambiar por: application.title=Mi Tienda DevOps by [Tu Nombre]
```

### Opción 2: Cambio Visual - Banner

```bash
cd src/ui/src/main/resources/templates

# Editar home.html
# Buscar líneas 60-80 con texto visible
# Personalizar el texto del banner principal
```

### Opción 3: Cambio de Tema

```bash
# En docker-compose.yaml o kubernetes.yaml
# Agregar variable de entorno:
RETAIL_UI_THEME: "teal"  # Opciones: default, orange, blue, green, teal
```

---

## 📊 Tamaños de Imágenes (Referencia)

```
retail-store-ui:       ~280 MB
retail-store-catalog:  ~180 MB
retail-store-cart:     ~280 MB
retail-store-checkout: ~220 MB
retail-store-orders:   ~280 MB
───────────────────────────────
TOTAL:                ~1.24 GB
```

---

## 🧪 Probar Localmente con Docker Compose

### Antes de subir las imágenes, pruébalas localmente:

```bash
# Editar docker-compose.yaml
# Cambiar las imágenes de:
# image: public.ecr.aws/aws-containers/retail-store-sample-ui:1.3.0
# Por:
# image: tu_usuario/retail-store-ui:1.3.0-custom

# Levantar stack completo
DB_PASSWORD='mypassword123' docker compose up

# Acceder en navegador
http://localhost:8888

# Para detener
docker compose down
```

---

## 🏗️ Uso en Secciones del Curso

### Sección 02-03: Docker Commands
```bash
# Pull tu imagen personalizada
docker pull tu_usuario/retail-store-ui:1.3.0-custom

# Run local
docker run -p 8888:8080 tu_usuario/retail-store-ui:1.3.0-custom
```

### Sección 04: Docker Compose
```bash
# Usar docker-compose.yaml personalizado
# (Ya incluido en esta carpeta)
DB_PASSWORD='pass123' docker compose up
```

### Sección 08-12: Kubernetes
```bash
# Actualizar manifests con tus imágenes
# En lugar de: public.ecr.aws/aws-containers/retail-store-sample-ui:1.3.0
# Usar: tu_usuario/retail-store-ui:1.3.0-custom

kubectl apply -f kubernetes.yaml
```

### Sección 13-14: EKS + AddOns
```bash
# Usar tus imágenes en manifests de la sección 14
# Reemplazar en todos los deployment.yaml
```

---

## 🐳 Comandos Útiles de Docker

```bash
# Ver todas las imágenes construidas
docker images | grep retail-store

# Ver tamaño total
docker images | grep retail-store | awk '{sum+=$7} END {print sum " MB"}'

# Limpiar imágenes viejas
docker image prune -a

# Ver logs de un contenedor
docker logs <container_id>

# Entrar a un contenedor
docker exec -it <container_id> /bin/bash

# Eliminar todas las imágenes retail-store
docker images | grep retail-store | awk '{print $3}' | xargs docker rmi -f
```

---

## 🌐 Migrar a Amazon ECR (Opcional)

Después de tener tus imágenes en Docker Hub, puedes migrarlas a ECR:

```bash
# Configurar AWS CLI
aws configure

# Ejecutar script de migración
./migrate-to-ecr.sh

# Resultado: Imágenes en:
# 123456789.dkr.ecr.us-east-1.amazonaws.com/retail-store-ui:1.3.0-custom
```

---

## 🔍 Troubleshooting

### Build muy lento
```bash
# Primera vez: 30-60 minutos (normal)
# Builds subsecuentes: 5-10 minutos (usa caché)

# Para build más rápido, usa BuildKit:
export DOCKER_BUILDKIT=1
docker build ...
```

### Error: "No space left on device"
```bash
# Limpiar Docker
docker system prune -a --volumes

# Verificar espacio
df -h
```

### Error en build de Java (UI, Cart, Orders)
```bash
# Asegúrate de tener suficiente memoria
# Docker Desktop: Settings → Resources → Memory (mínimo 4GB)

# Si falla Maven, intenta:
cd src/ui  # o cart, orders
./mvnw clean package -DskipTests
```

### Error en build de Go (Catalog)
```bash
cd src/catalog

# Verificar dependencias
go mod download
go mod verify

# Build manual
go build -o catalog
```

### Error en build de Node.js (Checkout)
```bash
cd src/checkout

# Limpiar node_modules
rm -rf node_modules package-lock.json

# Reinstalar
npm install

# Build manual
npm run build
```

---

## 📈 Siguientes Pasos

1. ✅ **Construir imágenes** → `./build-all-images.sh`
2. ✅ **Probar localmente** → `docker compose up`
3. ✅ **Subir a Docker Hub** → `./push-to-dockerhub.sh`
4. ✅ **Verificar en Hub** → https://hub.docker.com/u/tu_usuario
5. ✅ **Usar en Kubernetes** → Actualizar manifests secciones 8-14
6. ⏭️ **Migrar a ECR** → `./migrate-to-ecr.sh` (opcional)

---

## 🔗 Referencias

- **Curso DevOps:** Secciones 1-13
- **Código Original:** https://github.com/aws-containers/retail-store-sample-app
- **Docker Hub:** https://hub.docker.com
- **Amazon ECR:** https://aws.amazon.com/ecr/

---

## 💡 Tips y Mejores Prácticas

### Versionado de Imágenes
```bash
# Usar semantic versioning
1.3.0-custom       # Primera versión personalizada
1.3.1-custom       # Con cambios menores
1.3.0-custom-v2    # Segunda iteración
1.3.0-tu_nombre    # Con tu identificador
```

### Tags Recomendados
```bash
# Siempre crear estos tags:
tu_usuario/retail-store-ui:1.3.0-custom  # Versión específica
tu_usuario/retail-store-ui:latest         # Última versión
tu_usuario/retail-store-ui:dev            # Para desarrollo
tu_usuario/retail-store-ui:prod           # Para producción
```

### Multi-arch Images (Avanzado)
```bash
# Si necesitas ARM64 + AMD64
docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64 \
  -t tu_usuario/retail-store-ui:1.3.0-custom --push .
```

---

## 📞 Soporte

Si encuentras problemas:

1. Revisa los logs de Docker: `docker logs <container>`
2. Verifica que el Dockerfile existe en cada carpeta src/
3. Asegúrate de tener suficiente espacio en disco
4. Confirma que Docker Desktop está corriendo
5. Prueba build individual de cada servicio primero

---

## 📝 Changelog

### v1.3.0-custom (2026-03-02)
- ✨ Versión inicial personalizada
- ✨ Basada en retail-store-sample-app v1.3.0
- ✨ Scripts automatizados de build y push
- ✨ Listo para secciones 1-13 del curso

---

## 📄 Licencia

Este proyecto se basa en el **AWS Containers Retail Sample App** que usa licencia MIT.
Tus personalizaciones y builds son tuyos.

---

## 🎉 ¡Listo!

Ya tienes todo preparado para construir tus propias imágenes Docker personalizadas.

**Siguiente comando:** `./build-all-images.sh`

🚀 **¡Empieza a construir!**
