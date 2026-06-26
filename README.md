<div align="center">

<img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
<img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white"/>
<img src="https://img.shields.io/badge/SQLite-Local%20DB-003B57?style=for-the-badge&logo=sqlite&logoColor=white"/>
<img src="https://img.shields.io/badge/License-MIT-6C63FF?style=for-the-badge"/>
<img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=for-the-badge"/>

# 💜 MiBolsillo

**App móvil de gestión de gastos e ingresos personales**  
Lleva el control de tus finanzas de forma simple, rápida y sin conexión a internet.

[✨ Características](#-características) • [🚀 Inicio rápido](#-inicio-rápido) • [🗂 Estructura](#-estructura-del-proyecto) • [🤝 Contribuir](#-contribuir)

</div>

---

## ✨ Características

- 📊 **Dashboard mensual** — balance, ingresos y egresos del mes en tiempo real
- ➕ **Registrar movimientos** — título, monto, categoría, fecha y notas
- ✏️ **Editar y eliminar** — tap para editar, long press para eliminar
- 🔍 **Filtros inteligentes** — por tipo (ingreso/egreso) y por categoría
- 💾 **Base de datos local** — SQLite con `sqflite`, sin necesidad de internet
- 🎨 **Diseño moderno** — Material 3, gradientes morado + azul, animaciones suaves
- 📱 **100% offline** — tus datos nunca salen del dispositivo

---

## 🗂 Estructura del proyecto

```
mi_bolsillo/
├── lib/
│   ├── main.dart                      # Punto de entrada, tema global
│   ├── database/
│   │   └── database_helper.dart       # Singleton SQLite, CRUD + resúmenes
│   ├── models/
│   │   └── movimiento_model.dart      # Modelo de datos con toMap/fromMap
│   ├── screens/
│   │   ├── home_screen.dart           # Pantalla principal con lista y filtros
│   │   └── form_screen.dart           # Formulario crear/editar movimiento
│   ├── utils/
│   │   └── categorias.dart            # 10 categorías fijas con icono y color
│   └── widgets/
│       ├── resumen_card.dart          # Tarjeta de balance mensual
│       └── movimiento_tile.dart       # Item de lista con acciones
└── test/
    └── widget_test.dart
```

---

## 🎨 Paleta de colores

| Token | Color | Hex |
|---|---|---|
| Primary | Morado vibrante | `#6C63FF` |
| Secondary | Azul fuerte | `#3D5AF1` |
| Background | Blanco azulado | `#F4F6FF` |
| Ingreso | Verde | `#4CAF50` |
| Egreso | Rojo | `#E53935` |
| Text | Casi negro | `#1A1A2E` |

---

## 📋 Categorías disponibles

| Icono | Categoría | Icono | Categoría |
|:---:|---|:---:|---|
| 🍔 | Comida | 🎮 | Ocio |
| 🚗 | Transporte | 👕 | Ropa |
| 🏠 | Vivienda | 🎓 | Educación |
| ❤️ | Salud | 💼 | Trabajo |
| 💵 | Salario | ➕ | Otros |

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
git clone https://github.com/TU_USUARIO/mi_bolsillo.git

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

| Paquete | Versión | Uso |
|---|---|---|
| [`sqflite`](https://pub.dev/packages/sqflite) | `^2.3.2` | Base de datos SQLite local |
| [`path`](https://pub.dev/packages/path) | `^1.9.0` | Resolución de rutas de archivo |
| [`intl`](https://pub.dev/packages/intl) | `^0.20.0` | Formato de fechas y moneda |
| `flutter_localizations` | SDK | Localización en español |

---

## 🗄️ Modelo de datos

```dart
class Movimiento {
  final int?   id;         // PK autoincrement
  final String titulo;     // Nombre del movimiento
  final double monto;      // Mayor a 0
  final String categoria;  // De la lista fija de categorías
  final String fecha;      // Formato yyyy-MM-dd
  final String tipo;       // 'ingreso' | 'egreso'
  final String notas;      // Opcional
}
```

**Tabla SQL:** `movimientos` en `mibolsillo.db`

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

⭐ Si este proyecto te fue útil, ¡dale una estrella en GitHub!

</div>
