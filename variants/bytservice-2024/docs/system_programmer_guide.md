# Руководство системному программисту

## Требования

- Windows 10/11
- Visual Studio 2022
- .NET 8 SDK с поддержкой WPF
- SQL Server Express, Developer или LocalDB

## Развертывание

1. Создать БД запуском `scripts/01_create_database.sql`.
2. Загрузить стартовые данные запуском `scripts/02_import_data.sql`.
3. При необходимости применить роли БД из `scripts/04_security.sql`.
4. Открыть решение `PraktikaDemo.sln`.
5. Убедиться, что в `src/BytService.App/appsettings.json` указана корректная строка подключения.
6. Собрать и запустить проект `BytService.App`.

## Настройка

- для SQL Server Express часто подходит строка `Server=.\\SQLEXPRESS;Database=BytServiceDemo;Trusted_Connection=True;TrustServerCertificate=True;`
- для LocalDB можно использовать `Server=(localdb)\\MSSQLLocalDB;Database=BytServiceDemo;Trusted_Connection=True;`

## Сопровождение

- резервная копия создается скриптом `scripts/05_backup.sql`
- отчеты доступны в `scripts/03_reports.sql`
- импорт исходных файлов сохранен в `assets/import`

## Модификация

- для новых ролей достаточно добавить запись в `dbo.Roles` и расширить фильтрацию в `MainWindow.xaml.cs`
- при изменении структуры заявок необходимо синхронно обновить `RepairRequests`, `RequestService.cs` и форму `RequestDialog.xaml`

