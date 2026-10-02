#!/usr/bin/env bash
# ws: a work context = tmux session + qutebrowser session sharing the same name.
#   ws          fuzzel menu, pick a context or type a new name
#   ws NAME     switch to NAME (created if missing)
#   ws resume   at login: open browser + terminal on the current context
set -eu

qb_sessions=${XDG_DATA_HOME:-$HOME/.local/share}/qutebrowser/sessions
state=${XDG_STATE_HOME:-$HOME/.local/state}/ws
mkdir -p "$state"
cur=$(cat "$state/current" 2>/dev/null || echo default)
decoration="-C bb9af7ff --prompt-color bb9af7ff -m bb9af7ff -M bb9af7ff"

contexts() {
  for f in "$qb_sessions"/*.yml; do
    n=${f##*/} n=${n%.yml}
    [[ $n == _* ]] || echo "$n"
  done
}

term() { setsid -f foot tmux new-session -A -s "$1" >/dev/null 2>&1; }

case ${1:-} in
resume)
  setsid -f qutebrowser -r "$cur" >/dev/null 2>&1
  term "$cur"
  exit
  ;;
"") new=$(contexts | fuzzel --dmenu --prompt "ws [$cur] > " $decoration) || exit 0 ;;
*) new=$1 ;;
esac

# tmux forbids . and : in names, qutebrowser reserves _-prefixed sessions
if [[ ! $new =~ ^[A-Za-z0-9][A-Za-z0-9_-]*$ ]]; then
  notify-send "ws" "invalid context name: $new"
  exit 1
fi

# browser: save the current context, swap in the new one
if [[ $new != "$cur" ]]; then
  [[ -e $qb_sessions/$new.yml ]] ||
    printf 'windows:\n- tabs:\n  - history:\n    - url: about:blank\n      title: %s\n' "$new" >"$qb_sessions/$new.yml"
  setsid -f qutebrowser ":session-save --quiet $cur" ":session-load --clear $new" >/dev/null 2>&1
fi

# tmux: reuse a terminal already showing a context, otherwise open one
tmux has-session -t "=$new" 2>/dev/null || tmux new-session -d -s "$new" -c "$HOME"
client=
while read -r c s; do
  [[ -e $qb_sessions/$s.yml ]] && {
    client=$c
    break
  }
done < <(tmux list-clients -F '#{client_name} #{session_name}' 2>/dev/null)
if [[ -n $client ]]; then
  tmux switch-client -c "$client" -t "=$new"
else
  term "$new"
fi

echo "$new" >"$state/current"
