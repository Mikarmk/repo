# ER Diagram

```mermaid
erDiagram
    PARTNER_TYPES ||--o{ PARTNERS : typed
    PARTNERS ||--o{ PARTNER_REQUESTS : creates
    PARTNER_REQUESTS ||--o{ PARTNER_REQUEST_ITEMS : contains
    PRODUCTS ||--o{ PARTNER_REQUEST_ITEMS : referenced
```
