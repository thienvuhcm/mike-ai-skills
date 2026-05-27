---
description: Free localhost port 8080 (JBake local-preview)
---

# Kill process on port 8080

Free `http://localhost:8080/` by stopping whatever is listening on TCP port 8080 (typically the JBake `local-preview` site: `./mvnw ... jbake:inline -pl site-generator -P local-preview`).

Run this in the integrated terminal from the repo root:

```bash
pids=$(lsof -ti :8080); [ -n "$pids" ] && kill -9 $pids && echo "Freed port 8080" || echo "Port 8080 was already free"
```

If nothing changed, verify with `lsof -i :8080`.
