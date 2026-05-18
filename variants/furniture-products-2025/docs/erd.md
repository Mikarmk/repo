# ER Diagram

```mermaid
erDiagram
    PRODUCT_TYPES ||--o{ PRODUCTS : typed
    MATERIALS ||--o{ PRODUCTS : mainMaterial
    PRODUCTS ||--o{ PRODUCT_WORKSHOPS : processed
    WORKSHOPS ||--o{ PRODUCT_WORKSHOPS : used
```
