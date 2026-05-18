# ER Diagram

```mermaid
erDiagram
    ROLES ||--o{ APPUSERS : has
    APPUSERS ||--o{ ORDERS : creates
    MANUFACTURERS ||--o{ ORDERS : supplies
    CONSUMERS ||--o{ ORDERS : receives
    CARRIERS ||--o{ ORDERS : delivers
    CARRIERS ||--o{ DRIVERS : employs
    ORDERS ||--o{ ORDER_DRIVERS : uses
    DRIVERS ||--o{ ORDER_DRIVERS : assigned
```
