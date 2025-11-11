# Microservicio de Gestion de Estudiantes - Evaluacion DevOps

Microservicio desarrollado con Spring Boot 3.3.7 y Java 21 que implementa un sistema de gestion de estudiantes con pipeline CI/CD completo.

## Tabla de Contenidos

- [Tecnologias](#tecnologias)
- [Arquitectura](#arquitectura)
- [Pipeline CI/CD](#pipeline-cicd)
- [Instalacion y Ejecucion](#instalacion-y-ejecucion)
- [Endpoints](#endpoints)
- [Testing y Cobertura](#testing-y-cobertura)
- [Seguridad](#seguridad)
- [Despliegue](#despliegue)
- [Trazabilidad](#trazabilidad)
- [Garantia de Calidad](#garantia-de-calidad)

## Tecnologias

- **Java**: 21 LTS
- **Spring Boot**: 3.3.7
- **Base de Datos**: H2 (in-memory)
- **Build Tool**: Maven 3.9
- **Contenedores**: Docker
- **Orquestacion**: Docker Compose
- **CI/CD**: GitHub Actions
- **Testing**: JUnit 5, Mockito, MockMvc
- **Cobertura**: JaCoCo
- **Seguridad**: Dependabot, OWASP Dependency Check, CodeQL, Snyk

## Arquitectura

### Estructura del Proyecto

```
src/
├── main/
│   ├── java/com/example/bdget/
│   │   ├── BdgetApplication.java
│   │   ├── controller/
│   │   │   └── StudentController.java
│   │   ├── model/
│   │   │   └── Student.java
│   │   ├── repository/
│   │   │   └── StudentRepository.java
│   │   └── service/
│   │       ├── StudentService.java
│   │       └── StudentServiceImpl.java
│   └── resources/
│       └── application.properties
└── test/
    └── java/com/example/bdget/
        ├── BdgetApplicationTests.java
        ├── controller/
        │   └── StudentControllerTest.java
        ├── model/
        │   └── StudentModelTest.java
        └── service/
            └── StudentServiceImplTest.java
```

### Modelo de Datos

**Student**
- id: Long (auto-generado)
- name: String
- email: String
- age: Integer

## Pipeline CI/CD

El proyecto implementa dos workflows principales de GitHub Actions:

### 1. CI/CD Pipeline (ci-cd.yml)

Ejecuta automaticamente en cada push a main/develop y en pull requests.

**Jobs:**

1. **Build and Test**
   - Compila el proyecto con Maven
   - Ejecuta 13 tests unitarios con JUnit
   - Genera reporte de cobertura con JaCoCo
   - Sube artefactos de tests y cobertura

2. **Security Scan**
   - Analiza dependencias con OWASP Dependency Check
   - Bloquea el build si detecta vulnerabilidades criticas (CVSS >= 7)
   - Genera reporte de seguridad

3. **Build Docker**
   - Construye imagen Docker con multi-stage build
   - Sube imagen a GitHub Container Registry
   - Escanea imagen con Trivy
   - Envia resultados a GitHub Security

4. **Deploy**
   - Despliega en environment "development"
   - Solo se ejecuta en branch main
   - Despliegue simulado con Docker Compose

5. **Notify**
   - Reporta estado del pipeline
   - Falla si alguno de los jobs criticos fallo

### 2. Security Scan Pipeline (security-scan.yml)

Ejecuta semanalmente y en cada push.

**Jobs:**

1. **Snyk Scan** - Analisis de vulnerabilidades con Snyk
2. **OWASP Scan** - Dependency Check con threshold CVSS 7
3. **CodeQL Analysis** - Analisis estatico de codigo
4. **Security Summary** - Quality gate que bloquea si hay problemas criticos

### Quality Gates

El pipeline bloquea automaticamente el build si:
- Los tests unitarios fallan
- La cobertura de codigo no se genera
- OWASP detecta vulnerabilidades con CVSS >= 7
- CodeQL encuentra problemas de seguridad criticos
- El build de Docker falla

## Instalacion y Ejecucion

### Requisitos Previos

- Java 21
- Maven 3.9+
- Docker (opcional)
- Docker Compose (opcional)

### Ejecucion Local

```bash
# Clonar repositorio
git clone https://github.com/NicoAlvarezFM/Evaluacion2DEVOPS.git
cd Evaluacion2DEVOPS

# Compilar proyecto
./mvnw clean install

# Ejecutar aplicacion
./mvnw spring-boot:run
```

La aplicacion estara disponible en: http://localhost:8080

### Ejecucion con Docker

```bash
# Construir imagen
docker build -t bdget-microservicio:latest .

# Ejecutar contenedor
docker run -p 8080:8080 bdget-microservicio:latest
```

### Ejecucion con Docker Compose

**Version simple (1 instancia):**
```bash
docker-compose up -d
```

**Version con orquestacion (3 instancias + Load Balancer):**
```bash
docker-compose -f docker-compose.prod.yml up -d
```

Acceso con load balancer: http://localhost

## Endpoints

### API REST

```
GET    /students           - Obtener todos los estudiantes
GET    /students/{id}      - Obtener estudiante por ID
POST   /students           - Crear nuevo estudiante
PUT    /students/{id}      - Actualizar estudiante
DELETE /students/{id}      - Eliminar estudiante
```

### Actuator

```
GET /actuator/health        - Estado de la aplicacion
GET /actuator/metrics       - Metricas de la aplicacion
GET /actuator/info          - Informacion de la aplicacion
```

### H2 Console

```
URL: http://localhost:8080/h2-console
JDBC URL: jdbc:h2:mem:testdb
User: sa
Password: (vacio)
```

### Ejemplos de Uso

**Crear estudiante:**
```bash
curl -X POST http://localhost:8080/students \
  -H "Content-Type: application/json" \
  -d '{"name":"Juan Perez","email":"juan@example.com","age":20}'
```

**Listar estudiantes:**
```bash
curl http://localhost:8080/students
```

**Obtener estudiante por ID:**
```bash
curl http://localhost:8080/students/1
```

## Testing y Cobertura

### Tests Unitarios

El proyecto incluye 13 tests unitarios:

- **StudentControllerTest**: 5 tests (operaciones CRUD)
- **StudentModelTest**: 1 test (validacion de entidad)
- **StudentServiceImplTest**: 6 tests (logica de negocio)
- **BdgetApplicationTests**: 1 test (contexto Spring)

### Ejecutar Tests

```bash
# Ejecutar todos los tests
./mvnw test

# Ejecutar tests con cobertura
./mvnw verify

# Ver reporte de cobertura
open target/site/jacoco/index.html
```

### Cobertura de Codigo

JaCoCo genera un reporte completo de cobertura que incluye:
- Porcentaje de cobertura de lineas
- Porcentaje de cobertura de ramas
- Analisis por clase y metodo

El reporte se encuentra en: `target/site/jacoco/index.html`

## Seguridad

### Herramientas Implementadas

1. **Dependabot**
   - Actualizacion automatica de dependencias
   - Alertas de seguridad
   - Pull requests automaticos

2. **OWASP Dependency Check**
   - Analisis de vulnerabilidades en dependencias
   - Threshold: CVSS >= 7
   - Bloquea build si encuentra problemas criticos

3. **Snyk**
   - Escaneo de vulnerabilidades
   - Monitoreo continuo
   - Integracion con GitHub Security

4. **CodeQL**
   - Analisis estatico de codigo
   - Deteccion de patrones inseguros
   - Reportes en GitHub Security tab

5. **Trivy**
   - Escaneo de imagenes Docker
   - Deteccion de vulnerabilidades en capas
   - Formato SARIF para GitHub

### Alertas y Bloqueos

El sistema implementa quality gates que:
- Bloquean el merge si hay vulnerabilidades criticas
- Crean issues automaticos cuando fallan los escaneos
- Comentan en PRs con problemas de seguridad
- Requieren resolucion antes de continuar

Ver `.github/SECURITY_SETUP.md` para configuracion detallada.

## Despliegue

### Containerizacion

**Dockerfile** implementa multi-stage build:
- Stage 1: Build con Maven 3.9 y JDK 21
- Stage 2: Runtime con JRE 21 Alpine
- Usuario no-root para seguridad
- Health check integrado

### Orquestacion

**docker-compose.prod.yml** implementa:
- 3 instancias del microservicio
- Nginx como Load Balancer
- Algoritmo least_conn para distribucion
- Health checks automaticos
- Resource limits (CPU/memoria)
- Red aislada

Ver `DOCKER_COMPOSE.md` para instrucciones detalladas.

### GitHub Container Registry

Las imagenes se publican automaticamente en:
```
ghcr.io/nicoalvarezfm/bdget-microservicio:latest
ghcr.io/nicoalvarezfm/bdget-microservicio:main-<sha>
```

## Trazabilidad

### Trazabilidad de Codigo

1. **Control de Versiones**
   - Git para control de versiones
   - Branch main protegido
   - Pull requests obligatorios
   - Code reviews requeridos

2. **Commits**
   - Mensajes descriptivos
   - Referencias a issues cuando aplica
   - Firma de commits (recomendado)

3. **Tags y Releases**
   - Tags para versiones
   - Releases con notas de cambios
   - Changelog automatico

### Trazabilidad del Pipeline

1. **GitHub Actions**
   - Cada ejecucion tiene ID unico
   - Logs completos de cada job
   - Artifacts guardados 30 dias
   - Historia de ejecuciones

2. **Artifacts**
   - Reportes de tests
   - Reportes de cobertura JaCoCo
   - Reportes de seguridad OWASP
   - Logs de build

3. **Docker Images**
   - Tags con SHA del commit
   - Labels con metadata (fecha, version, commit)
   - Registro en GitHub Container Registry

### Trazabilidad de Issues

1. **Issues Automaticos**
   - Creados cuando falla seguridad
   - Labels: security, critical, bug
   - Asignacion automatica
   - Links a workflows y artifacts

2. **Pull Requests**
   - Comentarios automaticos del pipeline
   - Estado de checks visible
   - Bloqueo si no pasan quality gates

## Garantia de Calidad

### Proceso de QA

1. **Testing Automatizado**
   - 13 tests unitarios ejecutados en cada commit
   - Cobertura de codigo medida con JaCoCo
   - Tests de integracion con MockMvc
   - Falla el build si los tests no pasan

2. **Analisis de Codigo**
   - CodeQL para analisis estatico
   - Deteccion de code smells
   - Verificacion de best practices
   - Reportes en GitHub Security

3. **Analisis de Seguridad**
   - 3 herramientas complementarias (OWASP, Snyk, CodeQL)
   - Escaneo de dependencias
   - Escaneo de imagenes Docker
   - Threshold de seguridad: CVSS >= 7

4. **Quality Gates**
   - Build bloqueado si tests fallan
   - Build bloqueado si hay vulnerabilidades criticas
   - PR bloqueado hasta resolver problemas
   - Aprobaciones requeridas para merge

### Metricas de Calidad

1. **Cobertura de Tests**
   - Medida con JaCoCo
   - Reporte visual disponible
   - Tendencias trackeadas

2. **Vulnerabilidades**
   - Dashboard en GitHub Security
   - Alertas automaticas
   - Tracking de resolucion

3. **Performance del Pipeline**
   - Tiempo de ejecucion
   - Tasa de exito/fallo
   - Tendencias historicas

### Documentacion

- README.md (este archivo)
- DOCKER_COMPOSE.md - Guia de orquestacion
- .github/SECURITY_SETUP.md - Configuracion de seguridad
- Javadoc en codigo fuente
- Comentarios en workflows

## Estructura del Repositorio

```
.
├── .github/
│   ├── workflows/
│   │   ├── ci-cd.yml              # Pipeline principal
│   │   └── security-scan.yml      # Pipeline de seguridad
│   ├── dependabot.yml             # Configuracion Dependabot
│   └── SECURITY_SETUP.md          # Documentacion de seguridad
├── nginx/
│   └── nginx.conf                 # Configuracion load balancer
├── src/                           # Codigo fuente
├── target/                        # Archivos compilados
├── Dockerfile                     # Imagen Docker
├── docker-compose.yml             # Compose simple
├── docker-compose.prod.yml        # Compose con orquestacion
├── DOCKER_COMPOSE.md              # Guia Docker Compose
├── pom.xml                        # Configuracion Maven
└── README.md                      # Este archivo
```

## Contribuir

1. Fork del repositorio
2. Crear branch para feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit de cambios (`git commit -m 'Agregar nueva funcionalidad'`)
4. Push al branch (`git push origin feature/nueva-funcionalidad`)
5. Crear Pull Request

Los PRs deben pasar todos los quality gates antes de ser mergeados.

## Licencia

Este proyecto es parte de una evaluacion academica.

## Autor

Nicolas Alvarez - [NicoAlvarezFM](https://github.com/NicoAlvarezFM)

## Referencias

- [Spring Boot Documentation](https://docs.spring.io/spring-boot/docs/current/reference/html/)
- [Docker Documentation](https://docs.docker.com/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [OWASP Dependency Check](https://owasp.org/www-project-dependency-check/)
