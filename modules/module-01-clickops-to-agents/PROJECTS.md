# M01 exploratory projects

Five seeds. Hints, not solutions, on purpose. Pick one, or all five if you're on a roll.

### 1. Date your own stack

Map the infrastructure you actually run at work onto the seven eras from this module. Not
what your team says it does, what actually runs today: which parts are still ClickOps,
which are scripts, which made it to declarative IaC or GitOps?

*Hint: look at how a change actually gets made, not how the architecture diagram says it
should. The two are often different.* Which era is most of your stack sitting in, and what
residue, drift, sprawl, unreviewed state, review load, are you personally living with
because of it?

### 2. Step audit

Pick three things you or your team already do with AI assistance on infrastructure or
anything adjacent to it. Place each one on the six-step ladder from this module.

*Hint: be honest about step 1 versus step 2. A lot of "we use AI for this" turns out to be
step 1, suggest, with a human doing all the real work anyway.* For each of the three, ask:
is there an actual gate under this step, or are you just trusting it?

### 3. Find the silent failure

Think back to a real infrastructure incident you were part of or heard about in detail.

*Hint: the interesting cases are the ones where the change that caused the incident
"succeeded" at the time, nobody got an error, and the problem only showed up later.* Would
a scanner like Checkov or Trivy have caught it before it shipped? If not, what would have,
a policy check, a cost check, a human reviewer looking for something specific?

### 4. Argue the other side

Write the strongest honest case you can that agentic infrastructure isn't worth the
guardrail overhead for a small team, five engineers, no dedicated platform team, moving
fast. Then answer your own argument.

*Hint: don't strawman it. The real case usually rests on the fixed cost of building a
pipeline being too high relative to a small team's blast radius. What changes that
calculation, team size, regulatory exposure, how much of the infrastructure is customer-
facing?*

### 5. The one-line intent

Write the single intent you'd most want to hand an agent, one sentence, the kind of thing
you read at the start of this module's lab. Something real, from your own work, not a toy
example.

*Hint: keep it specific enough that two different engineers reading it would build roughly
the same thing.* Save it. Module 7 turns exactly this kind of sentence into a proper spec,
and you'll want your own real example when you get there.
