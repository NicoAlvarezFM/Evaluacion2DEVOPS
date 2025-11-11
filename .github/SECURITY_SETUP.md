# Configuración de Branch Protection Rules

Este archivo documenta las reglas de protección que deben configurarse manualmente en GitHub para el branch `main`.

## Configuración Manual Requerida

Para completar la implementación de alertas y bloqueos de seguridad (IE3), configura lo siguiente en:

**GitHub Repository → Settings → Branches → Branch protection rules → Add rule**

### Branch name pattern
```
main
```

### Reglas a Habilitar:

#### ✅ Require a pull request before merging
- [x] Require approvals: 1
- [x] Dismiss stale pull request approvals when new commits are pushed
- [x] Require review from Code Owners

#### ✅ Require status checks to pass before merging
- [x] Require branches to be up to date before merging

**Status checks requeridos:**
- `Build y Tests con JaCoCo`
- `Análisis de Seguridad`
- `Build Docker Image`
- `Security Summary & Gate` (del workflow security-scan.yml)
- `OWASP Dependency Check` (del workflow security-scan.yml)
- `CodeQL Security Analysis` (del workflow security-scan.yml)

#### ✅ Require conversation resolution before merging
- [x] Habilitar para asegurar que todos los comentarios de review sean resueltos

#### ✅ Do not allow bypassing the above settings
- [x] Incluir administradores (recomendado para producción)

#### ✅ Restrict who can push to matching branches
- Opcional: Solo permitir a usuarios específicos o equipos

## Alertas Automáticas Implementadas

### 1. Quality Gate en Pipeline
- ❌ Bloquea el build si OWASP detecta CVSS >= 7
- ❌ Bloquea el build si CodeQL encuentra vulnerabilidades
- ✅ Falla el workflow completo si hay problemas críticos

### 2. Issues Automáticos
- 🚨 Se crea un issue automático cuando falla el análisis de seguridad
- 📋 Incluye detalles del build, resultados y enlaces
- 🏷️ Etiquetas: `security`, `critical`, `bug`

### 3. Comentarios en Pull Requests
- 💬 Comenta automáticamente en PRs con problemas de seguridad
- 🚫 Indica que el PR no puede ser mergeado
- 📊 Muestra resumen de los problemas encontrados

### 4. Dependabot Alerts
- 🔔 Alertas automáticas para dependencias vulnerables
- 📦 PRs automáticos para actualizar dependencias
- ⚠️ Notificaciones por email configurables

### 5. Security Advisories
- 🔒 CodeQL envía resultados a GitHub Security tab
- 📈 Trivy escanea imágenes Docker y reporta vulnerabilidades
- 🔍 Dashboard centralizado en Security → Code scanning alerts

## Notificaciones

### Configurar Notificaciones de Email
En **Settings → Notifications**:
- [x] Dependabot alerts
- [x] Security alerts
- [x] GitHub Actions workflows

### Configurar Notificaciones del Repositorio
En **Watch → Custom**:
- [x] Issues
- [x] Pull requests
- [x] Releases
- [x] Discussions
- [x] Security alerts

## Verificación

Para verificar que todo está configurado:

1. **Crear un PR de prueba** con una dependencia vulnerable
2. **Verificar que el workflow falla** en el job de seguridad
3. **Confirmar que se crea un issue** automáticamente
4. **Verificar que el PR no puede ser mergeado** sin resolver los issues
5. **Comprobar notificaciones** en email y GitHub

## Comandos para Probar

```bash
# Simular dependencia vulnerable en pom.xml (solo para testing)
# Agregar una versión antigua de Spring Boot con CVEs conocidos

# Ejecutar workflow manualmente
gh workflow run security-scan.yml

# Ver estado del último workflow
gh run list --workflow=security-scan.yml

# Ver detalles de un run
gh run view <run-id>
```

## Referencias

- [GitHub Branch Protection](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [GitHub Security Features](https://docs.github.com/en/code-security/getting-started/github-security-features)
- [Dependabot](https://docs.github.com/en/code-security/dependabot)
- [CodeQL](https://codeql.github.com/docs/)
