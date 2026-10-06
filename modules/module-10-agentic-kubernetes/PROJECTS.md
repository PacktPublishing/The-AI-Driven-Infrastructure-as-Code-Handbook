# M10 Projects: Agentic Kubernetes and Platform IaC

3-5 stretch projects. Hints, not solutions.

1. **Compose a second platform resource.** Write a new XRD and Composition for something your
   own team would actually want as a namespaced XR: a namespaced quota, a default network
   policy, a starter deployment. Reuse `function-patch-and-transform`, or try a different
   composition function if you're curious.

2. **Break the reconcile loop on purpose.** Delete the composed `ConfigMap` directly with
   `kubectl delete configmap`, out from under Crossplane, and watch what happens. Does it come
   back? How long does that take? Compare this against what happens if you delete a
   Terraform-managed resource out from under Terraform's own state.

3. **Compare a v1 claim example against this module's v2 approach.** Find a Crossplane v1
   example online (a lot of documentation still shows claims). What object existed in that
   example that doesn't exist in yours? What took over its job?

4. **Add a fourth delivery layer: a claim-style wrapper for a non-platform team.** The lab's
   `XDatabase` is namespaced and direct, aimed at teams comfortable applying a custom resource.
   Write a small script or Makefile target that takes a plain `dbName` argument and generates
   the XR YAML for someone who'd rather run `make new-database NAME=billing` than write YAML by
   hand at all. What did you have to validate before generating, that the schema itself
   doesn't already enforce?

5. **Pin by digest somewhere else in your own stack.** Find one place in your own
   infrastructure that still references a floating tag (`latest`, or a bare version) for
   something that matters. Pin it by digest and write down what you'd have to change if that
   digest ever needed to move.
