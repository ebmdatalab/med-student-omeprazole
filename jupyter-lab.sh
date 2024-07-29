#!/bin/bash

# *****************************************************************************
#
# This script is intended as a cross-platform launcher which starts Jupyter Lab
# running inside a Docker container. We use Bash because we already require git
# to be installed and on Windows that brings with it git-bash (and Linux and
# macOS have Bash already).
#
# *****************************************************************************

set -euo pipefail


# ERROR HANDLER
#
# We expect this script to often get run by double-clicking in a file manager,
# in which case the console window will disappear on exit. But when exiting
# with an error we'd like the window to stick around so the user can read the
# message, so we set up an error handler which waits for a keypress.
error_handler() {
  echo
  echo "Jupyter Lab failed to start, press any key to exit."
  read
}

trap "error_handler" ERR


# CHANGE INTO SCRIPT DIRECTORY
#
# Unset CDPATH to prevent `cd` potentially behaving unexpectedly
unset CDPATH
cd "$( dirname "${BASH_SOURCE[0]}")"


# GENERATE DOCKER IMAGE NAME
#
# We want a Docker image name which is:
# (a) stable so repeated runs of this script use the same image;
# (b) unique to this specific project;
# (c) reasonably easy to identify by eye in a list of image names.
#
# So we use the naming scheme:
#
#     jupyter-<directory-name>-<short-hash-of-the-full-directory-path>
#
# e.g. "jupyter-docker-notebook-8cfe31c1"
#
dirname="$(basename "$PWD")"
path_hash=$(echo "$PWD" | shasum | head -c 8)
image_name="jupyter-$dirname-$path_hash"

# Generate a short random suffix so that we can set a meaningful name for the
# container but still ensure uniqueness (with sufficiently high probability)
container_suffix=$(head -c 6 /dev/urandom | base64 | tr '+/' '01')
container_name="$image_name-$container_suffix"


# BUILD IMAGE
#
# We explicitly specify the platform so that when running on Apple silicon we
# still get the `amd64` image rather than the `arm64` image. Not all the Python
# packages we want to install have `arm64` wheels, and we don't always have the
# headers we need to compile them. Insisting on `amd64` gives us cross-platform
# consistency.
docker build --platform linux/amd64 --tag "$image_name" .


# SET OS-SPECIFIC CONFIG
#
# On Linux, where the ownership of mounted files maps directly through to the
# host filesystem, we want the Docker user ID to match the current user ID so
# files end up with the right owner. On Windows/macOS files inside the
# container will appear owned as root, so we want to run as root.
if [[ "$(docker info -f '{{.OSType}}')" == "linux" ]]; then
  docker_user="$UID:$(id -g)"
else
  docker_user="root"
fi
# The git-bash terminal (which most of our Windows users will run this under)
# does not provide a TTY unless we run the command via the `winpty` tool. So we
# try to detect when we are running in git-bash and get the path to `winpty` if
# we are.
if [[ -z "${MSYSTEM:-}" ]]; then
  winpty_path=""
else
  winpty_path="$(command -v winpty || true)"
fi


# GENERATE SERVER URL
#
# Generate a random token with which to authenticate to Jupyter. Jupyter can
# generate this for us, but it massively simplifies things to generate it
# ourselves and pass it in, rather than try to extract the token Jupyter has
# generated. We use `base64` as it's universally available (unlike `base32`)
# and replace any URL-problematic characters.
token=$(head -c 12 /dev/urandom | base64 | tr '+/' '01')

# Likewise, we want to tell Jupyter what port to bind to rather than let it
# choose. We find a free port by asking to bind to port 0 and then seeing what
# port we're given. This is obviously race-unsafe in the sense that the port
# might no longer be free at the point we want to use it, but that's seems
# unlikely on a local workstation.
#
# We shell out to Perl as we can assume the presence of git and git implies the
# presence of Perl.
port=$(
  perl -e '
    use IO::Socket::INET;

    print(
      IO::Socket::INET->new(
        Proto => "tcp", LocalAddr => "127.0.0.1"
      )
      ->sockport()
    );
  '
)

server_url="http://localhost:$port/?token=$token"


echo
echo ' -> Connect to notebook with URL:'
echo
echo "        $server_url"
echo
echo '    Tip: to open in browser, triple-click the URL, right-click, choose "Open"'
echo


# START JUPYTER LAB IN DOCKER

docker_args=(
  run
  --rm
  --interactive
  --tty
  --name "$container_name"
  --user "$docker_user"

  # The leading slash before PWD here is needed when running on Windows to stop
  # git-bash mangling the path
  --volume "/$PWD:/workspace"
  --publish "$port:$port"

  "$image_name"

  jupyter lab
    --ip=0.0.0.0
    --port="$port"
    --IdentityProvider.token="$token"
    --ServerApp.custom_display_url="$server_url"
    --no-browser
    --allow-root
)

if [[ -z "$winpty_path" ]]; then
  docker "${docker_args[@]}"
else
  "$winpty_path" -- docker "${docker_args[@]}"
fi
