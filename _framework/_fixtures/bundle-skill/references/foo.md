# Foo Reference

Fixture reference content. If this paragraph appears in the flat output at the link
site, inlining worked.

This file deliberately contains an unescaped Langfuse macro token: {{today}} — the
build script must WARN about it (Langfuse interpolates {{token}} to empty on the MCP
path; AC-2.3 open item).
