import { useEffect, useRef, useState } from "react";

const TABLE_W = 238;
const ROW_H = 24;
const HEADER_H = 38;
const DIVIDER_H = 9;

const TABLES = [
    { id: "users", icon: "👤", label: "users", x: 60, y: 70, cols: [{ b: "PK", n: "user_id", t: "int auto_inc" }, null, { b: "", n: "first_name", t: "varchar" }, { b: "", n: "last_name", t: "varchar" }, { b: "", n: "email", t: "varchar" }, { b: "", n: "phone", t: "varchar" }, { b: "", n: "password_hash", t: "varchar" }, { b: "", n: "is_active", t: "tinyint" }, { b: "", n: "created_at", t: "timestamp" }, { b: "", n: "updated_at", t: "timestamp" }] },
    { id: "addresses", icon: "📍", label: "addresses", x: 60, y: 460, cols: [{ b: "PK", n: "address_id", t: "int auto_inc" }, null, { b: "FK", n: "user_id", t: "int" }, { b: "", n: "label", t: "varchar" }, { b: "", n: "street", t: "varchar" }, { b: "", n: "city", t: "varchar" }, { b: "", n: "state", t: "varchar" }, { b: "", n: "postal_code", t: "varchar" }, { b: "", n: "country", t: "varchar" }, { b: "", n: "is_default", t: "tinyint" }] },
    { id: "categories", icon: "🏷️", label: "categories", x: 430, y: 70, cols: [{ b: "PK", n: "category_id", t: "int auto_inc" }, null, { b: "", n: "name", t: "varchar" }, { b: "FK", n: "parent_id", t: "int ↺ self" }, { b: "", n: "description", t: "text" }, { b: "", n: "created_at", t: "timestamp" }] },
    { id: "products", icon: "📦", label: "products", x: 430, y: 330, cols: [{ b: "PK", n: "product_id", t: "int auto_inc" }, null, { b: "FK", n: "category_id", t: "int" }, { b: "", n: "name", t: "varchar" }, { b: "", n: "description", t: "text" }, { b: "", n: "price", t: "decimal" }, { b: "", n: "stock_qty", t: "int" }, { b: "", n: "sku", t: "varchar" }, { b: "", n: "brand", t: "varchar" }, { b: "", n: "is_active", t: "tinyint" }, { b: "", n: "updated_at", t: "timestamp" }] },
    { id: "product_images", icon: "🖼️", label: "product_images", x: 430, y: 780, cols: [{ b: "PK", n: "image_id", t: "int auto_inc" }, null, { b: "FK", n: "product_id", t: "int" }, { b: "", n: "image_url", t: "varchar" }, { b: "", n: "is_primary", t: "tinyint" }, { b: "", n: "created_at", t: "timestamp" }] },
    { id: "orders", icon: "🧾", label: "orders", x: 840, y: 200, cols: [{ b: "PK", n: "order_id", t: "int auto_inc" }, null, { b: "FK", n: "user_id", t: "int" }, { b: "FK", n: "address_id", t: "int" }, { b: "", n: "status", t: "varchar" }, { b: "", n: "total_amount", t: "decimal" }, { b: "", n: "discount_amount", t: "decimal" }, { b: "", n: "tax_amount", t: "decimal" }, { b: "", n: "shipping_fee", t: "decimal" }, { b: "", n: "ordered_at", t: "timestamp" }, { b: "", n: "updated_at", t: "timestamp" }] },
    { id: "order_items", icon: "📋", label: "order_items", x: 840, y: 680, cols: [{ b: "PK", n: "item_id", t: "int auto_inc" }, null, { b: "FK", n: "order_id", t: "int" }, { b: "FK", n: "product_id", t: "int" }, { b: "", n: "quantity", t: "int" }, { b: "", n: "unit_price", t: "decimal" }, { b: "", n: "subtotal", t: "generated" }] },
    { id: "payments", icon: "💳", label: "payments", x: 1250, y: 70, cols: [{ b: "PK", n: "payment_id", t: "int auto_inc" }, null, { b: "FK", n: "order_id", t: "int" }, { b: "", n: "amount", t: "decimal" }, { b: "", n: "method", t: "varchar" }, { b: "", n: "status", t: "varchar" }, { b: "", n: "transaction_id", t: "varchar" }, { b: "", n: "paid_at", t: "timestamp" }] },
    { id: "reviews", icon: "⭐", label: "reviews", x: 1250, y: 440, cols: [{ b: "PK", n: "review_id", t: "int auto_inc" }, null, { b: "FK", n: "product_id", t: "int" }, { b: "FK", n: "user_id", t: "int" }, { b: "", n: "rating", t: "smallint" }, { b: "", n: "title", t: "varchar" }, { b: "", n: "body", t: "text" }, { b: "", n: "is_verified", t: "tinyint" }, { b: "", n: "created_at", t: "timestamp" }] },
    { id: "coupons", icon: "🎟️", label: "coupons", x: 1250, y: 830, cols: [{ b: "PK", n: "coupon_id", t: "int auto_inc" }, null, { b: "", n: "code", t: "varchar UK" }, { b: "", n: "discount_type", t: "enum" }, { b: "", n: "discount_value", t: "decimal" }, { b: "", n: "min_order_amount", t: "decimal" }, { b: "", n: "max_discount", t: "decimal" }, { b: "", n: "max_uses", t: "int" }, { b: "", n: "times_used", t: "int" }, { b: "", n: "is_active", t: "tinyint" }, { b: "", n: "expires_at", t: "timestamp" }] },
    { id: "wishlists", icon: "💝", label: "wishlists", x: 60, y: 830, cols: [{ b: "PK", n: "wishlist_id", t: "int auto_inc" }, null, { b: "FK", n: "user_id", t: "int" }, { b: "FK", n: "product_id", t: "int" }, { b: "", n: "created_at", t: "timestamp" }] },
    { id: "cart_items", icon: "🛒", label: "cart_items", x: 430, y: 1060, cols: [{ b: "PK", n: "cart_item_id", t: "int auto_inc" }, null, { b: "FK", n: "user_id", t: "int" }, { b: "FK", n: "product_id", t: "int" }, { b: "", n: "quantity", t: "int" }, { b: "", n: "created_at", t: "timestamp" }, { b: "", n: "updated_at", t: "timestamp" }] },
];

const RELS = [
    { from: "users", fe: "b", to: "addresses", te: "t", label: "1:N", color: "#7c6af7" },
    { from: "users", fe: "r", to: "orders", te: "l", label: "1:N", color: "#7c6af7" },
    { from: "users", fe: "r", to: "reviews", te: "l", label: "1:N", color: "#7c6af7" },
    { from: "addresses", fe: "r", to: "orders", te: "l", label: "1:N", color: "#f7926a" },
    { from: "categories", fe: "b", to: "products", te: "t", label: "1:N", color: "#6af7c8" },
    { from: "products", fe: "b", to: "product_images", te: "t", label: "1:N", color: "#f7d26a" },
    { from: "products", fe: "r", to: "order_items", te: "l", label: "1:N", color: "#f7d26a" },
    { from: "products", fe: "r", to: "reviews", te: "l", label: "1:N", color: "#f7d26a" },
    { from: "orders", fe: "b", to: "order_items", te: "t", label: "1:N", color: "#6af7c8" },
    { from: "orders", fe: "r", to: "payments", te: "l", label: "1:1", color: "#f7926a" },
    { from: "users", fe: "b", to: "wishlists", te: "t", label: "1:N", color: "#7c6af7" },
    { from: "products", fe: "b", to: "wishlists", te: "r", label: "1:N", color: "#f7d26a" },
    { from: "users", fe: "b", to: "cart_items", te: "l", label: "1:N", color: "#7c6af7" },
    { from: "products", fe: "b", to: "cart_items", te: "t", label: "1:N", color: "#f7d26a" },
];

function tblH(cols) {
    return HEADER_H + 8 + cols.reduce((a, c) => a + (c === null ? DIVIDER_H : ROW_H), 0) + 6;
}

function edgePt(tbl, edge) {
    const h = tblH(tbl.cols);
    if (edge === "r") return { x: tbl.x + TABLE_W, y: tbl.y + h / 2 };
    if (edge === "l") return { x: tbl.x, y: tbl.y + h / 2 };
    if (edge === "b") return { x: tbl.x + TABLE_W / 2, y: tbl.y + h };
    return { x: tbl.x + TABLE_W / 2, y: tbl.y };
}

function ColRow({ col }) {
    if (col === null) return <div style={{ height: DIVIDER_H, background: "#1e1e2e" }} />;
    const bs = col.b === "PK"
        ? { bg: "rgba(247,210,106,.13)", color: "#f7d26a", border: "1px solid rgba(247,210,106,.3)" }
        : col.b === "FK"
            ? { bg: "rgba(247,146,106,.1)", color: "#f7926a", border: "1px solid rgba(247,146,106,.3)" }
            : { bg: "transparent", color: "transparent", border: "1px solid transparent" };
    const nc = col.b === "PK" ? "#f7d26a" : col.b === "FK" ? "#f7926a" : "#a8b8d8";
    const fw = col.b === "PK" ? 700 : 400;
    return (
        <div style={{ display: "flex", alignItems: "center", gap: 6, padding: "3.5px 12px", fontSize: 10.5 }}>
            <span style={{ fontSize: 9, fontWeight: 700, padding: "1px 4px", borderRadius: 3, minWidth: 22, textAlign: "center", background: bs.bg, color: bs.color, border: bs.border, letterSpacing: .4, flexShrink: 0 }}>
                {col.b || "  "}
            </span>
            <span style={{ flex: 1, color: nc, fontWeight: fw, fontFamily: "monospace", fontSize: 10.5, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{col.n}</span>
            <span style={{ color: "#5a5a7a", fontSize: 9.5, fontFamily: "monospace", flexShrink: 0 }}>{col.t}</span>
        </div>
    );
}

function TableCard({ tbl, hovered, onHover }) {
    return (
        <div onMouseEnter={() => onHover(tbl.id)} onMouseLeave={() => onHover(null)}
            style={{
                position: "absolute", left: tbl.x, top: tbl.y, width: TABLE_W, background: "#111118",
                border: `1px solid ${hovered ? "#7c6af7" : "#1e1e2e"}`, borderRadius: 10, overflow: "hidden",
                boxShadow: hovered ? "0 0 0 1px #7c6af7,0 8px 32px rgba(124,106,247,.18)" : "none",
                transition: "border-color .2s,box-shadow .2s", cursor: "default", userSelect: "none"
            }}>
            <div style={{
                padding: "10px 12px", background: hovered ? "#7c6af7" : "#181825",
                borderBottom: "1px solid #1e1e2e", display: "flex", alignItems: "center", gap: 7, transition: "background .2s"
            }}>
                <span style={{ fontSize: 14 }}>{tbl.icon}</span>
                <span style={{ fontFamily: "system-ui,sans-serif", fontWeight: 800, fontSize: 12.5, color: "#e8e8f0", letterSpacing: .3 }}>{tbl.label}</span>
            </div>
            <div style={{ padding: "4px 0" }}>
                {tbl.cols.map((c, i) => <ColRow key={i} col={c} />)}
            </div>
        </div>
    );
}

export default function ERDiagram() {
    const [hovered, setHovered] = useState(null);
    const [scale, setScale] = useState(0.48);
    const [pan, setPan] = useState({ x: 16, y: 10 });
    const dragging = useRef(false);
    const last = useRef({ x: 0, y: 0 });
    const wrapRef = useRef();
    const byId = Object.fromEntries(TABLES.map(t => [t.id, t]));

    const onDown = e => { dragging.current = true; last.current = { x: e.clientX, y: e.clientY }; };
    const onMove = e => {
        if (!dragging.current) return;
        setPan(p => ({ x: p.x + e.clientX - last.current.x, y: p.y + e.clientY - last.current.y }));
        last.current = { x: e.clientX, y: e.clientY };
    };
    const onUp = () => { dragging.current = false; };

    useEffect(() => {
        const el = wrapRef.current;
        const onWheel = e => {
            e.preventDefault();
            const r = el.getBoundingClientRect(), mx = e.clientX - r.left, my = e.clientY - r.top;
            const d = e.deltaY > 0 ? .92 : 1.08;
            setPan(p => ({ x: mx - (mx - p.x) * d, y: my - (my - p.y) * d }));
            setScale(s => Math.min(Math.max(s * d, .18), 2.2));
        };
        el.addEventListener("wheel", onWheel, { passive: false });
        return () => el.removeEventListener("wheel", onWheel);
    }, []);

    const zoomIn = () => setScale(s => Math.min(s * 1.15, 2.2));
    const zoomOut = () => setScale(s => Math.max(s * .87, .18));
    const fit = () => { setScale(.48); setPan({ x: 16, y: 10 }); };

    return (
        <div style={{ background: "#0a0a0f", height: "100vh", display: "flex", flexDirection: "column", overflow: "hidden", fontFamily: "'JetBrains Mono',monospace,system-ui" }}>
            {/* Header */}
            <div style={{ padding: "12px 24px", display: "flex", alignItems: "center", justifyContent: "space-between", background: "rgba(10,10,15,.95)", borderBottom: "1px solid #1e1e2e", flexShrink: 0, zIndex: 10 }}>
                <div>
                    <div style={{ fontWeight: 800, fontSize: 15, color: "#e8e8f0", letterSpacing: -.3 }}>E-Commerce DB — ER Diagram</div>
                    <div style={{ fontSize: 9.5, color: "#5a5a7a", letterSpacing: 2, textTransform: "uppercase", marginTop: 3 }}>MySQL 9.0+ · 12 Tables · 14 Relationships</div>
                </div>
                <div style={{ display: "flex", gap: 16, fontSize: 10 }}>
                    {[["#f7d26a", "Primary Key"], ["#f7926a", "Foreign Key"], ["#a8b8d8", "Column"]].map(([c, l]) => (
                        <div key={l} style={{ display: "flex", alignItems: "center", gap: 5, color: "#5a5a7a" }}>
                            <div style={{ width: 7, height: 7, borderRadius: 2, background: c, flexShrink: 0 }} />
                            {l}
                        </div>
                    ))}
                </div>
            </div>

            {/* Canvas */}
            <div ref={wrapRef} onMouseDown={onDown} onMouseMove={onMove} onMouseUp={onUp} onMouseLeave={onUp}
                style={{ flex: 1, overflow: "hidden", cursor: "grab", position: "relative", background: "#0a0a0f" }}>
                {/* Grid dots */}
                <svg style={{ position: "absolute", inset: 0, width: "100%", height: "100%", opacity: .3, pointerEvents: "none" }}>
                    <defs>
                        <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
                            <circle cx="20" cy="20" r="0.8" fill="#2a2a4a" />
                        </pattern>
                    </defs>
                    <rect width="100%" height="100%" fill="url(#grid)" />
                </svg>

                <div style={{ position: "absolute", transform: `translate(${pan.x}px,${pan.y}px) scale(${scale})`, transformOrigin: "0 0", width: 1900, height: 1500 }}>
                    <svg style={{ position: "absolute", top: 0, left: 0, width: "100%", height: "100%", pointerEvents: "none" }}>
                        {RELS.map((r, i) => {
                            const a = edgePt(byId[r.from], r.fe), b = edgePt(byId[r.to], r.te);
                            const cx = (a.x + b.x) / 2, mx = (a.x + b.x) / 2, my = (a.y + b.y) / 2 - 10;
                            return (
                                <g key={i}>
                                    <path d={`M${a.x},${a.y} C${cx},${a.y} ${cx},${b.y} ${b.x},${b.y}`}
                                        stroke={r.color} strokeWidth={1.5} fill="none" opacity={.6} />
                                    <circle cx={a.x} cy={a.y} r={4} fill={r.color} opacity={.9} />
                                    <circle cx={b.x} cy={b.y} r={4} fill={r.color} opacity={.9} />
                                    <text x={mx} y={my} textAnchor="middle" fill="#5a5a7a" fontSize={10} fontFamily="monospace">{r.label}</text>
                                </g>
                            );
                        })}
                    </svg>
                    {TABLES.map(t => <TableCard key={t.id} tbl={t} hovered={hovered === t.id} onHover={setHovered} />)}
                </div>

                {/* Zoom controls */}
                <div style={{ position: "absolute", bottom: 18, right: 18, display: "flex", flexDirection: "column", gap: 4, zIndex: 10 }}>
                    {[["＋", zoomIn], ["－", zoomOut], ["FIT", fit]].map(([l, fn]) => (
                        <button key={l} onClick={fn}
                            style={{
                                width: 34, height: 34, background: "#111118", border: "1px solid #1e1e2e", color: "#e8e8f0",
                                fontSize: l === "FIT" ? 10 : 16, cursor: "pointer", borderRadius: 7, fontFamily: "monospace",
                                display: "flex", alignItems: "center", justifyContent: "center"
                            }}>
                            {l}
                        </button>
                    ))}
                </div>
                <div style={{ position: "absolute", bottom: 22, left: 22, fontSize: 10, color: "#5a5a7a", letterSpacing: .5 }}>
                    Drag to pan · Scroll to zoom · Hover table to highlight
                </div>
            </div>
        </div>
    );
}