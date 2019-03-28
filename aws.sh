alias aws='docker run --rm -t $(tty &>/dev/null && echo "-i") -v "$(pwd):/project" -v "$HOME/.aws:/root/.aws" mesosphere/aws-cli'

__configure_aws() {
  local user_cred_file="$HOME/.aws/credentials"
  test -s "$user_cred_file" && return

  local root_cred_file='/root/.aws/credentials'
  sudo test -s "$root_cred_file" && return

  aws configure
}

__verify_aws_credentials_validated() {
  local test_access_file_bname='test_access.txt'
  local test_access_file="./$test_access_file_bname"
  rm -f "$test_access_file"
  aws s3 cp "$S3_BUCKET/$test_access_file_bname" "$test_access_file" || return

  if [ ! -f "$test_access_file" ]; then
    echo 'AWS setup failed.' >&2
  else
    rm -f "$test_access_file"
  fi
}

__setup_dev_env_files() {
  aws s3 cp "$S3_BUCKET/env.yml" config || return
  aws s3 cp "$S3_BUCKET/docker_secrets.sh" config
}
