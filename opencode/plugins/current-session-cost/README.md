# opencode-current-session-cost

A local OpenCode TUI plugin that replaces the built-in `opencode.sidebar.context`
section with the same Context block, but reads the session's spent amount from
the [`@lidtop/opencode-cost`](https://www.npmjs.com/package/@lidtop/opencode-cost)
ledger instead of OpenCode's live session cost.

The sidebar renders:

```text
Context
80,432 tokens
8% used
$0.0499 spent
```

The cost is the sum of the current session and, for a root session, its
subagent family. This matches the built-in cost scope while using the `/cost`
plugin's recorded provider-reported cost.

## Requirements

- OpenCode `>= 2.2.0`
- `@lidtop/opencode-cost` installed and loaded so its ledger exists

If the ledger is missing, unwritable, or has no rows for the session yet, the
plugin falls back to OpenCode's `data.session.cost(sessionID)`.

## Configuration

The plugin is loaded from `~/.config/opencode/cli.json`:

```json
{
  "plugins": [
    {
      "package": "/home/opi/opencode-plugins/current-session-cost",
      "options": {
        "intervalMs": 1500
      }
    },
    "-opencode.sidebar.context"
  ]
}
```

`-opencode.sidebar.context` disables the built-in Context section so this plugin
can render it instead.

Options:

| Option | Default | Description |
| --- | --- | --- |
| `intervalMs` | `1500` | How often the read-only ledger query refreshes. Values below `500` are clamped. |
| `database` | `$XDG_STATE_HOME/opencode/opencode-cost/cost.sqlite` or `~/.local/state/opencode/opencode-cost/cost.sqlite` | Override if the `/cost` plugin is configured with a custom `database`. |

## Uninstall

Remove the plugin entry and the `-opencode.sidebar.context` line from
`~/.config/opencode/cli.json`, then restart the TUI.
