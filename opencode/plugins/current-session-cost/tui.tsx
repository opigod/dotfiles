import { Plugin } from "@opencode/plugin/tui"
import { createMemo, createSignal, onCleanup, Show } from "solid-js"
import { Database } from "bun:sqlite"
import { existsSync } from "node:fs"
import { homedir } from "node:os"
import { join } from "node:path"

const money = new Intl.NumberFormat("en-US", {
  style: "currency",
  currency: "USD",
  minimumFractionDigits: 2,
  maximumFractionDigits: 4,
})

type LedgerTotals = {
  cost: number
  messages: number
  tokens: number
}

function defaultDatabase() {
  const state = process.env.XDG_STATE_HOME || join(homedir(), ".local", "state")
  return join(state, "opencode", "opencode-cost", "cost.sqlite")
}

function readLedger(path: string, sessionIDs: string[]): LedgerTotals | undefined {
  if (sessionIDs.length === 0 || !existsSync(path)) return
  let db: any
  try {
    db = new Database(path, { readonly: true })
    db.run("PRAGMA busy_timeout = 2000")
    const placeholders = sessionIDs.map(() => "?").join(", ")
    const row = db
      .query(
        `SELECT COALESCE(SUM(cost), 0) AS cost,
                COUNT(*) AS messages,
                COALESCE(SUM(input_tokens + output_tokens + reasoning_tokens + cache_read_tokens + cache_write_tokens), 0) AS tokens
           FROM usage
          WHERE session_id IN (${placeholders})`,
      )
      .get(...sessionIDs) as LedgerTotals | null
    if (!row) return
    return {
      cost: Number(row.cost),
      messages: Number(row.messages),
      tokens: Number(row.tokens),
    }
  } catch {
    return
  } finally {
    db?.close()
  }
}

function lastAssistantWithUsage(messages: readonly any[], boundary?: string) {
  const boundaryIndex = boundary ? messages.findIndex((message) => message.id === boundary) : -1
  if (boundary && boundaryIndex === -1) return
  const end = boundaryIndex === -1 ? messages.length : boundaryIndex
  const compactionIndex = messages.findLastIndex(
    (message, index) => message.type === "compaction" && message.status === "completed" && index < end,
  )
  return messages.findLast(
    (message, index) =>
      message.type === "assistant" && message.tokens !== undefined && index > compactionIndex && index < end,
  )
}

function contextUsage(messages: readonly any[], models: readonly any[] | undefined, boundary?: string) {
  const last = lastAssistantWithUsage(messages, boundary)
  if (!last) return
  const tokens =
    last.tokens.input +
    last.tokens.output +
    last.tokens.reasoning +
    last.tokens.cache.read +
    last.tokens.cache.write
  if (tokens <= 0) return
  const model = models?.find(
    (item) => item.providerID === last.model.providerID && item.id === last.model.id,
  )
  return {
    tokens,
    percent: model?.limit?.context ? Math.round((tokens / model.limit.context) * 100) : undefined,
  }
}

function ContextWithLedgerCost(props: {
  context: any
  sessionID: string
  database: string
  intervalMs: number
}) {
  const theme = props.context.theme
  const [ledger, setLedger] = createSignal<LedgerTotals | undefined>()

  const session = createMemo(() => props.context.data.session.get(props.sessionID))
  const messages = createMemo(() => props.context.data.session.message.list(props.sessionID) ?? [])
  const models = createMemo(() => props.context.data.location.model.list(session()?.location))
  const usage = createMemo(() => contextUsage(messages(), models(), session()?.revert?.messageID))
  const fallbackCost = createMemo(() => props.context.data.session.cost(props.sessionID))

  const read = () => {
    const current = session()
    const family = props.context.data.session.family(props.sessionID)
    const ids = current?.parentID ? [props.sessionID] : family.length ? family : [props.sessionID]
    setLedger(readLedger(props.database, ids))
  }

  read()
  const timer = setInterval(read, props.intervalMs)
  onCleanup(() => clearInterval(timer))

  // The ledger is the source of truth when it has recorded this session.
  // Before its first write (or if the /cost plugin is unavailable), fall back
  // to OpenCode's own session cost so the section still renders.
  const cost = createMemo(() => {
    const row = ledger()
    if (row && row.messages > 0) return row.cost
    return fallbackCost()
  })

  return (
    <Show when={usage() || cost() > 0}>
      <box>
        <text fg={theme.text.base}>
          <b>Context</b>
        </text>
        <Show when={usage()}>
          {(value) => (
            <>
              <text fg={theme.text.muted}>{value().tokens.toLocaleString()} tokens</text>
              <Show when={value().percent !== undefined}>
                <text fg={theme.text.muted}>{value().percent}% used</text>
              </Show>
            </>
          )}
        </Show>
        <Show when={cost() > 0}>
          <text fg={theme.text.muted}>{money.format(cost())} spent</text>
        </Show>
      </box>
    </Show>
  )
}

export default Plugin.define({
  id: "local.current-session-cost",
  setup(context) {
    const database =
      typeof context.options.database === "string" && context.options.database.trim()
        ? context.options.database.trim()
        : defaultDatabase()
    const intervalMs =
      typeof context.options.intervalMs === "number" ? Math.max(500, context.options.intervalMs) : 1500

    context.ui.slot({
      prepend: "sidebar.content",
      render: (props) => (
        <ContextWithLedgerCost
          context={context}
          sessionID={props.sessionID}
          database={database}
          intervalMs={intervalMs}
        />
      ),
    })
  },
})
