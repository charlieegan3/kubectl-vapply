#!/bin/bash

set -eo pipefail

b_green='\033[1;32m'
no_color='\033[0m'

readonly namespace="$1"
echo -e "Applying to namespace: $b_green$namespace$no_color"

readonly group_name="$2"
echo -e "Applying to group: $b_green$group_name$no_color"

readonly manifests_path="$4"
echo -e "Sourcing manifests from: $b_green$manifests_path$no_color"

version_hash=""
if [ -d "$manifests_path" ]; then
  version_hash=$(tar -cf - $manifests_path | shasum | cut -d' ' -f1)
else
  version_hash=$(cat $manifests_path | shasum | cut -d' ' -f1)
fi
echo -e "Current resource version: $b_green$version_hash$no_color"

readonly resources=$(kubectl api-resources --verbs=list --namespaced -o name  | tr '\n' ',' | sed 's/,$/\n/')
readonly cmd_apply="kubectl apply -f $manifests_path"
readonly cmd_label="kubectl label --overwrite=true -f $manifests_path vapply-group=$group_name vapply-version=$version_hash"
readonly cmd_delete="kubectl delete "$resources" -l vapply-group==$group_name,vapply-version,vapply-version!=$version_hash -n $namespace"

set +e # run label even if apply fails
echo "Applying new resources..."
eval $cmd_apply | sed 's/^/    /' || eval $cmd_label | sed 's/^/    /'

echo "Labeling resources..."
eval $cmd_label >/dev/null 2>&1 && echo "    (labelled)" || echo "    (One or more resources already labelled)"
set -e

echo "Deleting old resources..."
eval $cmd_delete | sed 's/^/    /'

echo "vapply complete"
