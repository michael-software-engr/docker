dev_setup() {
  local organizations="${1-}"

  local this_dir="$(dirname "$BASH_SOURCE")"

  source "$this_dir/../../../config/docker_secrets.sh" || exit

  docker-compose exec --env RAILS_ENV=production web rake db:dump || exit
  docker-compose exec web rails db:create || exit
  docker-compose exec --env RAILS_ENV=development web rails db:restore pattern=Equity || exit

  if [ -n "$organizations" ]; then
    docker-compose exec web rails db:import organizations="$organizations" || exit
  fi

  # docker-compose exec --env RAILS_ENV=development web rails db:migrate || exit
}

set -o nounset
dev_setup "$@"
