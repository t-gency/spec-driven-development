# Runbooks

Operator playbooks: the procedures someone follows to run, deploy, recover or maintain something.

Updated with the operation they describe. **A runbook nobody has run in six months is a guess**,
so each one carries a *Last verified* date and the name of whoever last ran it.

## What makes one usable at 3am

- **Every step says how to tell it worked.** A step with no check is where it fails
- **The rollback names the point of no return**, before that step and not after
- **Copy-pasteable commands.** Not "restart the service": the command
- **Escalation is explicit.** Who to wake, and at what point

## Not a runbook

- How the system is built &rarr; a spec, or the README
- Why it is built that way &rarr; an ADR
- How we write code &rarr; `docs/conventions/`

Start from `TEMPLATE.md`.
