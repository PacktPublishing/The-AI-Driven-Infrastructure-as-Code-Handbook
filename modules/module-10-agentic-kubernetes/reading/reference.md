# M10 Reference Card: Agentic Kubernetes and Platform IaC

## Cluster setup

```
kind create cluster --config kind-config.yaml
kubectl get nodes
```

`kind-config.yaml` pins the node image by digest:
```
image: kindest/node:v1.31.0@sha256:...
```
Confirm any digest yourself: `docker pull kindest/node:<tag>` and read the printed `Digest:` line.

## Crossplane v2 install

```
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm install crossplane crossplane-stable/crossplane \
  --namespace crossplane-system --version 2.4.0 --wait
```
Confirm it's v2: `helm list -n crossplane-system`, `APP VERSION` starts with `2.`.

## XRD / Composition / XR checklist

| Piece | Terraform equivalent | What it does |
|---|---|---|
| XRD (`CompositeResourceDefinition`) | provider's resource schema | defines what fields a request can carry |
| Composition | module | the recipe: what gets created when someone asks |
| XR | resource block | the actual request, applied directly, namespaced in v2, no claim object |

v2 change, stated precisely: **claims removed**. `spec.scope: Namespaced` on the XRD is what
makes a namespaced XR possible; there is no `claimNames` field to add.

## One capability, three ways to deliver it

| Layer | What a team gets | What they have to know |
|---|---|---|
| Raw manifests | Full control, every field explicit | The full definition of a `Secret`, `Service`, `StatefulSet` |
| Helm chart | `helm install --set dbName=X` | The chart's `values.yaml`, nothing else |
| Crossplane XR | A 5-line request, `kubectl apply` | Only the XRD's schema, `dbName` and `storageSize` |

Each layer is real, none of them fake the layer below, the XR composes the exact same
`Secret`/`Service`/`StatefulSet` structure the raw manifests define by hand.

## Composing a native Kubernetes kind needs its own RBAC

A Crossplane `Composition` that composes `Secret`/`Service` (via `function-patch-and-transform`)
works out of the box. Composing `apps/statefulsets` does not, Crossplane's default `crossplane`
`ClusterRole` only grants `get/list/create` on `apps/deployments`. Grant the `crossplane`
`ServiceAccount` explicit RBAC for exactly what the Composition composes:

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: xdatabases-composer
rules:
  - apiGroups: ["apps"]
    resources: ["statefulsets"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
```

## Readiness checks that don't apply

A `StatefulSet` has no `status.conditions[type=Ready]` field, only `status.readyReplicas`.
`MatchCondition` silently never fires. `MatchInteger` against `readyReplicas` hits a real
parsing bug in `function-patch-and-transform` v0.9.0 (`not a (int64) number`). The working
fix: `readinessChecks: [{type: None}]`, the same pattern this module's `ConfigMap` warm-up
already used, and verify real readiness with `kubectl` directly.

## Numbered teardown

1. `kubectl delete -f xr.yaml` for every XR (composed resources go with it via owner references)
2. `helm uninstall <release> -n <namespace>` for every Helm-installed instance
3. `kind delete cluster --name <cluster>`
4. Confirm: `docker ps -a --filter "name=<cluster>"` returns nothing
