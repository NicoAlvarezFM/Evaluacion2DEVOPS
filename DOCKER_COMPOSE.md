# Docker Compose - Guia de Uso IE5

Documentacion para la orquestacion de contenedores con Docker Compose.

## Estructura

```
docker-compose.yml          # Version basica (1 instancia)
docker-compose.prod.yml     # Version con orquestacion (3 instancias + load balancer)
nginx/nginx.conf            # Configuracion del load balancer
```

## Arquitectura de Orquestacion

### docker-compose.prod.yml
- 3 instancias del microservicio (bdget-app-1, bdget-app-2, bdget-app-3)
- 1 Load Balancer Nginx
- Red aislada para comunicacion interna
- Health checks automaticos
- Limites de recursos (CPU/memoria)

## Despliegue

### Version Simple (1 instancia)
```bash
docker-compose up -d
```

### Version con Orquestacion (3 instancias + LB)
```bash
docker-compose -f docker-compose.prod.yml up -d
```

## Acceso

### Version Simple
- API: http://localhost:8080
- H2 Console: http://localhost:8080/h2-console
- Actuator Health: http://localhost:8080/actuator/health

### Version con Orquestacion
- Load Balancer: http://localhost
- Instancia 1: http://localhost:8081
- Instancia 2: http://localhost:8082
- Instancia 3: http://localhost:8083

## Verificacion

```bash
# Ver estado de contenedores
docker-compose -f docker-compose.prod.yml ps

# Ver logs
docker-compose -f docker-compose.prod.yml logs -f

# Ver logs de una instancia especifica
docker-compose -f docker-compose.prod.yml logs -f bdget-app-1

# Ver estadisticas de recursos
docker stats

# Verificar health checks
docker inspect bdget-app-1 | grep -A 10 "Health"
```

## Balanceo de Carga

El Nginx usa algoritmo **least_conn** (menor conexiones) para distribuir las peticiones entre las 3 instancias.

```bash
# Probar balanceo (ejecutar varias veces)
curl http://localhost/actuator/info

# Ver estadisticas de nginx
curl http://localhost/nginx-status
```

## Escalamiento

### Detener una instancia
```bash
docker-compose -f docker-compose.prod.yml stop bdget-app-2
```

### Reiniciar instancia
```bash
docker-compose -f docker-compose.prod.yml start bdget-app-2
```

### Ver distribucion de carga
```bash
# Logs de nginx
docker-compose -f docker-compose.prod.yml logs nginx-lb
```

## Limpieza

```bash
# Detener y eliminar contenedores
docker-compose -f docker-compose.prod.yml down

# Eliminar tambien volumenes y red
docker-compose -f docker-compose.prod.yml down -v

# Eliminar imagenes
docker rmi bdget-microservicio:latest
```

## Troubleshooting

### Contenedor no inicia
```bash
# Ver logs detallados
docker-compose -f docker-compose.prod.yml logs bdget-app-1

# Inspeccionar contenedor
docker inspect bdget-app-1
```

### Health check falla
```bash
# Verificar endpoint dentro del contenedor
docker exec bdget-app-1 wget -O- http://localhost:8080/actuator/health
```

### Load balancer no balancea
```bash
# Verificar configuracion nginx
docker exec bdget-nginx-lb cat /etc/nginx/nginx.conf

# Ver logs de nginx
docker-compose -f docker-compose.prod.yml logs nginx-lb
```

## Monitoring

```bash
# Ver uso de recursos en tiempo real
docker stats bdget-app-1 bdget-app-2 bdget-app-3 bdget-nginx-lb

# Ver red
docker network inspect bdget-network

# Ver volumenes
docker volume ls
```
