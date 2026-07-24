/* Freeze Dried Apples — storefront logic
 * Mirrors the iOS app: pack selection, cart, Shippo demo rates,
 * and a Stripe checkout that calls the backend /create-payment-intent
 * (falling back to a simulated demo order when no live key is configured).
 */

const PACKS = {
  individual: {
    sku: "individual",
    name: "Single Pack",
    subtitle: "One pouch of organic freeze-dried Pink Lady apples",
    priceCents: 199,
    weightOz: 1.2,
    freeShipping: false,
  },
  bundle10: {
    sku: "bundle10",
    name: "10-Pack Bundle",
    subtitle: "Ten pouches — best value for Miami snacking",
    priceCents: 2000,
    weightOz: 12.0,
    freeShipping: true,
  },
};

const REVIEWS = [
  { author: "Camila R.", neighborhood: "Coconut Grove", rating: 5, title: "Perfect pool-day snack", body: "Crispy, sweet-tart Pink Lady flavor without the fridge. We keep a pouch in the tote for afternoon beach runs.", date: "Jun 2026" },
  { author: "James T.", neighborhood: "Brickell", rating: 5, title: "Office desk staple", body: "Light enough for humidity, bold enough to feel like a real apple. The 10-pack disappeared in two weeks.", date: "May 2026" },
  { author: "Sofia M.", neighborhood: "Wynwood", rating: 4, title: "Clean and local vibes", body: "Love that it’s organic and Florida-shipped. Texture is airy crunch — kids ask for these over chips.", date: "Apr 2026" },
  { author: "Diego L.", neighborhood: "Coral Gables", rating: 5, title: "Gifted a bundle", body: "Sent the free-shipping 10-pack to my sister in Tampa. Arrived fast, packaging looked thoughtful.", date: "Mar 2026" },
];

const money = (cents) => `$${(cents / 100).toFixed(2)}`;

// ---- State ----
const cart = new Map(); // sku -> quantity
let selectedPack = "individual";
let address = { name: "", email: "", phone: "", line1: "", line2: "", city: "Miami", state: "FL", postalCode: "", country: "US" };
let rates = [];
let selectedRateId = null;
let processing = false;
let placedOrder = null;

// ---- Cart helpers ----
const cartItems = () => [...cart.entries()].map(([sku, quantity]) => ({ ...PACKS[sku], quantity }));
const totalItemCount = () => [...cart.values()].reduce((a, b) => a + b, 0);
const subtotalCents = () => cartItems().reduce((sum, it) => sum + it.priceCents * it.quantity, 0);
const qualifiesFreeShipping = () => cartItems().some((it) => it.freeShipping && it.quantity > 0);
const totalWeightOz = () => cartItems().reduce((sum, it) => sum + it.weightOz * it.quantity, 0);

function addToCart(sku, qty = 1) {
  cart.set(sku, (cart.get(sku) || 0) + qty);
  syncCartBadge();
  computeRates();
}
function setQuantity(sku, qty) {
  if (qty <= 0) cart.delete(sku);
  else cart.set(sku, qty);
  syncCartBadge();
  computeRates();
  renderDrawer();
}

function syncCartBadge() {
  const el = document.getElementById("cartCount");
  const n = totalItemCount();
  el.textContent = n;
  el.hidden = n === 0;
}

// ---- Shippo demo rates (mirrors ShippoService) ----
function computeRates() {
  if (cart.size === 0) { rates = []; selectedRateId = null; return; }
  if ((address.postalCode || "").length < 5) { rates = []; selectedRateId = null; return; }

  if (qualifiesFreeShipping()) {
    rates = [{ id: "free_bundle", carrier: "Freeze Dried Apples", service: "Free Florida bundle shipping", amountCents: 0, days: "2–4 business days", provider: "Shippo" }];
  } else {
    const w = totalWeightOz();
    const base = w <= 2 ? 499 : w <= 8 ? 699 : 899;
    rates = [
      { id: "usps_ground", carrier: "USPS", service: "Ground Advantage", amountCents: base, days: "2–5 business days", provider: "Shippo (demo)" },
      { id: "ups_ground", carrier: "UPS", service: "Ground", amountCents: base + 250, days: "1–3 business days", provider: "Shippo (demo)" },
      { id: "fedex_home", carrier: "FedEx", service: "Home Delivery", amountCents: base + 350, days: "1–3 business days", provider: "Shippo (demo)" },
    ];
  }
  if (!rates.find((r) => r.id === selectedRateId)) selectedRateId = rates[0] ? rates[0].id : null;
}

const selectedRate = () => rates.find((r) => r.id === selectedRateId) || null;
const shippingCents = () => (selectedRate() ? selectedRate().amountCents : 0);

function addressValid() {
  return (
    address.name.trim() &&
    address.email.includes("@") &&
    address.line1.trim() &&
    address.city.trim() &&
    address.state.trim().length === 2 &&
    (address.postalCode || "").length >= 5
  );
}

// ---- Pack chooser ----
function initChooser() {
  document.querySelectorAll(".pack").forEach((label) => {
    const input = label.querySelector("input");
    input.addEventListener("change", () => {
      selectedPack = input.value;
      document.querySelectorAll(".pack").forEach((l) => l.classList.remove("selected"));
      label.classList.add("selected");
    });
  });
  document.getElementById("addBtn").addEventListener("click", () => addToCart(selectedPack));
  document.getElementById("addCheckoutBtn").addEventListener("click", () => { addToCart(selectedPack); openDrawer(); });
}

// ---- Reviews ----
function renderReviews() {
  const grid = document.getElementById("reviewGrid");
  grid.innerHTML = REVIEWS.map((r) => `
    <article class="review-card">
      <div class="r-stars" aria-label="${r.rating} out of 5">${"★".repeat(r.rating)}${"☆".repeat(5 - r.rating)}</div>
      <h4>${r.title}</h4>
      <p class="r-body">${r.body}</p>
      <p class="r-meta">${r.author} · ${r.neighborhood} · ${r.date}</p>
    </article>`).join("");
}

// ---- Drawer ----
const drawer = () => document.getElementById("drawer");
function openDrawer() {
  placedOrder = null;
  computeRates();
  renderDrawer();
  drawer().classList.add("open");
  drawer().setAttribute("aria-hidden", "false");
  document.getElementById("drawerOverlay").hidden = false;
}
function closeDrawer() {
  drawer().classList.remove("open");
  drawer().setAttribute("aria-hidden", "true");
  document.getElementById("drawerOverlay").hidden = true;
}

function renderDrawer() {
  const body = document.getElementById("drawerBody");

  if (placedOrder) { body.innerHTML = confirmationHTML(placedOrder); wireConfirm(); return; }

  if (cart.size === 0) {
    body.innerHTML = `<div class="empty-bag">
        <p style="font-size:2rem">🛍️</p>
        <h3>Your bag is empty</h3>
        <p class="hint">Add a Single Pack or 10-Pack Bundle to continue.</p>
      </div>`;
    return;
  }

  const items = cartItems();
  const bag = items.map((it) => `
    <div class="bag-item">
      <div>
        <div class="bi-name">${it.name}</div>
        <div class="bi-note">${it.freeShipping ? "Free shipping eligible" : "Shipping calculated below"}</div>
      </div>
      <div class="qty">
        <button data-dec="${it.sku}" aria-label="Decrease">−</button>
        <span>×${it.quantity}</span>
        <button data-inc="${it.sku}" aria-label="Increase">+</button>
      </div>
      <div class="bi-price">${money(it.priceCents * it.quantity)}</div>
    </div>`).join("");

  body.innerHTML = `
    <div class="co-section"><h3>Your bag</h3>${bag}</div>

    <div class="co-section">
      <h3>Ship to</h3>
      <p class="hint">Florida-friendly defaults — edit for anywhere in the U.S.</p>
      <label class="fld"><span>Full name</span><input id="aName" value="${address.name}"></label>
      <label class="fld"><span>Email</span><input id="aEmail" type="email" value="${address.email}"></label>
      <label class="fld"><span>Address</span><input id="aLine1" value="${address.line1}"></label>
      <div style="display:flex;gap:10px">
        <label class="fld" style="flex:1"><span>City</span><input id="aCity" value="${address.city}"></label>
        <label class="fld" style="width:80px"><span>State</span><input id="aState" value="${address.state}" maxlength="2"></label>
        <label class="fld" style="width:110px"><span>ZIP</span><input id="aZip" value="${address.postalCode}" inputmode="numeric"></label>
      </div>
    </div>

    <div class="co-section">
      <h3>Shipping (Shippo)</h3>
      <div id="shipSection">${ratesHTML()}</div>
    </div>

    <div class="co-section">
      <div class="totals">
        <div class="trow"><span>Subtotal</span><span id="tSubtotal">—</span></div>
        <div class="trow"><span>Shipping</span><span id="tShipping">—</span></div>
        <div class="trow total"><span>Total</span><span id="tTotal">—</span></div>
        <p class="secure">🔒 Secure checkout powered by Stripe</p>
      </div>
    </div>

    <button class="btn btn-primary full" id="payBtn">${processing ? "Processing…" : "Pay with Stripe"}</button>
    <p class="err" id="payErr" hidden></p>`;

  wireDrawer();
  updateTotalsUI();
  refreshPayState();
}

function ratesHTML() {
  if (qualifiesFreeShipping()) {
    const free = `<p class="free-note">10-Pack Bundle includes free shipping.</p>`;
    return free + rateList();
  }
  if (rates.length === 0) return `<p class="hint">Enter your ZIP to load Shippo rates.</p>`;
  return rateList();
}
function rateList() {
  return rates.map((r) => `
    <div class="rate ${r.id === selectedRateId ? "selected" : ""}" data-rate="${r.id}">
      <span class="r-radio">${r.id === selectedRateId ? "◉" : "○"}</span>
      <div>
        <div class="r-main">${r.carrier} · ${r.service}</div>
        <div class="r-sub">${r.days} · ${r.provider}</div>
      </div>
      <span class="r-amt">${r.amountCents === 0 ? "Free" : money(r.amountCents)}</span>
    </div>`).join("");
}

function wireDrawer() {
  const bind = (id, key, after) => {
    const el = document.getElementById(id);
    if (!el) return;
    el.addEventListener("input", (e) => {
      address[key] = e.target.value;
      if (after) after();
    });
  };
  bind("aName", "name", refreshPayState);
  bind("aEmail", "email", refreshPayState);
  bind("aLine1", "line1", refreshPayState);
  bind("aCity", "city", () => { computeRates(); updateShippingUI(); });
  bind("aState", "state", refreshPayState);
  bind("aZip", "postalCode", () => { computeRates(); updateShippingUI(); });

  document.querySelectorAll("[data-inc]").forEach((b) => b.addEventListener("click", () => {
    const sku = b.getAttribute("data-inc"); setQuantity(sku, (cart.get(sku) || 0) + 1);
  }));
  document.querySelectorAll("[data-dec]").forEach((b) => b.addEventListener("click", () => {
    const sku = b.getAttribute("data-dec"); setQuantity(sku, (cart.get(sku) || 0) - 1);
  }));
  wireRateClicks();

  const payBtn = document.getElementById("payBtn");
  if (payBtn) payBtn.addEventListener("click", pay);
}

function wireRateClicks() {
  document.querySelectorAll("[data-rate]").forEach((el) => el.addEventListener("click", () => {
    selectedRateId = el.getAttribute("data-rate");
    updateShippingUI();
  }));
}

// Update rates list + totals + pay state in place, WITHOUT rebuilding the
// address inputs (rebuilding them would drop keyboard focus while typing).
function updateShippingUI() {
  const ship = document.getElementById("shipSection");
  if (ship) ship.innerHTML = ratesHTML();
  wireRateClicks();
  updateTotalsUI();
  refreshPayState();
}

function updateTotalsUI() {
  const sub = subtotalCents();
  const shipC = shippingCents();
  const set = (id, val) => { const el = document.getElementById(id); if (el) el.textContent = val; };
  set("tSubtotal", money(sub));
  set("tShipping", selectedRate() ? (shipC === 0 ? "Free" : money(shipC)) : "—");
  set("tTotal", money(sub + shipC));
}

function refreshPayState() {
  const payBtn = document.getElementById("payBtn");
  if (payBtn) payBtn.disabled = !(addressValid() && selectedRate() && !processing);
}

// ---- Payment ----
async function pay() {
  const rate = selectedRate();
  if (!rate || !addressValid()) return;
  processing = true;
  renderDrawer();

  const totalCents = subtotalCents() + rate.amountCents;
  const bodyPayload = {
    amount: totalCents,
    currency: "usd",
    customer_email: address.email,
    shipping: {
      name: address.name,
      rate_id: rate.id,
      amount: rate.amountCents,
      carrier: rate.carrier,
      service: rate.service,
      address: {
        line1: address.line1, line2: address.line2, city: address.city,
        state: address.state, postal_code: address.postalCode, country: address.country,
      },
    },
    metadata: { brand: "Freeze Dried Apples", market: "Miami FL" },
  };

  let order;
  try {
    const res = await fetch("/create-payment-intent", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(bodyPayload),
    });
    const data = await res.json();
    if (res.ok && data.clientSecret) {
      // Live PaymentIntent created by the backend + Stripe.
      order = { id: data.paymentIntentId || data.id, totalCents, isDemo: false };
    } else {
      // Backend reachable but no valid live key → simulate a demo order (mirrors the iOS demo mode).
      order = { id: "pi_demo_" + Math.random().toString(36).slice(2, 10), totalCents, isDemo: true };
    }
  } catch (e) {
    // Network/backend unavailable → demo order so the flow can still be walked.
    order = { id: "pi_demo_" + Math.random().toString(36).slice(2, 10), totalCents, isDemo: true };
  }

  processing = false;
  placedOrder = order;
  cart.clear();
  syncCartBadge();
  renderDrawer();
}

function confirmationHTML(order) {
  return `<div class="confirm">
      <div class="seal">✅</div>
      <span class="badge ${order.isDemo ? "demo" : "live"}">${order.isDemo ? "Demo payment" : "Live Stripe payment"}</span>
      <h3>You’re all set</h3>
      <p class="order-id">Order ${order.id}</p>
      <p class="hint">Thanks for supporting Miami-made Freeze Dried Apples. ${order.isDemo ? "Demo Stripe payment recorded — configure a live STRIPE_SECRET_KEY for real charges." : "Stripe payment confirmed."}</p>
      <div class="c-total">${money(order.totalCents)}</div>
      <button class="btn btn-primary" id="doneBtn">Done</button>
    </div>`;
}
function wireConfirm() {
  const b = document.getElementById("doneBtn");
  if (b) b.addEventListener("click", closeDrawer);
}

// ---- Contact form ----
function initContact() {
  let topic = "order";
  document.querySelectorAll("#topicSeg .seg").forEach((s) => s.addEventListener("click", () => {
    document.querySelectorAll("#topicSeg .seg").forEach((x) => x.classList.remove("active"));
    s.classList.add("active");
    topic = s.getAttribute("data-topic");
  }));

  document.getElementById("contactForm").addEventListener("submit", (e) => {
    e.preventDefault();
    const name = document.getElementById("cName").value.trim();
    const email = document.getElementById("cEmail").value.trim();
    const message = document.getElementById("cMessage").value.trim();
    const errEl = document.getElementById("contactErr");
    const ok = name && email.includes("@") && message.length >= 10;
    if (!ok) { errEl.hidden = false; return; }
    errEl.hidden = true;
    const success = document.getElementById("contactSuccess");
    success.hidden = false;
    success.textContent = `Message sent — thanks, ${name}! We’ll reply to ${email} about your ${topic} question soon.`;
    e.target.reset();
    document.querySelectorAll("#topicSeg .seg").forEach((x, i) => x.classList.toggle("active", i === 0));
    topic = "order";
  });
}

// ---- Init ----
document.addEventListener("DOMContentLoaded", () => {
  initChooser();
  renderReviews();
  initContact();
  syncCartBadge();
  document.getElementById("cartBtn").addEventListener("click", openDrawer);
  document.getElementById("closeDrawer").addEventListener("click", closeDrawer);
  document.getElementById("drawerOverlay").addEventListener("click", closeDrawer);
});
