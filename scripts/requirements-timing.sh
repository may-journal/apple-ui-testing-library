#!/usr/bin/env bash
# Prints time per host and phase from the library's signposts, run with `make requirements-timing`.
# It names each phase from config/timing-phases.json, and docs/architecture/04-code.md, Tests, explains the rest.
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
phases="$here/../config/timing-phases.json"

start="$(date '+%Y-%m-%d %H:%M:%S')"
make -k requirements
status=$?

# Pairs each interval's begin and end by process and ID, then sums them per host and phase.
# The phase is the code in the high half of the ID, since the log drops the names.
/usr/bin/log show --signpost --style ndjson \
  --predicate 'subsystem == "org.may-journal.ui-testing-library"' --start "$start" |
  jq -rs --slurpfile config "$phases" '
    map(select(.signpostType == "begin" or .signpostType == "end") | {
      host: (.processImagePath | split("/") | last),
      key: [.processID, .signpostID],
      phase: ($config[0].phases[(.signpostID / 4294967296 | floor | tostring)] // ""),
      type: .signpostType,
      at: ((.timestamp[0:19] | strptime("%Y-%m-%d %H:%M:%S") | mktime) + (.timestamp[19:26] | tonumber))})
    | group_by(.key)
    | map(select(length == 2) | sort_by(.type)
      | {host: .[0].host, phase: .[0].phase, ms: (1000 * (.[1].at - .[0].at))})
    | group_by([.host, .phase])
    | (["host", "phase", "count", "total ms", "mean ms"] | @tsv),
      (.[] | [.[0].host, .[0].phase, length, (map(.ms) | add | round),
        ((map(.ms) | add) / length * 10 | round / 10)] | @tsv)' |
  column -t -s "$(printf '\t')"

exit "$status"
