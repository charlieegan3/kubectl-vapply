#!/bin/bash

set -eo pipefail

readonly namespace="$1"
echo "Applying to namespace: $namespace"

readonly group_name="$2"
echo "Applying to group: $group_name"

readonly manifests_path="$4"
echo "Sourcing manifests from: $manifests_path"

readonly version_hash=$(cat $manifests_path | shasum | cut -d' ' -f1)
echo "Current resource version: $version_hash"

readonly resources=$(kubectl api-resources --verbs=list --namespaced -o name  | tr '\n' ',' | sed 's/,$/\n/')
readonly cmd_apply="kubectl apply -f $manifests_path"
readonly cmd_label="kubectl label --record=true -f $manifests_path vapply-group=$group_name vapply-version=$version_hash"
readonly cmd_delete="kubectl delete "$resources" -l vapply-group==$group_name,vapply-version,vapply-version!=$version_hash -n $namespace"

set +e # run label even if apply completes
echo -e "\nApplying new resources..."
eval $cmd_apply || eval $cmd_label

echo -e "\nLabeling resources..."
eval $cmd_label >/dev/null 2>&1 || echo "(One or more resources already labelled)"
set -e

echo -e "\nDeleting old resources..."
eval $cmd_delete
