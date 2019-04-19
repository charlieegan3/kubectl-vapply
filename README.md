# Versioned Apply

'Versioned Apply' (`vapply`) is a kubectl plugin that extends `kubectl apply`
with delete functionality.

`vapply` labels all applied resources with a `vapply-group` and
`vapply-version`. After applying it removes all resources in the group not at
the current version.

## Installation

```bash
sudo cp vapply.sh /usr/local/bin/kubectl-vapply
sudo chmod +x /usr/local/bin/kubectl-vapply
```

## Usage

```
kubectl vapply NAMESPACE GROUP_NAME -f manifests.yaml
```

## Why?

* `--prune` isn't really ready for this yet.
* Helm has this functionality but I don't have Helm
* Flux doesn't seem to have this functionality.
