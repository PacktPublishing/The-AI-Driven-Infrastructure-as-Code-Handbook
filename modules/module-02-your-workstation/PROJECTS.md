# M02 Projects: Your Agentic IaC Workstation

4 seeds, hints not solutions.

1. **Run the same intent through both CLIs.** Give Claude Code and Codex the exact same
   one-line ask and compare their first drafts. Where do they agree, and where does the
   design choice differ?

2. **Break a pinned version on purpose.** Install a second Terraform version alongside the
   pinned 1.16.0 (a version manager like `tfenv`, or a second binary on a scratch `PATH`), point
   your shell at the wrong one, and re-run `terraform plan` on `lab/solution/step2-drafted`. Note
   exactly what differs, warning text, plan formatting, an outright error, whatever you actually
   see. Then switch back to 1.16.0 and confirm the module's real `[ Expected output ]` returns.

3. **Write your own step 1 to step 2 pair.** Pick a small, real ask from your own work, not
   from this course. Run it through step 1 first, by hand, then step 2. Note what actually
   differed, the way this module's own lab did.

4. **Bonus, exploratory: hand configuration to Ansible, keep provisioning in Terraform.** This
   is deliberately outside the course's main tool split, an exploratory add-on, not a flagship
   project. Your `step3-acceptedits` container is already running (`terraform apply`). Instead
   of adding a fourth `local_file` resource for the next piece of content, write a small Ansible
   playbook that targets the running container (Ansible's `docker` connection plugin, no SSH
   needed) and templates a new page into `/usr/share/nginx/html/`, or rewrites `default.conf`'s
   `/healthz` response body. Terraform still owns the container's existence; Ansible owns what's
   inside it once it's up, the same provision-then-configure split real infra teams use when one
   tool creates a resource and a different one manages its running state. Ask your agent to
   write the playbook, then read every task in it before you run it, same discipline as every
   other step in this module. Two real judgment questions to answer in your own notes: what
   broke the first time you ran `ansible-playbook` against a container instead of a host, and
   would you actually want two IaC tools touching the same container in a real team, or is that
   a smell this exercise exists to let you feel for yourself?
