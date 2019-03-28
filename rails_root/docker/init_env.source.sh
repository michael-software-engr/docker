this_dir="$(dirname "$BASH_SOURCE")"
if docker pull mesosphere/aws-cli; then
  if source "$this_dir/aws.sh"; then
    [ -n "${__aws_local-}" ] && __configure_aws

    if __verify_aws_credentials_validated; then
      if type aws >/dev/null; then
        echo 'aws command successfully setup.'

        if __setup_dev_env_files; then
          if source "$this_dir/../config/docker_secrets.sh"; then
            echo 'Dev env successfully setup.'
          fi
        fi
      fi
    fi

    # Unset all names sourced from aws.sh and others coming from other places.
    unset __aws_local

    unset __configure_aws
    unset __verify_aws_credentials_validated
    unset __setup_dev_env_files
  fi
fi
unset this_dir
