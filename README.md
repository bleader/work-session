# ws

Switch between work sessions, each session is a tmux + qutebrowser pair sharing the same name.

## Install

```bash
chmod +x ws
sudo mv ws /usr/local/bin/ws
```

## Usage

| Command | Description |
|---|---|
| `ws` | fuzzy-select a session from existing contexts (or create a new one) |
| `ws NAME` | switch to (or create) a context named `NAME` |
| `ws resume` | open the current context in qutebrowser + foot — use at login |
| `ws` → `[delete]` | kill a tmux session and its saved browser tabs |

## Details

- Existing contexts come from qutebrowser's saved sessions (`~/.local/share/qutebrowser/sessions/*.yml`).
- The current context is tracked in `~/.local/state/ws/current`.
- A session name may start with an alphanumeric character and contain `[A-Za-z0-9_-]` (no `.` or `:` for tmux, no leading `_` for qutebrowser).
- A fresh context is auto-created with an empty browser tab if it doesn't already exist.
