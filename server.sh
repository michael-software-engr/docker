# Run inside Rails root...
# S3_BUCKET='s3://dev.aws-example-s3-bucket.com' __aws_local=true ./docker/server.sh

docker_init() {
  local this_dir="$(dirname "$BASH_SOURCE")"

  source "$this_dir/lib.sh" || exit
  source "$this_dir/aws.sh" || exit

  ensure_docker_is_installed
  ensure_enough_space_for_docker_images_and_containers
  ensure_default_postgresql_port_is_open
  ensure_default_redis_port_is_open
  ensure_default_rails_server_port_is_open

  shopt -s expand_aliases
  __aws_local="${__aws_local-}" source "$this_dir/init_env.source.sh" || exit
  shopt -u expand_aliases

  # Reinitialize variable because the source above destroys it.
  this_dir="$(dirname "$BASH_SOURCE")"

  start_server "$this_dir"
}

ensure_docker_is_installed() {
  docker run hello-world > /dev/null || exit
}

ensure_enough_space_for_docker_images_and_containers() {
  # You have the option of bypassing this check.
  [ -n "${__bypass_disk_space_check-}" ] && return

  local work_dir="$(
    docker image inspect fce289e99eb9 | grep WorkDir | cut -f 2 -d ':' |
      sed -e 's/^[ ]*//' -e 's/[ ]*$//' -e 's/"//g'
  )"

  local key_dir_component='overlay2'

  local minimum_space_required=10000000 # KB => 10GB
  local msr_gb='10GB'
  declare -a temp=(
    "Warning: please make sure you have at least '$msr_gb' of free space"
    "in the directory that will contain docker images and containers."
  )
  local disk_space_not_enough_msg="${temp[*]}"

  # Look for this dir path str. I don't know if it's the same for all system.
  # If this str is not found, manually check if you have enough space.
  grep -q "$key_dir_component" <<<"$work_dir" || __error "$disk_space_not_enough_msg"

  local key_dir="$(sed "s/$key_dir_component.*$/$key_dir_component/" <<<"$work_dir")"
  local available="$(
    df "$key_dir" | tail -1 | sed 's/[ ][ ]*/ /g' | cut -f 4 -d ' '
  )"

  local remaining="$(expr "$available" - "$minimum_space_required")"

  [ "$remaining" -gt 0 ] || __error "$disk_space_not_enough_msg"
}

ensure_default_postgresql_port_is_open() {
  local port='5432'
  local proc_info="$(sudo lsof -i :"$port")"
  __ensure_port_is_available \
    "$port" \
    'postgres' \
    "$(tail -1 <<<"$proc_info" | cut -f 1 -d ' ')" \
    "$proc_info"
}

ensure_default_redis_port_is_open() {
  local port='6379'
  local proc_info="$(sudo netstat -antup | grep "$port")"
  __ensure_port_is_available \
    "$port" \
    'redis-server' \
    "$(cut -f 2 -d '/' <<<"$proc_info" | cut -f 1 -d ' ')" \
    "$proc_info"
}

ensure_default_rails_server_port_is_open() {
  local port='3000'
  local proc_info="$(sudo lsof -i :"$port")"
  __ensure_port_is_available \
    "$port" \
    'ruby' \
    "$(tail -1 <<<"$proc_info" | cut -f 1 -d ' ')" \
    "$proc_info"
}

start_server() {
  local this_dir="${1:?ERROR, must pass this dir.}"
  source "$this_dir/../config/docker_secrets.sh" || exit

  export APP_PATH=$(pwd)

  docker-compose build || exit
  docker-compose up
}

set -o nounset
docker_init "$@"
