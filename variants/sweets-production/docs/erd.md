# ER Diagram

```mermaid
erDiagram
    ROLES ||--o{ APPUSERS : has
    PRODUCTS ||--o{ ORDER_ITEMS : ordered
    BUYERS ||--o{ ORDERS : creates
    ORDERS ||--o{ ORDER_ITEMS : contains
    RAW_MATERIALS ||--o{ PRODUCT_MATERIALS : needed
    PRODUCTS ||--o{ PRODUCT_MATERIALS : consumes
```
