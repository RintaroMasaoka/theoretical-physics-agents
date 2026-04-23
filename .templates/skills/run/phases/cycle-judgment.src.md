# Phase: Cycle Step 1 — Research Judgment

This phase file is a reference that PI Reads during `/run` when making the research-judgment decision at the start of each cycle (after Cycle Bookkeeping, before Task Execution). It covers tree traversal, thinking flow, agent selection guidelines, and the close decision. Load it at each step-1 entry unless already in working memory from the current session.

---

PI works **depth-first within the cursor's subtree**. The general movement: dive into leaves, float up when done.

## Tree Traversal

1. **Read the cursor**: research/focus.md tells you where you are. Start there
2. **Check the current node**: Read its log.md and plan.md (if exists) and note.md (if exists). Is there work to do? Are there open/active children to dive into?
3. **Dive to a leaf**: If children exist, pick the most important one and descend. Repeat until you reach a node with actionable work
4. **Work at the leaf**: This is where tasks get dispatched (see `cycle-dispatch.md`)
5. **After leaf work completes** (see `cycle-collection.md`): apply the float-up protocol
6. **When the cursor's subtree completes**: read root `research/note.md` to decide the next direction. Update research/focus.md to the new focus

**Zooming out is deliberate, not automatic.** Only read upper nodes when the current subtree's work is exhausted. This keeps PI focused.

## Thinking Flow

1. **Check the current subtree**: What nodes are open/active? What does the parent's plan.md (children decomposition, strategy) and log.md (Current State) say about what's needed?
2. **Identify the most important gap**: Within the subtree, where does the argument break off?
3. **Depth check**: Review stable nodes in the subtree. Do they mention unexplored angles? Deepening a stable result can be more valuable than starting the next open node
4. **Design tasks with kind in mind**: For conjecture → "search for refutation"; for caution → "find problems"; for example → "calculate the concrete case". kind directly becomes the cognitive mode instruction (see `nodes.md` for the kind table)
5. **Update TodoWrite**: Update based on findings

## Agent Selection Guidelines (not rigid priorities)

- Early research / insufficient literature → **scout** / **reader**
- Open or active gaps → **researcher** (with cognitive mode appropriate to kind)
- Verify researcher's attempt → **critic** with **Target A** (the attempt file in `logs/` — the only critic mode PI ever dispatches; PI decides accept/resubmit/pivot). Critic's Target B (note.md review) is a curator-internal step, not PI-dispatched — see "Critic verification mode" in `cycle-collection.md` for details
- Further research needed after verification → **researcher** (resubmit with previous notes and feedback)
- Build/extend/refine simulation framework → **engine-builder** (`research/lib/`, or "refine lib" for self-directed improvement)
- Numerical verification → **simulator** (using existing `lib/` modules)
- Verify note/plan readability → **self-check** (no research context — catches what PI overlooks)
- Build/maintain concept definitions → **concept-checker**
- Maintain knowledge base → **curator** (note.md polishing, wiki-links, log.md compression, staleness cleanup)

**PI judges as a researcher.** The above are guidelines; judge freely.

## Close Decision

Nodes that show no progress after repeated cycles can be closed. This is not "failure" but "an honest academic judgment." Reframing is also a viable option.
- Continue research if there is progress even without full resolution
- For important questions, up to 5 attempts are acceptable
- For truly important questions, up to 20 attempts are acceptable
