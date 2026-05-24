# GUARDIAN AI — MASTER CONTEXT

## Filosofía del Proyecto

Guardian AI es una plataforma clínica multiplataforma offline-first diseñada para profesionales de la salud en entornos con conectividad limitada o nula. La aplicación prioriza la privacidad del paciente mediante un modelo de conocimiento cero (zero-knowledge): ningún dato clínico sale del dispositivo del usuario sin su consentimiento explícito. Toda la información se almacena localmente con cifrado de extremo a extremo, y el procesamiento de IA se realiza directamente en el dispositivo mediante modelos de lenguaje locales.

Los principios fundamentales son:
- **Offline-first**: Funcionalidad completa sin conexión a internet
- **Zero-knowledge**: El usuario tiene control total sobre sus datos
- **Privacidad por diseño**: Cifrado en reposo y en tránsito
- **Código abierto**: Transparencia total en el manejo de datos clínicos

## Stack Tecnológico Oficial

| Capa | Tecnología |
|------|-----------|
| **Lenguaje** | Dart 3.2+ |
| **Framework** | Flutter (multiplataforma: Android, iOS, Web, Linux, Windows, macOS) |
| **UI** | Material 3 (M3) con diseño oscuro personalizado |
| **Estado** | Riverpod (flutter_riverpod + riverpod_annotation) |
| **Arquitectura** | Clean Architecture + Domain-Driven Design |
| **Navegación** | GoRouter |
| **Base de datos local** | SQLCipher (SQLite cifrado) vía sqflite + sqlcipher_flutter_libs |
| **Cifrado** | AES-256 (encrypt + pointycastle), flutter_secure_storage |
| **Autenticación** | biometric (local_auth) + PIN de 6 dígitos |
| **IA local** | llama.cpp (binding nativo) con modelo BioMistral 7B Q4 |
| **Exportación** | PDF (pdf + printing), TXT (share_plus) |
| **UI/UX** | flutter_animate, shimmer, lottie, google_fonts, flutter_svg |
| **Responsive** | responsive_framework |

## Arquitectura

### Clean Architecture

El proyecto sigue estrictamente los principios de Clean Architecture con tres capas principales:

```
lib/
├── core/                  # Capa transversal
│   ├── constants/         # Constantes, colores, dimensiones
│   ├── errors/            # Excepciones y failures
│   ├── extensions/        # Extensiones de Dart/Flutter
│   ├── routing/           # Configuración de GoRouter
│   ├── theme/             # Tema Material 3
│   └── utils/             # Utilidades globales
├── shared/                # Widgets y modelos compartidos
│   ├── models/            # Modelos de datos (VitalSigns, Medication, etc.)
│   ├── providers/         # Providers globales de Riverpod
│   ├── utils/             # Validators, constantes
│   └── widgets/           # Widgets reutilizables
└── modules/               # Módulos funcionales (ver abajo)
    └── <modulo>/
        ├── data/          # Capa de datos
        │   ├── datasources/  # Fuentes de datos locales
        │   ├── models/       # Modelos de serialización (DTOs)
        │   └── repositories/ # Implementaciones de repositorios
        ├── domain/        # Capa de dominio
        │   ├── entities/     # Entidades de negocio
        │   ├── repositories/ # Interfaces de repositorio
        │   └── usecases/     # Casos de uso
        └── presentation/  # Capa de presentación
            ├── pages/        # Pantallas
            ├── providers/    # Providers del módulo
            └── widgets/      # Widgets del módulo
```

### Principios SOLID

- **S** — Responsabilidad única: cada caso de uso realiza una única operación clínica
- **O** — Abierto/cerrado: los repositorios se extienden vía inyección de dependencias
- **L** — Sustitución de Liskov: las implementaciones concretas son intercambiables
- **I** — Segregación de interfaces: repositorios con métodos específicos
- **D** — Inversión de dependencias: las capas superiores dependen de abstracciones

### Patrón Repositorio

Cada módulo define una interfaz de repositorio en `domain/repositories/` y su implementación concreta en `data/repositories/`. Las fuentes de datos locales en `data/datasources/` manejan la persistencia con SQLCipher.

### Inyección de Dependencias con Riverpod

Los providers de Riverpod se organizan por módulo en `presentation/providers/`, con providers globales en `shared/providers/`. Se utilizan `StateNotifierProvider` y `FutureProvider` según la necesidad.

## Estructura del Proyecto

```
guardian_ai/
├── android/
├── assets/
│   ├── fonts/           # Inter, SF Pro, IBM Plex Sans
│   ├── icons/           # Iconos SVG
│   └── images/          # Imágenes y assets gráficos
├── ios/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_constants.dart
│   │   │   └── app_dimensions.dart
│   │   ├── errors/
│   │   │   ├── app_exceptions.dart
│   │   │   └── failures.dart
│   │   ├── extensions/
│   │   │   └── context_extensions.dart
│   │   ├── routing/
│   │   │   └── app_router.dart
│   │   ├── theme/
│   │   │   └── app_theme.dart
│   │   └── utils/
│   │       ├── date_utils.dart
│   │       └── utils.dart          # Barrel export
│   ├── shared/
│   │   ├── models/
│   │   │   ├── clinical_notes_model.dart
│   │   │   ├── medication_model.dart
│   │   │   └── vital_signs_model.dart
│   │   ├── providers/
│   │   │   ├── auth_state_provider.dart
│   │   │   ├── providers.dart
│   │   │   └── theme_provider.dart
│   │   ├── utils/
│   │   │   ├── constants.dart
│   │   │   └── validators.dart
│   │   └── widgets/
│   │       ├── clinical_app_bar.dart
│   │       ├── clinical_button.dart
│   │       ├── clinical_card.dart
│   │       ├── clinical_input.dart
│   │       ├── empty_state.dart
│   │       ├── loading_overlay.dart
│   │       ├── section_header.dart
│   │       └── status_badge.dart
│   ├── modules/
│   │   ├── ai/                     # Guardian Core
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   ├── models/
│   │   │   │   └── repositories/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       ├── providers/
│   │   │       └── widgets/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   ├── models/
│   │   │   │   └── repositories/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/
│   │   │   └── presentation/       # Auth UI (login, PIN, biometrics)
│   │   ├── calculators/            # Guardian Calc
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   └── repositories/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   ├── calculation_result.dart
│   │   │   │   │   └── clinical_formula.dart
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/
│   │   │   │       ├── calculate_body_surface.dart
│   │   │   │       ├── calculate_dose.dart
│   │   │   │       ├── calculate_drip_rate.dart
│   │   │   │       ├── calculate_fluid_balance.dart
│   │   │   │       ├── calculate_infusion.dart
│   │   │   │       ├── calculate_max_dose_check.dart
│   │   │   │       ├── calculate_pediatric_dose.dart
│   │   │   │       └── calculate_vasopressor.dart
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       ├── providers/
│   │   │       └── widgets/
│   │   ├── dashboard/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── logs/                   # Guardian Shift
│   │   │   └── ...
│   │   └── patients/
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   └── main.dart
├── models/                         # Modelos GGUF para IA local
├── native/                         # Código nativo (llama.cpp bindings)
├── test/
│   ├── integration/
│   ├── unit/
│   │   ├── calculators/
│   │   ├── models/
│   │   └── shared/
│   └── widget/
├── pubspec.yaml
└── MASTER_CONTEXT.md
```

## Módulos

### Guardian Calc — Calculadoras Clínicas

Módulo de cálculo clínico con los siguientes casos de uso:

| Caso de Uso | Fórmula | Validaciones |
|-------------|---------|-------------|
| `CalculateDose` | `peso × dosisPorKg` | Peso 0.5-300 kg, dosis/kg ≤ 10000 |
| `CalculateInfusion` | `(dosis × peso × 60) / concentración` | Peso, dosis, concentración > 0; rate ≤ 5000 mL/h |
| `CalculateDripRate` | `(volumen × factor) / tiempo` | Volumen ≤ 5000 mL, tiempo ≤ 1440 min |
| `CalculateBodySurface` | `√((altura × peso) / 3600)` Mosteller | Peso 0.5-300, altura 10-250 cm |
| `CalculateFluidBalance` | `ingresos - egresos` | Input/output ≤ 20000 mL, no negativos |
| `CalculatePediatricDose` | `(peso / 70) × dosisAdulta` Clark | Peso 0.5-120 kg, dosis adulta ≤ 10000 |
| `CalculateVasopressor` | `(dosis × peso × 60) / concentración` | 5 vasopresores predefinidos |
| `CalculateMaxDoseCheck` | Comparación con tabla de referencia | 10 medicamentos en base de datos |

### Guardian Core — Motor de IA Local

- Modelo: BioMistral 7B Q4 (quantized GGUF)
- Motor: llama.cpp vía bindings nativos
- Contexto: 2048 tokens, máximo 512 tokens de salida
- Temperatura: 0.3 (baja para respuestas clínicas predecibles)
- Operaciones: análisis de signos vitales, análisis de medicación, resumen clínico, respuesta a preguntas
- Privacidad: 100% offline, sin llamadas a APIs externas

### Guardian Shift — Libro de Guardia

- Registro de eventos clínicos durante el turno
- Línea de tiempo de actividades
- Dashboard con indicadores clave
- Gestión de tareas pendientes

### Guardian Engine — Sistema

- Configuración de la aplicación
- Tema oscuro único
- Gestión de sesión y timeout
- Exportación de datos (PDF, TXT)
- Cifrado y seguridad

## Reglas de Seguridad

1. **Offline-first**: Toda la funcionalidad crítica opera sin conexión
2. **SQLCipher**: Base de datos local cifrada con AES-256
3. **AES-256**: Cifrado de campos sensibles en reposo
4. **Autenticación biométrica**: Huella digital / Face ID
5. **PIN de 6 dígitos**: Acceso secundario con bloqueo tras 5 intentos fallidos
6. **Bloqueo por inactividad**: Sesión expira tras 5 minutos; cierre completo tras 12 horas
7. **Memoria segura**: Limpieza de datos sensibles en memoria
8. **Sin dependencias cloud**: Ningún dato clínico se envía a servidores externos
9. **Almacenamiento seguro**: flutter_secure_storage para tokens y credenciales

## Reglas de UI

### Modo Oscuro
- Único modo disponible (no hay modo claro)
- Fondos oscuros para reducir fatiga visual en entornos clínicos con poca luz

### Paleta de Colores
- **Clinical Blue** `#3BA4FF` — Acciones primarias, enlaces, información
- **Monitor Green** `#00D17A` — Estados normales, OK, estable
- **Alert Red** `#FF4D4D` — Alertas, crítico, error
- **Warning Amber** `#FFB347` — Advertencias
- **Bg Primary** `#0B0F14` — Fondo principal
- **Bg Card** `#1A212B` — Superficies de tarjetas
- **Text Primary** `#E8EDF5` — Texto principal

### Tipografía
- **Inter** — Texto de interfaz y UI general
- **SF Pro** — Texto clínico y datos numéricos
- **IBM Plex Sans** — Código, dosis, valores técnicos

### Touch Targets
- Mínimo 48×48 dp (compatible con guantes)
- Espaciado generoso entre elementos interactivos

### Accesibilidad
- Alto contraste en toda la interfaz
- Legible en condiciones de poca luz (modo nocturno)
- Texto clínico en tamaños ≥ 14 sp

### Responsive
- **Mobile**: Layout de una columna (< 600px)
- **Tablet**: Layout de dos columnas (600-1024px)
- **Desktop**: Layout de tres columnas (> 1024px)

## Guías de Código

### Arquitectura
- **Clean Architecture**: Las capas domain/data/presentation deben mantenerse estrictamente separadas
- **Riverpod**: Todo el estado debe manejarse con Riverpod; evitar `setState` en componentes complejos
- **Casos de uso**: Cada caso de uso debe tener una única responsabilidad y estar unit-testado

### Estilo
- Todos los textos de UI deben estar en **español** (incluyendo descripciones, errores, labels)
- Nombres de clases, métodos y variables en **inglés** (camelCase)
- Archivos en **snake_case** (estándar Dart)

### Testing
- Todos los cálculos clínicos deben tener tests unitarios
- Usar `flutter_test` para tests de unidades y widgets
- Usar `mocktail` para mocks
- Los tests deben cubrir: caso normal, casos borde, y errores esperados

### Manejo de Errores
- Usar `ValidationException` para errores de validación de entrada
- Usar `CalculationException` para errores en cálculos
- Todos los casos de uso deben lanzar excepciones tipadas
- La capa de presentación debe manejar todos los estados: loading, data, error, empty

### Prohibiciones
- **No Firebase** para datos clínicos (solo permitido para analytics no clínicos con consentimiento)
- **No llamadas a APIs externas** para procesamiento de datos de pacientes
- **No almacenamiento en cloud** de información médica sin cifrado de extremo a extremo
