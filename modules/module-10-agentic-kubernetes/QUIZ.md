# M10 Quiz: Agentic Kubernetes and Platform IaC

9 questions. Pick one answer, then open the reveal to check it and read why.

---

**1. What's the real mechanical difference between `terraform apply` and a Kubernetes reconcile loop?**

- A. There is no real difference, they both just create resources
- B. `terraform apply` runs once and stops; a reconcile loop keeps comparing desired state against actual state, continuously
- C. Kubernetes never lets you see a plan before applying
- D. Terraform can only be used for cloud resources, Kubernetes can't

<details>
<summary>Answer</summary>

**B.** A one-shot apply does its work and stops. A controller's reconcile loop keeps
watching, and corrects drift on its own, whether or not anyone re-runs anything.

</details>

---

**2. Why does this module's `kind` cluster config pin the node image by digest instead of a version tag like `v1.31.0`?**

- A. Digests are shorter to type
- B. A tag like `v1.31.0` can still move to a different underlying build over time; a digest is the exact content hash and can't
- C. `kind` doesn't support version tags at all
- D. It's required by Docker, not a `kind`-specific choice

<details>
<summary>Answer</summary>

**B.** A floating tag can quietly point at a different build later. A digest is content-addressed,
the same digest always resolves to the exact same image, so every learner gets an identical cluster.

</details>

---

**3. What changed in Crossplane v2 that this module actually uses?**

- A. XRDs were removed
- B. Compositions became optional
- C. Claims were removed, a composite resource (XR) is now namespaced and requested directly
- D. Crossplane no longer supports custom resources

<details>
<summary>Answer</summary>

**C.** In v1, a namespaced claim stood in for a cluster-scoped XR. In v2, the XR itself is
namespaced, so a team requests it directly, no separate claim object needed.

</details>

---

**4. Match the pieces: which Terraform concept does a Crossplane XRD play the same role as?**

- A. A `resource` block
- B. `terraform apply`
- C. A provider's resource schema, what fields a request can carry
- D. `terraform state`

<details>
<summary>Answer</summary>

**C.** An XRD defines the schema, same job a provider's resource schema does. A Composition
plays the module's role, and the XR itself plays the resource block's role.

</details>

---

**5. Why does this module's `ConfigMap` need `readinessChecks: [{type: None}]` in its Composition?**

- A. It's required for every Crossplane resource, no exceptions
- B. A plain `ConfigMap` has no status conditions Crossplane can watch, so without an explicit check the XR stays `READY False` forever, waiting for a signal that never comes
- C. It speeds up the reconcile loop
- D. It disables the resource's owner reference

<details>
<summary>Answer</summary>

**B.** Crossplane's default readiness detection watches for status conditions. A `ConfigMap`
doesn't have any, so `type: None` tells Crossplane to treat its mere existence as ready.

</details>

---

**6. In this module's lab, what actually deletes the composed `ConfigMap` when you delete the XR?**

- A. A separate `kubectl delete configmap` command, run manually
- B. The `ownerReferences` block Crossplane set on the ConfigMap, Kubernetes garbage-collects it automatically
- C. Nothing, it has to be deleted by hand every time
- D. The `kind` cluster teardown, not the XR delete

<details>
<summary>Answer</summary>

**B.** The composed `ConfigMap` carries an owner reference back to the XR. Delete the XR,
and Kubernetes garbage-collects everything it owns, no manual cleanup step.

</details>

---

**7. Why does Helm 4 matter for this module specifically, beyond "it's the newer version"?**

- A. Helm 3 can't install Crossplane at all
- B. Helm 3's last feature release was September 2026 and its security support ends February 2027, so this course teaches the version that will still be supported
- C. Helm 4 removed the ability to install charts from a repo
- D. Helm 4 is required by `kind`

<details>
<summary>Answer</summary>

**B.** Nothing about the chart-install workflow changed dramatically. The point is which
version is still receiving security support when a learner is actually running this lab.

</details>

---

**8. This module's lab hit a real error composing a `StatefulSet`: `cannot get existing composed resource: Timeout: failed waiting for *unstructured.Unstructured Informer to sync`. What was the actual root cause?**

- A. The kind cluster ran out of memory
- B. Crossplane's default ClusterRole grants RBAC for `apps/deployments`, not `apps/statefulsets`, so composing a StatefulSet needs an explicit grant
- C. The StatefulSet's image tag was wrong
- D. `kubectl` was pointed at the wrong context

<details>
<summary>Answer</summary>

**B.** The error reads like a caching problem and is actually a permissions problem.
Crossplane, composing a native Kubernetes kind, acts as itself and needs its own RBAC grant
for exactly what it composes, unlike a provider authenticating to a cloud API with its own
credentials.

</details>

---

**9. Why does the lab's `db-composition.yaml` use `readinessChecks: [{type: None}]` on the composed `StatefulSet`, the same pattern the PART I `ConfigMap` warm-up used?**

- A. `StatefulSet` and `ConfigMap` are both composed the same way, no real reason
- B. A `StatefulSet` has no `status.conditions[type=Ready]` field, only `status.readyReplicas`, and a real parsing bug makes `MatchInteger` against it fail too, so real readiness has to be checked directly with `kubectl` instead
- C. `type: None` is required for every composed resource in Crossplane v2
- D. It disables the StatefulSet's readiness probe

<details>
<summary>Answer</summary>

**B.** Two different resources hit `type: None` for two different real reasons: a `ConfigMap`
has no status conditions at all, a `StatefulSet` has conditions Crossplane can't reliably read
in this function version. Same workaround, different root cause each time.

</details>
