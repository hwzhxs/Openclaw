PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS threads (
    thread_ts       TEXT    NOT NULL PRIMARY KEY,
    channel         TEXT    NOT NULL,
    starter_user    TEXT    NOT NULL DEFAULT '',
    starter_text    TEXT    NOT NULL DEFAULT '',
    status          TEXT    NOT NULL DEFAULT 'open',
    created_at      TEXT    NOT NULL,
    updated_at      TEXT    NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_threads_channel    ON threads(channel);
CREATE INDEX IF NOT EXISTS idx_threads_status     ON threads(status);
CREATE INDEX IF NOT EXISTS idx_threads_updated_at ON threads(updated_at);

CREATE TABLE IF NOT EXISTS events (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    thread_ts       TEXT    NOT NULL DEFAULT '',
    channel         TEXT    NOT NULL,
    event_type      TEXT    NOT NULL,
    user            TEXT    NOT NULL DEFAULT '',
    text            TEXT    NOT NULL DEFAULT '',
    ts              TEXT    NOT NULL,
    raw_json        TEXT    NOT NULL DEFAULT '{}',
    collected_at    TEXT    NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_events_ts_type   ON events(ts, event_type);
CREATE INDEX        IF NOT EXISTS idx_events_thread_ts ON events(thread_ts);
CREATE INDEX        IF NOT EXISTS idx_events_channel   ON events(channel);
CREATE INDEX        IF NOT EXISTS idx_events_event_type ON events(event_type);
CREATE INDEX        IF NOT EXISTS idx_events_collected ON events(collected_at);

CREATE TABLE IF NOT EXISTS violations (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    thread_ts       TEXT    NOT NULL DEFAULT '',
    channel         TEXT    NOT NULL DEFAULT '',
    rule_name       TEXT    NOT NULL,
    details         TEXT    NOT NULL DEFAULT '{}',
    action_taken    TEXT    NOT NULL DEFAULT 'none',
    dry_run         INTEGER NOT NULL DEFAULT 1,
    created_at      TEXT    NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_violations_thread_ts  ON violations(thread_ts);
CREATE INDEX IF NOT EXISTS idx_violations_rule_name  ON violations(rule_name);
CREATE INDEX IF NOT EXISTS idx_violations_created_at ON violations(created_at);
CREATE INDEX IF NOT EXISTS idx_violations_dry_run    ON violations(dry_run);

CREATE TABLE IF NOT EXISTS collector_state (
    channel         TEXT    NOT NULL PRIMARY KEY,
    last_ts         TEXT    NOT NULL DEFAULT '0',
    last_run_at     TEXT    NOT NULL DEFAULT '',
    messages_total  INTEGER NOT NULL DEFAULT 0,
    events_total    INTEGER NOT NULL DEFAULT 0
);
