
Подготовка
Монорепозиторий `.NET Framework 4.8`, `WPF`, `MSSQL` и `ADO.NET`.

## Структура

- `variants/transport-logistics` - перевозки, заказы, перевозчики, директор
- `variants/online-courses` - онлайн-курсы, расписание, преподаватели, родители
- `variants/event-management` - мероприятия, клиенты, отзывы, директор
- `variants/sweets-production` - сладости, продукция, сырье, кладовщик
- `variants/bytservice-2024` - учет заявок на ремонт бытовой техники
- `variants/partner-orders` - партнеры, заявки, продукция, предложения
- `variants/partner-requests-2025` - отдельный вариант 2025
- `variants/furniture-products-2025` - отдельный вариант 2025
- `docs` - общие инструкции и индекс решений
- `templates` - переиспользуемый каркас WPF + ADO.NET

## Общий подход

Для каждого варианта подготовлены:

- ресурсы в `assets/raw`
- место для нормализованных файлов в `assets/normalized`
- `database` со скриптами `01..06`
- `docs` с ER-описанием, mapping, алгоритмом, тестами и гайдами
- `src` с WPF-проектом или каркасом проекта

## Быстрый порядок работы на экзамене

1. Открыть нужную папку в `variants/<variant-code>`.
2. Выполнить `database/01_create_database.sql`.
3. Выполнить `database/02_import_staging.sql`.
4. Выполнить `database/03_normalize_and_seed.sql`.
5. Проверить `database/04_reports.sql`.
6. Открыть solution или `.csproj` из `src`.
7. Настроить строку подключения по [docs/adonet-mssql-guide.txt](/Users/murat/Desktop/Демо экзамены/repo/docs/adonet-mssql-guide.txt).

## Работа с БД

В репозитории теперь есть два вида примеров:

- `ADO.NET` через `SqlConnection`, `SqlCommand`, `SqlDataReader`
- `Entity Framework` / `Database First` через `DemoTestEntities`, `db.Users.ToList()`, `FirstOrDefault()`, `SaveChanges()`

Полезные файлы:

- [adonet-mssql-guide.txt](/Users/murat/Desktop/Демо экзамены/repo/docs/adonet-mssql-guide.txt)
- [exam-cheatsheet-print.txt](/Users/murat/Desktop/Демо экзамены/repo/docs/exam-cheatsheet-print.txt)
- [EF-WPF-cheatsheet-print.docx](/Users/murat/Desktop/Демо экзамены/repo/docs/EF-WPF-cheatsheet-print.docx)
- [EF-WPF-concrete-examples.docx](/Users/murat/Desktop/Демо экзамены/repo/docs/EF-WPF-concrete-examples.docx)

## Статус

Наиболее полный прикладной пример в репозитории сейчас: `variants/bytservice-2024`.
Остальные варианты доведены до экзаменационного каркаса: структура, SQL, mapping, окна и документация подготовлены так, чтобы их можно было быстро адаптировать или показывать как рабочий шаблон на защите.
