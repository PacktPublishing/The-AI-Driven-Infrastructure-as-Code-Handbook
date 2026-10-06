# M05 Quiz: MCP and the Tool Layer

9 questions. Pick one answer, then open the reveal to check it and read why.

---

**1. In one sentence, what is MCP?**

- A. A faster way to write Terraform
- B. A standard protocol that lets an agent call a tool or read a resource from an external server, instead of every vendor building its own integration
- C. A replacement for writing skills
- D. A new autonomy step above step 6

<details>
<summary>Answer</summary>

**B.** MCP is the shared interface. Before it, every agent vendor wrote a bespoke
connector to every tool. It has nothing to do with writing Terraform faster (A), it doesn't
replace skills (C), and it has nothing to do with the autonomy ladder's steps at all (D).

</details>

---

**2. A teammate says: "A skill and an MCP tool are basically the same thing, just configured differently." What's wrong with that?**

- A. Nothing, they are the same thing
- B. A skill is packaged instructions the agent follows itself; an MCP tool is a live call to a real external system that returns real data
- C. Skills are enforced, MCP tools are voluntary
- D. MCP tools only work with GitHub

<details>
<summary>Answer</summary>

**B.** A skill never leaves the agent's own reasoning, it just gives it packaged
instructions. An MCP tool call reaches an actual external system and gets back a real
answer. C has it backwards, both a skill and an MCP tool are voluntary, the agent chooses
whether to reach for either one. D is just wrong, MCP works with any server that speaks the
protocol.

</details>

---

**3. Asked the exact same question about a Terraform provider's latest version, an agent gave two different answers: "~3.6.2, best guess" without a tool, and "4.5.0, from the registry" with the Terraform MCP server. What does this actually demonstrate?**

- A. The agent is unreliable and shouldn't be trusted with either answer
- B. Training data has a cutoff, so a live lookup can catch a stale guess a model would otherwise state with real confidence
- C. MCP servers always return higher numbers than a model's guess
- D. The first answer was a formatting bug, not a real difference

<details>
<summary>Answer</summary>

**B.** The model's own knowledge is frozen at training time. A live MCP lookup reads the
actual current state instead. This isn't about the agent being unreliable in general (A),
it's about knowing when to reach for a live source. C is a coincidence of this one example,
not a rule. D, the disagreement is real, not cosmetic.

</details>

---

**4. An agent opens a pull request through the GitHub MCP server. Given the course thesis from module 1, what happens next?**

- A. The PR merges automatically, since the agent authored it through an official tool
- B. Nothing, opening a PR through MCP is the final step
- C. A human reviews the diff and decides whether to merge, the agent's authority ends at opening it
- D. The MCP server itself decides whether to merge, based on CI status

<details>
<summary>Answer</summary>

**C.** The agent proposes, the pipeline decides, same as every other module. Opening a PR
through MCP doesn't change that boundary at all, a human still reviews and merges, or
doesn't. A, B, and D all hand the actual decision to something other than a human, which is
exactly what the thesis says not to do.

</details>

---

**5. Which autonomy step does this module's lab sit on?**

- A. Step 2, draft, because the agent writes the PR content itself
- B. Step 3, propose with plan, the same step as module 4's skill-based lab
- C. Step 4, gated apply, because a hook checks the PR before merge
- D. Step 5, supervised, because the agent runs the whole sequence unattended

<details>
<summary>Answer</summary>

**B.** MCP adds capability, real tool calls and real data, not autonomy. A human still
reads and decides on everything the agent produces through MCP, exactly like module 4's
skill-based lab. C is wrong, this module doesn't introduce a hook, that's module 6. D is
wrong, nothing here runs unattended.

</details>

---

**6. Why does the reading warn that an MCP server is "still a permission surface," even an official one?**

- A. Official servers are actually more dangerous than unofficial ones
- B. What a server can read or write is configured, and a broadly-scoped token is a real risk regardless of who built the server
- C. MCP servers can't be trusted at all, official or not
- D. This only applies to servers that charge money

<details>
<summary>Answer</summary>

**B.** "Official" describes who maintains the server, not what access you've granted it.
A GitHub token scoped to every repository you own is a bigger blast radius than one scoped
to a single throwaway repo, no matter which server holds it. A and C both overstate the
point into something the reading doesn't claim, and D isn't related at all.

</details>

---

**7. What's the actual difference between a hook (module 6) and an MCP tool call (this module)?**

- A. There is no real difference, both are just "extra code that runs"
- B. A hook is enforced, it runs whether or not the agent wants it to; an MCP tool call is voluntary, the agent chooses to make it, but what comes back is real, live data
- C. Hooks are for GitHub, MCP is for Terraform
- D. MCP tool calls always run before a hook would

<details>
<summary>Answer</summary>

**B.** Enforcement is the axis that separates them, not what they're used for. A hook
can't be skipped. An MCP tool call can be, the agent decides whether to reach for it, the
same way it decides whether to reach for a skill, the difference from a skill being that a
real answer comes back from a real system. C and D both invent a rule the material never
states.

</details>

---

**8. After applying the RDS-with-parameter-group module, `terraform apply` reports success with no errors. What still needs checking before you trust that the parameter group actually took effect?**

- A. Nothing, a clean apply means everything wired up correctly
- B. Whether `aws_db_instance.app`'s `parameter_group_name` really matches the parameter group's own name, checked in the actual state, not just re-read from the HCL
- C. Whether the Terraform MCP server is still connected
- D. Whether the GitHub MCP server can see the new resource

<details>
<summary>Answer</summary>

**B.** Terraform will apply a module where the instance and the parameter group's names have
silently drifted apart, nothing errors, the parameter group simply never attaches. A clean
apply (A) only means the HCL was valid, not that the resources reference each other
correctly. C and D are unrelated, neither MCP server has anything to do with verifying this
module's own internal wiring.

</details>

---

**9. `aws-iac-mcp-server` is real, AWS-endorsed, and installs cleanly, then crashes on startup with a real dependency error. What's the actual lesson?**

- A. AWS-endorsed tools should never be trusted
- B. "Official" describes who publishes a package, not whether it runs; verify a server actually starts, and actually covers your IaC tool, before depending on it
- C. This proves MCP itself is unreliable as a protocol
- D. The course made an error, this server must not really exist

<details>
<summary>Answer</summary>

**B.** The install succeeding and the server starting are two separate facts, and this one
splits them: 86 real packages install, then it crashes. Separately, its real tool list is
CloudFormation/CDK-scoped, never Terraform, so even a working install wouldn't have helped
this module's Terraform build. A overstates it into blanket distrust, C blames the protocol
for one server's bug, D is simply wrong, the crash was captured live while building this
lab.

</details>
