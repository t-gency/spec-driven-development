# 3 · Traceability: the part that makes it work

Everything in documents 1 and 2 is a well-organised way to write things down. Useful, but not new.
This is the part that is new, and the reason the practice is worth reviving.

**Without this section, the three documents are ceremony.**

## Every obligation has an ID

One prefix per kind of thing, one ID per obligation:

| Prefix | What it identifies |
|---|---|
| `D-NN` | A decision, with a reversibility flag |
| `TC-NNN` | A technical constraint: what restricts the solution space |
| `FR-NNN` | A functional requirement |
| `NFR-NNN` | A quantified non-functional requirement |
| `S-NN` | A scenario, in Given/When/Then, with lettered variants |
| `AC-NN` | An acceptance criterion |
| `OPEN-Q-NN` | An unresolved question, with an owner |
| `R-NN` | A risk, with a mitigation that points at real work |

The IDs are stable. A requirement keeps its number for the life of the feature, including after
others around it are deleted. Renumbering to close gaps breaks every citation pointing at it, so
gaps are normal and expected.

## The chain

An ID is not a label. It is a link in a chain that runs from a decision to a line of code:

```
D-01          a decision in the Concept Note
  └─ TC-002   becomes a constraint in the Spec
       └─ FR-003          which a requirement must respect
            └─ S-04       which a scenario exercises
                 └─ test tagged "S-04"
                      └─ the code that makes it pass
```

The bottom two links are what make the rest real. **The scenario ID is embedded in the test
itself**, in the test name or a native tag:

```python
@pytest.mark.scenario("S-04")
def test_recovers_partial_turn_after_disconnect():
```

```typescript
it("S-04: recovers the partial turn after a disconnect", () => {
```

Not a table in a wiki mapping tests to requirements. A table is a second thing to maintain, and
the second thing always rots. A tag in the test file moves with the test, gets deleted with the
test, and can be grepped.

## What that buys: the audit

Once the IDs are in the documents and in the tests, a tool can walk every obligation in the Spec
and, for each one, find the code that satisfies it. Each obligation gets exactly one verdict:

| Verdict | Meaning |
|---|---|
| `IMPLEMENTED` | The code satisfies it, and here is the file and line |
| `PARTIAL` | Half of it is there; here is which half is missing |
| `ABSENT` | Nothing satisfies it, and here is where it would live |
| `DIVERGENT` | The code contradicts it |
| `UNVERIFIABLE` | It could not be checked, and here is why |

`UNVERIFIABLE` sitting above `ABSENT` is deliberate: **"I could not check" must never be reported
as "it is not there."** That distinction is what makes the report trustworthy enough to act on.

The audit also runs backwards: it looks for public behaviour in the code that **no ID sanctions**.
That is usually the more interesting direction. Code nobody specified is either a missing
requirement or scope that crept in, and both are worth knowing before someone builds on top of it.

## Two rules that keep the audit honest

**Prose is a claim; code is evidence.** Documentation, code comments, commit messages, PR
descriptions and test names are claims about behaviour. Only the implementation is evidence. A
comment that says `// validates the token` is not proof that a token is validated.

**A gate passing is not proof.** A failing check is evidence of a gap. A passing check is only
evidence that the check passed. A test that asserts nothing, a test whose subject is mocked away,
a code path nothing reaches: all of these pass. The audit is written to look for exactly these,
because they are what a superficial check rewards.

## Why this could not have existed before

Nothing here is technically hard. It did not happen because the labour was absurd: keeping IDs
consistent across three documents, tagging every test, and re-verifying the whole set on every
change is weeks of a person's attention per feature, forever.

An agent does that pass in minutes, repeatedly, without getting bored on obligation forty-seven.

That is the actual change. Not that AI writes the documents — that part is convenient but
secondary. **It is that AI makes verifying them cheap enough to do continuously**, which is the
thing that was always missing. A spec nobody verifies decays into fiction. A spec that gets
audited every week stays a contract.

---

Next: [Adopting it](04-adopting-it.md)
