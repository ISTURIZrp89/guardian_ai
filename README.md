# Guardian AI

**Monitor Clínico Inteligente** — App Flutter multiplataforma con calculadoras clínicas, chat IA (local/cloud), autenticación PIN + Google, y suscripciones premium.

## Stack

| Capa | Tecnología |
|------|-----------|
| Framework | Flutter 3.27.4 / Dart 3.6.2 |
| Estado | Riverpod 2.x |
| Rutas | GoRouter 14.x |
| DB local | sqflite + sqlcipher (cifrado) |
| Auth | Firebase Auth + Google Sign-In |
| IA local | GGUF (BioMistral, Meditron, ClinicalCamel via Hugging Face) |
| UI | Material 3, tema oscuro clínico |
| Tests | 114 unit tests (mocktail) |

## Paleta

- `#0B0F14` deepBlack / `#3BA4FF` clinicalBlue / `#00D17A` monitorGreen / `#FF4D4D` alertRed
- Fondo: `#141A21` secondary / `#1A212B` card / `#1E2631` input
- Texto: `#E8EDF5` primary / `#8E9BB0` secondary / `#4A5363` disabled

## Módulos

```
lib/
├── core/          # Constantes, tema, routing, extensiones, errores, utils
├── modules/
│   ├── ai/        # Chat IA, modelos (descarga/carga/inferencia simulada)
│   ├── auth/      # Splash, Login (Google), PIN (setup/unlock), biométrico
│   ├── calculators/  # 19 fórmulas clínicas con detalle, búsqueda, categorías
│   ├── settings/  # Configuración, modelos IA, seguridad, acerca de
│   └── subscription/ # Tiers free/premium con features
├── shared/        # Widgets reutilizables, validadores
└── models/        # Modelos de datos (medicación, signos vitales, etc.)
```

## 19 Calculadoras Clínicas

| # | Fórmula | Tipo |
|---|---------|------|
| 1 | Dosis mg/kg | Farmacología |
| 2 | Dosis Pediátrica (Clark) | Pediatría |
| 3 | mg a mL | Farmacología |
| 4 | Gotas/min | Infusión |
| 5 | Microgotas/min | Infusión |
| 6 | Infusión mL/h | Infusión |
| 7 | Balance Hídrico | Fluidos |
| 8 | Superficie Corporal (Mosteller) | Antropometría |
| 9 | Escala de Sedación (RASS) | Neurología |
| 10 | Dosis Vasopresores | Farmacología |
| 11 | Máxima Dosis Segura | Farmacología |
| 12 | Glasgow Coma Scale | Neurología |
| 13 | QTc (Bazett) | Cardiología |
| 14 | Anión GAP | Nefrología |
| 15 | APACHE II (simplificado) | UCI |
| 16 | MELD Score | Hepatología |
| 17 | CHA₂DS₂-VASc | Cardiología |
| 18 | Wells (TEP) | Neumología |
| 19 | CURB-65 | Neumología |

## Modelos IA (Hugging Face)

| Modelo | Repo | Archivo GGUF |
|--------|------|-------------|
| BioMistral 7B Q4_K_M | TheBloke/BioMistral-7B-GGUF | biomistral-7b.Q4_K_M.gguf |
| Meditron 7B Q4_K_M | TheBloke/meditron-7b-GGUF | meditron-7b.Q4_K_M.gguf |
| ClinicalCamel 7B Q4_K_M | TheBloke/ClinicalCamel-7B-GGUF | clinicalcamel-7b.Q4_K_M.gguf |

## Navegación

```
/splash → (2s) → ¿Firebase signed in?
├── No  → /login → Google sign-in o Skip → /ai
└── Sí  → ¿PIN configurado?
    ├── No  → /pin-setup → /ai
    └── Sí  → /ai (home)
```

- `/ai` es la pantalla principal post-auth
- Calculadoras accesibles desde ícono en app bar de AI
- Settings accesible desde ícono en app bar de AI
- `/unlock` para reingreso con PIN cuando la app se cierra

## Suscripciones

| Tier | Features |
|------|----------|
| **Free** | AI básico, 19 calculadoras, modelos locales |
| **Premium** | IA avanzada en nube, modelos premium, soporte prioritario |

Firebase + pagos (Stripe / in-app) no están configurados — todo funciona con try/catch.

## Ejecutar

```bash
cd /home/isturiz/guardian_ai
./run.sh                     # Menú interactivo
# o directo:
flutter run -d chrome        # Web (Chrome)
```

## Tests

```bash
flutter test  # 114 tests pasan
```

## Estado Actual

- `flutter analyze`: 0 errores (solo warnings/info pre-existentes)
- 114/114 tests pasan
- Chrome web es el único target ejecutable en este entorno (sin sudo para Android SDK / Linux GTK)
- Firebase requiere `google-services.json` / `GoogleService-Info.plist` + web client ID
- Pagos requieren backend de validación (Stripe / in-app purchases)

## Próximos Pasos

1. Crear proyecto Firebase y agregar archivos de configuración
2. Probar en Chrome: `./run.sh` → opción 1
3. Verificar grid compacto de calculadoras y flujo AI-as-home
4. Verificar descarga/carga de modelos desde Hugging Face en Settings
5. Configurar backend de suscripciones (Stripe o in-app purchases)
