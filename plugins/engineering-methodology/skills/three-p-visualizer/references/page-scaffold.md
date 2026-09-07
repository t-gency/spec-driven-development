# Page scaffold — design language + proven building blocks

Everything here has been verified working in a real browser. Copy the
JS/CSS patterns rather than re-deriving them — pan-zoom math and drawer
state are easy to get subtly wrong.

## 1. Design language

- **Single self-contained file.** Vanilla HTML/CSS/JS. The only
  external dependency allowed is a web-font `<link>` (Google Fonts).
  No frameworks, no build step, no CDN scripts.
- **Distinctive theme derived from the domain.** Pick a characterful
  display + body font pairing (e.g. IBM Plex for mainframe subject
  matter — the font itself tells the story). Never default to
  Inter/Roboto/Arial or purple-gradient-on-white.
- **A color narrative, not a palette.** Give the two or three central
  concepts of the system their own accent colors and use them
  *consistently across every diagram* (e.g. amber = legacy path,
  green = new path, violet = verification machinery, cyan = frozen
  contracts). The legend appears once; after that, color carries
  meaning everywhere.
- **Dark, atmospheric base** usually reads best for engineering
  audiences: a near-black background, one or two fixed radial glows,
  optional scanline/grain overlay at low opacity via a `body::after`
  with `pointer-events:none`.
- **CSS variables for everything** (`--bg`, `--panel`, `--line`,
  `--ink`, accent colors, font stacks). Components below assume them.
- **Monospace for IDs and data**, condensed display face for headings,
  humanist sans for body.

## 2. Page skeleton

```
<header>  feature name · framing paragraph · three 3P cards (data-goto links)
<nav class="tabs">  P1 Product · P2 Process · P3 Project  (sticky, backdrop-blur)
<main>
  <section class="view on" id="view-product">  …ladder…  …lenses…
  <section class="view" id="view-process">  …pipeline… cycle… quality… rollout…
  <section class="view" id="view-project">  …timeline… costs… decisions… risks… open-qs…
<footer>  links back to the three source .md docs
<aside id="drawer"> + <div id="scrim">   (detail panel, see §5)
```

Tab switching: views are `display:none` except `.on`; switching scrolls
to the tab bar. Wire the header 3P cards to the same `showView(v)`.

```js
const tabs=document.querySelectorAll('nav.tabs button[data-view]');
function showView(v){
  tabs.forEach(x=>x.classList.toggle('active',x.dataset.view===v));
  document.querySelectorAll('section.view').forEach(s=>s.classList.toggle('on',s.id==='view-'+v));
  window.scrollTo({top:document.querySelector('nav.tabs').offsetTop,behavior:'smooth'});
}
tabs.forEach(b=>b.addEventListener('click',()=>showView(b.dataset.view)));
```

## 3. Abstraction ladder (Product view)

Two-column grid: sticky rung sidebar (left) + content panel (right);
stacks on narrow screens. Each rung sets its accent via a CSS custom
property so one rule colors everything:

```html
<div class="ladder">
  <div class="rungs">
    <button class="rung on" data-lvl="context"  data-depth="0" style="--lc:var(--cyan)">…</button>
    <button class="rung"    data-lvl="operation" data-depth="1" style="--lc:var(--green)">…</button>
    …
  </div>
  <div>
    <div class="lvl on" id="lvl-context" style="--lc:var(--cyan)"> <div class="lvlhead">…</div> …content… </div>
    <div class="lvl"    id="lvl-operation" …> … </div>
  </div>
</div>
```

```js
const rungs=document.querySelectorAll('.rung');
function showLevel(id){
  rungs.forEach(r=>r.classList.toggle('on',r.dataset.lvl===id));
  document.querySelectorAll('.lvl').forEach(l=>l.classList.toggle('on',l.id==='lvl-'+id));
}
rungs.forEach(r=>r.addEventListener('click',()=>showLevel(r.dataset.lvl)));
```

Rung styling: left border + dot that lights with `--lc` when `.on`;
indent by `data-depth` (a spacer span widened per depth). Give each
level a `.lvlhead` banner (level tag, title, one-paragraph summary with
source IDs). End each level with prev/next buttons (`data-go`) that
call `showLevel` and scroll the ladder into view.

## 4. Pan & zoom SVG (every diagram)

Wrap each SVG in a `.viz` frame with corner zoom buttons and a hint
line. The SVG's content lives in a single `<g class="world">`. This
implementation is verified: wheel-zoom at cursor, pointer drag,
buttons, and a guard so a drag doesn't fire node clicks.

```js
document.querySelectorAll('.viz[data-panzoom]').forEach(viz=>{
  const svg=viz.querySelector('svg'), world=svg.querySelector('.world');
  let s=1,tx=0,ty=0,drag=null,moved=false;
  const apply=()=>world.setAttribute('transform',`translate(${tx},${ty}) scale(${s})`);
  const toSvg=(cx,cy)=>{const r=svg.getBoundingClientRect(),vb=svg.viewBox.baseVal;
    return [(cx-r.left)*vb.width/r.width,(cy-r.top)*vb.height/r.height];};
  const zoomAt=(px,py,k)=>{const ns=Math.min(9,Math.max(.3,s*k));
    tx=px-(px-tx)*(ns/s); ty=py-(py-ty)*(ns/s); s=ns; apply();};
  svg.addEventListener('wheel',e=>{e.preventDefault();
    const [px,py]=toSvg(e.clientX,e.clientY); zoomAt(px,py,e.deltaY<0?1.18:1/1.18);},{passive:false});
  svg.addEventListener('pointerdown',e=>{drag={x:e.clientX,y:e.clientY,tx,ty};moved=false;
    svg.setPointerCapture(e.pointerId);viz.classList.add('grabbing');});
  svg.addEventListener('pointermove',e=>{if(!drag)return;
    const r=svg.getBoundingClientRect(),vb=svg.viewBox.baseVal;
    if(Math.abs(e.clientX-drag.x)+Math.abs(e.clientY-drag.y)>4)moved=true;
    tx=drag.tx+(e.clientX-drag.x)*vb.width/r.width;
    ty=drag.ty+(e.clientY-drag.y)*vb.height/r.height; apply();});
  const end=()=>{drag=null;viz.classList.remove('grabbing');};
  svg.addEventListener('pointerup',end); svg.addEventListener('pointercancel',end);
  svg.addEventListener('click',e=>{if(moved){e.stopPropagation();}},true);
  viz.querySelectorAll('.zoombar button').forEach(btn=>btn.addEventListener('click',()=>{
    const vb=svg.viewBox.baseVal,cx=vb.width/2,cy=vb.height/2;
    if(btn.dataset.z==='in')zoomAt(cx,cy,1.3);
    else if(btn.dataset.z==='out')zoomAt(cx,cy,1/1.3);
    else{s=1;tx=0;ty=0;apply();}
  }));
});
```

SVG conventions: hand-author coordinates in a generous `viewBox`
(~1440 wide); define arrow `<marker>`s once per accent color; animate
flow edges with `stroke-dasharray` + a `stroke-dashoffset` keyframe
(`.flowdash`); clickable nodes are `<g class="node" data-info="key">`
with a hover brightness/drop-shadow.

## 5. Detail drawer

Fixed right panel + scrim; driven by a single `INFO` dictionary so all
clickable things share one mechanism:

```js
const INFO={ nodeKey:{tag:'CATEGORY · SUBCATEGORY',title:'…',html:`<p>…</p>
  <p class="refs"><span class="specref">Spec §… · <em>D-…, TC-…</em></span></p>`}, … };
function openInfo(key){ /* fill #dtag/#dtitle/#dbody, add .open to drawer+scrim */ }
document.querySelectorAll('[data-info]').forEach(el=>el.addEventListener('click',()=>openInfo(el.dataset.info)));
// close: ✕ button, scrim click, Escape key
```

Every drawer body ends with a `.refs` line citing source sections/IDs.

## 6. Specialized components (use when the content calls for them)

- **Byte bars** (fixed-layout records): a flex row where each field's
  width is proportional to its byte length; hover tooltip shows name,
  declared type (e.g. PIC clause), offset, length, and role; a ruler
  row below with byte indices. Color-code validated vs pass-through
  fields.
- **Mode toggle** (runtime modes / feature-flag states): buttons set a
  mode; diagram groups get `.lit`/`.dim` classes (opacity transition);
  role labels inside nodes update via `textContent` (e.g.
  AUTHORITATIVE / MIRROR / OFF).
- **Signature-quirk simulator**: render the rule list as toggle rows;
  recompute the output artifact live (e.g. the exact reject record with
  padding made visible as `·`), highlight the "winning" rule, and show
  the counter implications. This is usually the page's most valuable
  20 lines of JS.
- **NFR lens chips**: a chip row + one panel; each lens lists 2–4
  bullets, each prefixed with the ladder level it speaks to.
- **Risk matrix**: CSS grid likelihood × severity, heat-tinted cells
  (`--heat` custom property), risk chips opening the drawer.
- **Traffic/phase bars**: thin striped bars (legacy color vs new color
  vs ghost) to show authority shifting across migration phases.
- **Rollout stepper**: CSS counter on numbered steps; gated steps get
  an amber ring and a gate chip.
- **Disclaimer block**: a dashed amber box, used wherever the page
  shows estimated (non-normative) durations/effort.

## 7. Verification checklist (Step 5 of SKILL.md)

- Serve over HTTP; `file:` is blocked for browser tooling.
- Console: zero errors (favicon 404 acceptable).
- Screenshot and *look at*: each view; at least two ladder levels; the
  simulator with 2+ toggles on; every mode of the mode toggle; the
  drawer open from a diagram node AND from a risk chip; one diagram
  zoomed in.
- Verify zoom actually transforms (`world.getAttribute('transform')`).
- Common defects to hunt visually: SVG text overflowing node boxes,
  unreadable low-contrast labels, tab content bleeding between views,
  drawer not closing on Escape.
- Clean up: kill the server, delete screenshots and `.playwright-mcp/`.
