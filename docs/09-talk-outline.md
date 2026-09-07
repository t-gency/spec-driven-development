# 9 · Talk outline

Two audiences were asked for: **Product broadly**, and **the team who will
actually use this**. They need different talks, but the first 20 minutes are the same.

Structure below is 45 minutes plus questions. Cut section 5 for the broad audience; cut nothing
for the team.

---

## 0 · Open with the failure, not the solution (3 min)

Do not start with "there is a methodology with three documents". Start with the three questions
nobody can answer three weeks after shipping:

- Was this decided, or did someone assume it?
- Is the code doing what we agreed, or what was convenient?
- If we change this, what breaks?

Ask for a show of hands on who has been unable to answer one of these in the last month. The
material lands very differently once the room has admitted the problem.

## 1 · Why the old answer failed (5 min)

Specs are not a new idea. They died, and the reason matters: **the spec went stale and nobody
could afford to keep it current.** Anyone in the room over 35 has lived this and is already
sceptical. Say it before they do.

## 2 · What changed (5 min)

Two things, and the second is the real one.

- An agent can write most of the document. Cost per Spec drops from days to hours
- **An agent can audit the code against it.** The loop that was always missing closes

Land the asymmetry explicitly: writing was never the hard part. Verifying was. That is what got
cheap.

## 3 · The three documents (10 min)

One slide each. Do not read the section lists; the templates exist for that.

- **Concept Note** — why, and in what direction. Divergent. Decisions get IDs and a reversibility
  flag
- **Spec** — what it must do. Normative. Every line an obligation
- **Implementation Plan** — what, where, in what order. Executable

Best single example for a mixed room: put a bad requirement and a good one side by side.

> "The system must be fast"
>
> "The system shall return search results within 300 ms at p95 for datasets under 10,000 records"

Then the question that does the work: *which one can be violated?* Only the second. A requirement
that cannot be violated is not a requirement.

## 4 · Traceability, the part that matters (10 min)

This is the centre of the talk. If time runs short, cut something else.

Show the chain on one slide: `D-01 → TC-002 → FR-003 → S-04 → test tagged S-04 → the code`.

Then show what the audit returns. The five verdicts, and specifically why `UNVERIFIABLE` ranks
above `ABSENT`: *"I could not check" must never be reported as "it is not there."* That one line
is what makes people trust the output, and it usually gets a reaction.

Then the backwards sweep: code that no ID sanctions. That lands harder than the forward direction,
because everyone in the room has shipped something nobody specified.

## 5 · Making it real — team audience only (8 min)

The four questions the methodology does not answer, and what we chose:

1. **The unit.** `Surface | Feature → Name`; 53 tickets, 18 features
2. **The bridge.** Two body fields, `Docs` and `Satisfies`
3. **Where tasks live.** Ticket for people, plan tasks for the executor. Never both
4. **What earns it.** Full pipeline on 2 or 3 features out of 18

Spend the time on point 4. It is the one that decides whether adoption survives the first month.

## 6 · Close on the honest cost (4 min)

Do not oversell. State the number: 15,000 to 40,000 words per feature. Say plainly that most work
should not get this, and that a team running it on everything will quietly stop running it on
anything.

Then the one-sentence close:

> A spec nobody verifies decays into fiction. A spec that gets audited is a contract. The only
> thing that changed is that auditing got cheap.

---

## Questions to expect

**"Isn't this just waterfall?"** No, and the difference is concrete: waterfall specified the whole
system once, up front. This specifies one feature at a time, and the Concept Note explicitly
carries what is still undecided rather than pretending it is settled.

**"Who writes these, product or engineering?"** The methodology does not assign roles, only an
owner and reviewers per document. In practice the Concept Note leans product, the Plan leans
engineering, and the Spec is where the two actually have to agree — which is the point of it
existing.

**"What if the code and the Spec disagree?"** That is the audit's `DIVERGENT` verdict, and it is a
finding, not a failure. Someone decides which one is wrong. Before this existed, nobody found out
at all.

**"How long until we see value?"** One feature. The first audit on a feature you thought was
finished is the demo.

**"We already write tickets, isn't this duplicated?"** A ticket is a unit of work. A Spec is a
statement of obligations. They answer different questions, and the two body fields are what keep
them from being two versions of the same thing.
