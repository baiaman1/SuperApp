# SuperAppBackend

Backend для мобильного приложения учета денег с прицелом на развитие в SuperApp.

## Что уже есть

- `ASP.NET Core Web API` на `net8.0`
- Чистая архитектура: `Domain`, `Application`, `Infrastructure`, `WebApi`
- `PostgreSQL` через `EF Core` + `Npgsql`
- JWT-аутентификация
- Вход через Google ID token
- Development sign-in для локальной разработки Flutter-клиента
- Учет счетов, категорий, доходов, расходов и переводов между счетами
- Восстановление данных после утери устройства через повторный вход в аккаунт

## Структура

- `src/SuperAppBackend.Domain` - сущности и enum'ы
- `src/SuperAppBackend.Application` - use cases, DTO, интерфейсы, бизнес-правила
- `src/SuperAppBackend.Infrastructure` - EF Core, репозитории, JWT, Google auth
- `src/SuperAppBackend.WebApi` - контроллеры, middleware, конфигурация API

## Основные endpoint'ы

- `POST /api/auth/google`
- `POST /api/auth/login`
- `POST /api/auth/refresh`
- `POST /api/auth/development` - только для Development
- `GET /api/auth/me`
- `GET/POST/PUT /api/accounts`
- `GET/POST/PUT /api/categories`
- `GET/POST/DELETE /api/transactions`
- `POST /api/transactions/transfer`
- `GET /api/dashboard/summary`

## Swagger

- `GET /swagger/index.html`
- в Swagger UI уже настроена кнопка `Authorize` для `Bearer JWT`

## Что настроить перед запуском

1. Поднять `PostgreSQL`.
2. Обновить строку подключения в `src/SuperAppBackend.WebApi/appsettings*.json`.
3. Задать безопасный `Jwt:SecretKey`.
4. Прописать `GoogleAuth:ClientIds` для Android/iOS/Web клиентов Flutter.

## Seed-данные

В `Development` при `Database:SeedMockDataOnStartup = true` автоматически создаются:

- `super admin`: `admin@superapp.local` / `Admin123!`
- `demo user`: `demo@superapp.local` / `Demo123!`

Также для demo user добавляются:

- несколько счетов
- базовые категории доходов и расходов
- моковые транзакции и переводы между счетами

Если база уже была создана на старой схеме, для новой структуры может понадобиться пересоздать dev-базу или временно включить `Database:ResetOnStartup`.

## Сборка

Для этой среды добавлен последовательный build-скрипт:

```powershell
powershell -ExecutionPolicy Bypass -File .\build.ps1
```

## Следующий логичный шаг

- добавить миграции `EF Core`
- вынести refresh token rotation и logout endpoints
- покрыть application layer тестами
- затем подключать Flutter-клиент
