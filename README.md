<div align="center">

---

## ✨ Características

- 📊 **Dashboard mensual** — balance, ingresos, egresos y comparativa con el mes anterior
- 📈 **Gráfico de tendencias** — evolución de ingresos vs egresos en los últimos meses
- 🍩 **Gráfico por categoría** — distribución de gastos en forma de dona
- ➕ **Registrar movimientos** — título, monto, categoría, fecha y notas opcionales
- ✏️ **Editar y eliminar** — formulario reutilizable para crear y editar
- 🔍 **Búsqueda y filtros** — búsqueda por texto, filtro por tipo (Todos/Ingresos/Egresos) y por categoría
- 📅 **Selector de mes** — navega entre meses para ver el historial
- 🔃 **Ordenación** — por fecha, monto o alfabético
- 📤 **Compartir** — exporta y comparte los datos via `share_plus`
- 💾 **Base de datos local** — SQLite con `sqflite 2.3.2`, sin servidor, sin internet
- 🌙 **Modo oscuro/claro** — sigue la configuración del sistema automáticamente
- 📱 **100% offline** — tus datos nunca salen del dispositivo

---

## 🗂 Estructura del proyecto

```
mi_bolsillo/
├── lib/
│   ├── main.dart                           # Punto de entrada, MaterialApp, tema, localización
│   ├── database/
│   │   └── database_helper.dart            # Singleton SQLite: CRUD, totales, tendencias
│   ├── models/
│   │   └── movimiento_model.dart           # Modelo Movimiento con toMap/fromMap/copyWith
│   ├── screens/
│   │   ├── splash_screen.dart              # Pantalla de carga inicial
│   │   ├── home_screen.dart                # Dashboard: resumen, gráficas, lista y filtros
│   │   ├── form_screen.dart                # Formulario crear/editar movimiento
│   │   └── movimiento_detail_screen.dart   # Vista detalle de un movimiento
│   ├── theme/
│   │   └── app_theme.dart                  # AppPalette (ThemeExtension), tema claro y oscuro
│   ├── utils/
│   │   └── categorias.dart                 # 10 categorías con icono y color
│   └── widgets/
│       ├── resumen_card.dart               # Tarjeta de balance/ingreso/egreso mensual
│       ├── movimiento_tile.dart            # Item de lista con icono de categoría
│       ├── categoria_chart.dart            # Gráfico de dona por categoría
│       ├── tendencia_chart.dart            # Gráfico de líneas de tendencia mensual
│       └── dashboard_skeleton.dart         # Skeleton loading mientras carga datos
├── test/
│   └── widget_test.dart
├── android/
├── ios/
└── pubspec.yaml
```

---

## 🎨 Paleta de colores

### Modo claro

| Token           | Descripción        | Hex         |
| --------------- | ------------------- | ----------- |
| `primary`     | Morado vibrante     | `#5B5AF7` |
| `primaryDark` | Morado oscuro       | `#2F46D8` |
| `accent`      | Teal/turquesa       | `#12B8A6` |
| `background`  | Fondo gris suave    | `#F6F7FB` |
| `surface`     | Blanco puro         | `#FFFFFF` |
| `income`      | Verde ingresos      | `#169B62` |
| `expense`     | Rojo egresos        | `#D64545` |
| `warning`     | Naranja advertencia | `#FFB547` |

### Modo oscuro

| Token          | Descripción      | Hex         |
| -------------- | ----------------- | ----------- |
| `primary`    | Morado suave      | `#8D8CFF` |
| `background` | Fondo muy oscuro  | `#0F1220` |
| `surface`    | Superficie oscura | `#181B2A` |
| `income`     | Verde claro       | `#4ADE80` |
| `expense`    | Rojo claro        | `#FF6B6B` |

---

## 📋 Categorías disponibles

| Icono | Categoría | Disponible en      |
| :---: | ---------- | ------------------ |
|  🍔  | Comida     | Egresos            |
|  🚗  | Transporte | Egresos            |
|  🏠  | Vivienda   | Egresos            |
| ❤️ | Salud      | Egresos            |
|  🎮  | Ocio       | Egresos            |
|  👕  | Ropa       | Egresos            |
|  🎓  | Educación | Egresos            |
|  💼  | Trabajo    | Egresos / Ingresos |
|  💵  | Salario    | Ingresos           |
|  ➕  | Otros      | Egresos / Ingresos |

> Las categorías disponibles en el formulario se filtran automáticamente según el tipo seleccionado (ingreso o egreso).

---

## 🚀 Inicio rápido

### Requisitos previos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) `>= 3.0.0`
- Dart `>= 3.0.0`
- Android Studio / VS Code con extensión Flutter
- Emulador Android / iOS o dispositivo físico

### Instalación

```bash
# 1. Clona el repositorio
git clone https://github.com/RCHUCOYA/mi_bolsillo.git

# 2. Entra al directorio
cd mi_bolsillo

# 3. Instala dependencias
flutter pub get

# 4. Ejecuta la app
flutter run
```

### Build de producción

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS (requiere macOS + Xcode)
flutter build ipa --release
```

---

## 📦 Dependencias

| Paquete                                            | Versión    | Uso                                         |
| -------------------------------------------------- | ----------- | ------------------------------------------- |
| [`sqflite`](https://pub.dev/packages/sqflite)       | `^2.3.2`  | Base de datos SQLite local                  |
| [`path`](https://pub.dev/packages/path)             | `^1.9.0`  | Resolución de rutas del archivo`.db`     |
| [`intl`](https://pub.dev/packages/intl)             | `^0.20.0` | Formato de fechas (`DateFormat`) y moneda |
| [`share_plus`](https://pub.dev/packages/share_plus) | `^13.2.0` | Compartir datos desde el dashboard          |
| `flutter_localizations`                          | SDK         | Localización en español (`es_ES`)       |

**Dev dependencies**

| Paquete           | Versión   | Uso                                |
| ----------------- | ---------- | ---------------------------------- |
| `flutter_lints` | `^6.0.0` | Reglas de estilo Dart recomendadas |

---

## � Base de datos

### Archivo

- **Nombre:** `mibolsillo.db`
- **Ubicación en Android:** `/data/data/com.example.mi_bolsillo/databases/mibolsillo.db`
- **Motor:** SQLite vía `sqflite ^2.3.2`
- **Versión de esquema:** `1`

### Tabla `movimientos`

```sql
CREATE TABLE movimientos (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  titulo    TEXT    NOT NULL,
  monto     REAL    NOT NULL,
  categoria TEXT    NOT NULL,
  fecha     TEXT    NOT NULL,   -- formato: 'yyyy-MM-dd'
  tipo      TEXT    NOT NULL,   -- 'ingreso' | 'egreso'
  notas     TEXT                -- puede ser vacío
);
```

### Modelo Dart

```dart
class Movimiento {
  final int?   id;         // PK autoincrement
  final String titulo;     // Nombre del movimiento
  final double monto;      // Valor positivo
  final String categoria;  // Una de las 10 categorías definidas
  final String fecha;      // 'yyyy-MM-dd'
  final String tipo;       // 'ingreso' | 'egreso'
  final String notas;      // Opcional, default ''
}
```

### Métodos disponibles en `DatabaseHelper`

| Método                                             | Descripción                                      |
| --------------------------------------------------- | ------------------------------------------------- |
| `insertMovimiento(m)`                             | Inserta un movimiento nuevo                       |
| `getAllMovimientos()`                             | Devuelve todos ordenados por fecha DESC           |
| `getMovimientosFiltrados({tipo, categoria, mes})` | Filtra por cualquier combinación                 |
| `updateMovimiento(m)`                             | Actualiza un movimiento existente por id          |
| `deleteMovimiento(id)`                            | Elimina por id                                    |
| `getTotalByTipo(tipo, {mes})`                     | Suma total de ingresos o egresos del mes          |
| `getTotalesPorCategoria({mes, tipo})`             | Mapa`categoria → total` agrupado               |
| `getTotalesPorUltimosMeses(n)`                    | Lista de ingresos/egresos de los últimos n meses |

---

## 🧪 Tests

```bash
# Ejecutar todos los tests
flutter test

# Con cobertura
flutter test --coverage
```

---

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Por favor lee [CONTRIBUTING.md](CONTRIBUTING.md) antes de empezar.

1. **Fork** el repositorio
2. Crea tu rama: `git checkout -b feature/nueva-funcionalidad`
3. Haz commit: `git commit -m "feat: agrega nueva funcionalidad"`
4. Push: `git push origin feature/nueva-funcionalidad`
5. Abre un **Pull Request**

---

## 📄 Licencia

Este proyecto está bajo la licencia **MIT**. Consulta el archivo [LICENSE](LICENSE) para más detalles.

---

<div align="center">
