# 🤝 Guía de Contribución — MiBolsillo

¡Gracias por tu interés en contribuir a MiBolsillo! Este documento explica cómo puedes ayudar.

---

## 📋 Tabla de contenidos

- [Código de conducta](#código-de-conducta)
- [¿Cómo contribuir?](#cómo-contribuir)
- [Configuración del entorno](#configuración-del-entorno)
- [Convenciones de commits](#convenciones-de-commits)
- [Estilo de código](#estilo-de-código)
- [Proceso de Pull Request](#proceso-de-pull-request)

---

## Código de conducta

Este proyecto sigue el principio de respeto mutuo. Se espera que todos los participantes mantengan un ambiente inclusivo y profesional.

---

## ¿Cómo contribuir?

Hay varias formas de contribuir:

- 🐛 **Reportar bugs** — abre un [issue](../../issues/new?template=bug_report.md)
- 💡 **Sugerir mejoras** — abre un [issue](../../issues/new?template=feature_request.md)
- 🔧 **Enviar código** — abre un Pull Request
- 📝 **Mejorar documentación** — edita el README u otros archivos `.md`
- ⭐ **Dar una estrella** — ayuda a que más personas descubran el proyecto

---

## Configuración del entorno

```bash
# 1. Haz fork del repositorio en GitHub

# 2. Clona tu fork
git clone https://github.com/TU_USUARIO/mi_bolsillo.git
cd mi_bolsillo

# 3. Agrega el repositorio original como upstream
git remote add upstream https://github.com/OWNER/mi_bolsillo.git

# 4. Instala dependencias
flutter pub get

# 5. Verifica que todo funcione
flutter analyze
flutter test
```

---

## Convenciones de commits

Usamos [Conventional Commits](https://www.conventionalcommits.org/):

| Prefijo | Uso |
|---|---|
| `feat:` | Nueva funcionalidad |
| `fix:` | Corrección de bug |
| `docs:` | Cambios en documentación |
| `style:` | Formato, sin cambios de lógica |
| `refactor:` | Refactorización de código |
| `test:` | Agregar o modificar tests |
| `chore:` | Tareas de mantenimiento |

**Ejemplos:**
```
feat: agregar pantalla de estadísticas por categoría
fix: corregir cálculo de balance cuando no hay movimientos
docs: actualizar instrucciones de instalación en README
```

---

## Estilo de código

- Sigue las guías oficiales de [Dart](https://dart.dev/guides/language/effective-dart/style)
- Ejecuta `flutter analyze` antes de cada commit — debe pasar sin errores ni warnings
- Usa `const` donde sea posible
- Nombres de variables y funciones en **camelCase** en español
- Nombres de clases en **PascalCase**
- Ancho máximo de línea: **100 caracteres**

---

## Proceso de Pull Request

1. Sincroniza tu fork con el upstream:
   ```bash
   git fetch upstream
   git checkout main
   git merge upstream/main
   ```

2. Crea una rama descriptiva:
   ```bash
   git checkout -b feat/estadisticas-categorias
   ```

3. Realiza tus cambios y commitea siguiendo las convenciones

4. Asegúrate de que los tests pasan:
   ```bash
   flutter test
   flutter analyze
   ```

5. Abre el Pull Request completando la plantilla proporcionada

6. Espera la revisión — puede haber comentarios o solicitudes de cambio

---

## 🙏 ¡Gracias por contribuir!
