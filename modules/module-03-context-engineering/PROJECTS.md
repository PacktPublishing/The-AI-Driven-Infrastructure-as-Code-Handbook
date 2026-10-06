# M03 Projects: Context Engineering for Infrastructure

3-5 stretch project seeds. Hints, not solutions.

1. **Write your team's `AGENTS.md`.** For a real repo you actually work in, not a toy one.
   Include provider pins, your team's real naming convention, and at least one never-do rule
   your team enforces informally today.

2. **Break it on purpose.** Delete one line from your `AGENTS.md`, run the same intent you
   ran before, and see what comes back wrong. That deleted line was load-bearing. Which one
   surprised you most?

3. **Retrieval audit.** In a test repo, rename one file to something an agent would not
   guess, `x7.tf` instead of `networking.tf`. Ask an agent to change something in it. Does it
   still find the file? What clue, if any, let it find it anyway?

4. **The information gap, at your shop.** Pick one policy your team enforces informally, a
   Slack message from six months ago, an unwritten rule everyone just knows. Write it down
   somewhere an agent would read it. Would an agent have violated it before you wrote it
   down? Test it if you can.

5. **Context budget audit.** Look at what a real agent session in your own repo actually
   loaded into context before doing anything useful. How much of it was the task, and how
   much was noise, an unrelated file, old chat turns, a huge log? Where would you cut first?
