#!/bin/bash
set -e

# export PYPI_HOST="pypi.sohonet.co.uk"
# export TWINE_USERNAME="sohonet"
# export TWINE_PASSWORD="..."

python_build() {
  python setup.py sdist bdist_wheel
  twine upload --verbose --repository-url https://$PYPI_HOST dist/*
}

check_pypi_version() {

  local versions_array=$(curl -s -XGET https://${TWINE_USERNAME}:${TWINE_PASSWORD}@${PYPI_HOST}/simple/workalendar/ 2>&1 | sed -e 's/<[^>]*>//g' | sed 's/[^0-9.]*\([0-9.]*\)\([a-z]\+[0-9]\+\)\?.*/\1\2/' | sed 's/\.$//' )
  local package_version=$1

  if [[ ! "$(echo $versions_array |  tr ' ' '\n' | grep "^${package_version}$")" ]];
  then
    echo "Pushing version ${package_version}"
    python_build
  else
    echo "Skipping pypi push as version ${package_version} already exists"
    exit 0
  fi

}

main() {
  local python_package_version=$(python setup.py --version)

  git_hash=$(git log --pretty=format:'%h' -n 1)
  echo "Creating Build for ${CIRCLE_BRANCH} version ${python_package_version}"
  check_pypi_version $python_package_version
}
main


