# ER Diagram

```mermaid
erDiagram
    ROLES ||--o{ APPUSERS : has
    APPUSERS ||--o{ EVENT_ORDERS : creates
    SERVICES ||--o{ EVENT_ORDERS : ordered
    EVENT_ORDERS ||--o{ REVIEWS : reviewed
```
