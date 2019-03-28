__error() {
  echo "ERROR: $1" >&2
  shift

  local msgs=''
  for msg in "$@"; do
    echo "$msg" >&2
  done

  exit 1
}

__ensure_port_is_available() {
  local port="${1:?ERROR, must pass port.}"
  local proc_to_kill="${2:?ERROR, must pass name of proc to kill.}"
  local proc_using_port="${3-}"
  local proc_info="${4-}"

  [ "$proc_using_port" = "$proc_to_kill" ] &&
    __error \
      "process name '$proc_to_kill' is running:" \
      "$proc_info" \
      "Please shut down the process using port '$port' before proceeding."
}
