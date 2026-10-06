# M05 Exploratory Projects

3 seeds, hints not solutions.

1. **Find a stale answer of your own.** Ask your agent a question about a tool or provider
   you use often, with no MCP tool available, then with one. Where did it disagree with
   itself? Was the disagreement large enough to matter?

2. **Wire up a third MCP server.** Pick one relevant to your own stack, a cloud provider's,
   a monitoring tool's, an internal system's. Register it, make one real call, and note
   what it returned that you couldn't have gotten from the model alone.

3. **Audit an MCP server's permissions.** For any server you've configured, work out
   exactly what it can read and what it can write. Would you trust it to run unattended? If
   not, what's the narrowest scope that would still let it do its job?

4. **Stretch: build your own MCP server.** Neither Terraform MCP nor `aws-iac-mcp-server`
   knows about your team's own conventions, an internal module registry, a naming policy, a
   cost-approval workflow. Write a minimal stdio MCP server, in any language, exposing one
   real tool that answers a question specific to your own infrastructure. This is genuinely
   more work than the rest of this module, and it's optional for exactly that reason.
