# Runbook — {{Operation}}

> **Owner:** {{team}} · **Last verified:** {{YYYY-MM-DD}} by {{name}}
>
> Updated with the operation it describes. A runbook nobody has run in six months is a guess.

## When you run this

The trigger. An alert, a release, a recurring maintenance window, an incident symptom.

## Before you start

- **Access needed:** which credentials, which roles
- **Expected duration:**
- **Blast radius:** what is affected while this runs, and who should know

## Steps

Numbered, copy-pasteable, **each one with how to tell it worked**. A step whose success cannot be
checked is where a runbook fails at 3am.

1. **{{Step}}**
   ```bash
   {{command}}
   ```
   *Confirms:* what you should see.

## Rollback

How to undo it, and up to which step undoing is still possible. **If some step is a point of no
return, say so before that step, not after.**

## When it goes wrong

| Symptom | Cause | What to do |
|---|---|---|

## Escalation

Who to wake, and at what point. A runbook that ends with "if this fails, ask someone" has not
finished.
