import SwiftUI

struct SealPalette: Identifiable, Hashable {
    let id: String
    let title: String
    let background: Color
    let line: Color
    let text: Color
    let highlight: Color

    static let wax = SealPalette(id: "wax", title: L("蜜蝋", "Wax"),
                                 background: Color(red: 0.42, green: 0.06, blue: 0.06),
                                 line: Color(red: 0.95, green: 0.78, blue: 0.45),
                                 text: Color(red: 1.0, green: 0.90, blue: 0.70),
                                 highlight: Color(red: 1.0, green: 0.97, blue: 0.80))
    static let manuscript = SealPalette(id: "manuscript", title: L("写本", "Manuscript"),
                                        background: Color(red: 0.94, green: 0.89, blue: 0.78),
                                        line: Color(red: 0.22, green: 0.15, blue: 0.10),
                                        text: Color(red: 0.18, green: 0.12, blue: 0.08),
                                        highlight: Color(red: 0.70, green: 0.10, blue: 0.08))
    static let night = SealPalette(id: "night", title: L("夜", "Night"),
                                   background: Color(red: 0.04, green: 0.04, blue: 0.07),
                                   line: Color(red: 0.80, green: 0.68, blue: 0.40),
                                   text: Color(red: 0.92, green: 0.84, blue: 0.62),
                                   highlight: Color(red: 0.55, green: 0.85, blue: 1.0))
    static let all = [wax, manuscript, night]
}

/// Radii as fractions of the seal's radius, outside in.
private enum R {
    static let ringOuter = 1.0, ringInner = 0.83
    static let ringLetter = 0.905, numberAbove = 0.963, numberBelow = 0.853
    static let cos7 = cos(Double.pi / 7)
    static let bandOuterApothem = ringInner * cos7          // outer heptagon touches the ring
    static let bandInnerApothem = bandOuterApothem - 0.075
    static let starRadius = bandInnerApothem / cos7          // heptagram points
    static let chordDistance = starRadius * cos(2 * Double.pi / 7)
    static let stripWidth = 0.05
    static let innerHeptagonRadius = chordDistance / cos7    // where the strips cross
    static let ddOuter = chordDistance - stripWidth / 2, ddInner = ddOuter - 0.058
    static let ssInner = ddInner - 0.058
    static let zabathielApothem = ssInner - 0.045
    static let pentagramRadius = zabathielApothem - 0.035
}

struct SealCanvas: View {
    var palette: SealPalette = .wax
    /// Layers drawn (in order received); fewer while the build animation runs.
    var visibleLayers: Int = Layer.allCases.count
    var focus: Layer? = nil
    var ringName: RingName? = nil

    var body: some View {
        Canvas { ctx, size in
            let radius = min(size.width, size.height) / 2 * 0.97
            let g = Geo(center: CGPoint(x: size.width / 2, y: size.height / 2), radius: radius)
            ctx.fill(Path(ellipseIn: g.rect(1.0)), with: .color(palette.background))

            for layer in Layer.allCases.prefix(visibleLayers) {
                let dim = focus != nil && focus != layer
                let lineColor = dim ? palette.line.opacity(0.22) : (focus == layer ? palette.highlight : palette.line)
                let textColor = dim ? palette.text.opacity(0.22) : (focus == layer ? palette.highlight : palette.text)
                draw(layer, ctx: &ctx, g: g, line: lineColor, text: textColor)
            }
            if let ringName { drawPath(ringName, ctx: &ctx, g: g) }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityLabel(L("神の真理の印章", "Sigillum Dei Aemeth"))
    }

    // MARK: Layers

    private func draw(_ layer: Layer, ctx: inout GraphicsContext, g: Geo, line: Color, text: Color) {
        let lw = max(g.radius * 0.004, 0.6)
        switch layer {
        case .ring:
            ctx.stroke(Path(ellipseIn: g.rect(R.ringOuter)), with: .color(line), lineWidth: lw * 1.6)
            ctx.stroke(Path(ellipseIn: g.rect(R.ringInner)), with: .color(line), lineWidth: lw * 1.6)
            for i in 0..<40 {
                let a = Double(i) * 9
                ctx.stroke(Path { p in p.move(to: g.pt(R.ringInner, a)); p.addLine(to: g.pt(R.ringOuter, a)) },
                           with: .color(line.opacity(0.7)), lineWidth: lw)
            }
            for cell in SealData.ring {
                let size = g.radius * 0.058
                g.text(&ctx, cell.letter, r: R.ringLetter, deg: cell.centerDeg, size: size, color: text, serif: true)
                if let n = cell.number, let pos = cell.position {
                    g.text(&ctx, "\(n)", r: pos == .above ? R.numberAbove : R.numberBelow, deg: cell.centerDeg,
                           size: g.radius * 0.03, color: text)
                }
            }

        case .sigils:
            for s in SealData.sigils {
                let r = (R.ringInner + R.bandOuterApothem) / 2 + 0.004
                g.text(&ctx, s.letter, r: r, deg: s.centerDeg, size: g.radius * 0.05, color: text, serif: true, bold: true)
                // the small cross Michael joined to each sign
                let c = g.pt(r + 0.032, s.centerDeg)
                var cross = ctx
                cross.translateBy(x: c.x, y: c.y)
                cross.rotate(by: .degrees(s.centerDeg))
                let k = g.radius * 0.012
                cross.stroke(Path { p in
                    p.move(to: CGPoint(x: -k, y: 0)); p.addLine(to: CGPoint(x: k, y: 0))
                    p.move(to: CGPoint(x: 0, y: -k)); p.addLine(to: CGPoint(x: 0, y: k))
                }, with: .color(line), lineWidth: lw)
                if let n = s.number {
                    g.text(&ctx, "\(n)", r: r, deg: s.centerDeg - 4.2, size: g.radius * 0.026, color: text)
                }
            }

        case .band:
            let outer = g.polygon(7, circumradius: R.bandOuterApothem / R.cos7, startDeg: 0)
            let inner = g.polygon(7, circumradius: R.starRadius, startDeg: 0)
            ctx.stroke(outer, with: .color(line), lineWidth: lw * 1.4)
            ctx.stroke(inner, with: .color(line), lineWidth: lw * 1.4)
            let midR = (R.bandOuterApothem + R.bandInnerApothem) / 2 / R.cos7
            for side in 0..<7 {
                let a0 = Double(side) * 360 / 7, a1 = Double(side + 1) * 360 / 7
                let letters = Array(SealData.table1[side])
                for j in 0..<7 {
                    let t = (Double(j) + 0.5) / 7
                    let p = g.lerp(g.pt(midR, a0), g.pt(midR, a1), t)
                    g.text(&ctx, String(letters[j]), at: p, deg: (a0 + a1) / 2, size: g.radius * 0.042, color: text, serif: true)
                    if j > 0 {
                        let tt = Double(j) / 7
                        let po = g.lerp(g.pt(R.bandOuterApothem / R.cos7, a0), g.pt(R.bandOuterApothem / R.cos7, a1), tt)
                        let pi = g.lerp(g.pt(R.starRadius, a0), g.pt(R.starRadius, a1), tt)
                        ctx.stroke(Path { p in p.move(to: po); p.addLine(to: pi) }, with: .color(line.opacity(0.6)), lineWidth: lw)
                    }
                }
            }

        case .godNames:
            for (row, tokens) in SealData.tokens.enumerated() {
                let mid = (Double(row) + 0.5) * 360 / 7
                let r = R.bandInnerApothem - 0.052
                let size = g.radius * 0.04
                // spread the tokens along the side, tops outward
                let span = 0.27
                for (j, tok) in tokens.enumerated() {
                    let offset = (Double(j) - 3) / 6 * span
                    let p = g.alongSide(apothem: r, midDeg: mid, offset: offset)
                    if !tok.letter.isEmpty {
                        g.text(&ctx, tok.letter, at: p, deg: mid, size: size, color: text, serif: true, bold: true)
                    }
                    if let note = tok.note {
                        let q = g.alongSide(apothem: r + 0.022, midDeg: mid, offset: offset + (tok.letter.isEmpty ? 0 : 0.022))
                        g.text(&ctx, note, at: q, deg: mid, size: g.radius * 0.019, color: text)
                    }
                }
            }

        case .heptagram:
            var star = ctx
            star.clip(to: g.polygon(7, circumradius: R.starRadius, startDeg: 0))
            for k in 0..<7 {
                let a = g.pt(R.starRadius, Double(k) * 360 / 7), b = g.pt(R.starRadius, Double(k + 2) * 360 / 7)
                for side in [-1.0, 1.0] {
                    let (p, q) = g.offsetLine(a, b, by: side * R.stripWidth / 2 * g.radius)
                    star.stroke(Path { $0.move(to: p); $0.addLine(to: q) }, with: .color(line), lineWidth: lw * 1.2)
                }
            }
            // Daughters of Light in the points
            for (k, name) in SealData.daughters.enumerated() {
                g.text(&ctx, name, r: R.starRadius - 0.135, deg: Double(k) * 360 / 7,
                       size: g.radius * 0.034, color: text, serif: true)
            }
            // Sons of Light along the strips
            for (k, name) in SealData.sons.enumerated() {
                let mid = SealData.sonStripMidDeg[k]
                g.text(&ctx, name, r: R.chordDistance, deg: mid, size: g.radius * 0.028, color: text, serif: true)
            }

        case .daughtersOfDaughters, .sonsOfSons:
            let isDD = layer == .daughtersOfDaughters
            let outerA = isDD ? R.ddOuter : R.ddInner
            let innerA = isDD ? R.ddInner : R.ssInner
            ctx.stroke(g.polygon(7, circumradius: outerA / R.cos7, startDeg: 360 / 14), with: .color(line), lineWidth: lw * 1.2)
            ctx.stroke(g.polygon(7, circumradius: innerA / R.cos7, startDeg: 360 / 14), with: .color(line), lineWidth: lw * 1.2)
            let names = isDD ? SealData.daughtersOfDaughters : SealData.sonsOfSons
            for (k, name) in names.enumerated() {
                g.text(&ctx, "+ " + name + " +", r: (outerA + innerA) / 2, deg: Double(k) * 360 / 7,
                       size: g.radius * 0.031, color: text, serif: true)
            }

        case .zabathiel:
            ctx.stroke(g.polygon(7, circumradius: R.zabathielApothem / R.cos7 + 0.012, startDeg: 360 / 14),
                       with: .color(line), lineWidth: lw)
            let letters = ["Z", "A", "B", "A", "T", "H", "I"]
            for (k, l) in letters.enumerated() {
                let deg = Double(k) * 360 / 7 - 6
                g.text(&ctx, l, r: R.zabathielApothem - 0.004, deg: deg, size: g.radius * 0.036, color: text, serif: true, bold: true)
                if k == 6 { g.text(&ctx, "21/8", r: R.zabathielApothem + 0.002, deg: deg + 5.5, size: g.radius * 0.016, color: text) }
            }

        case .pentagram:
            let star = g.pentagram(R.pentagramRadius)
            ctx.stroke(star, with: .color(line), lineWidth: lw * 4.5)
            ctx.stroke(star, with: .color(palette.background), lineWidth: lw * 2.2)
            for (k, p) in SealData.pentagram.enumerated() {
                let deg = Double(k) * 72
                g.text(&ctx, p.capital, r: R.pentagramRadius * 0.62, deg: deg, size: g.radius * 0.03, color: text, serif: true, bold: true)
                g.arcText(&ctx, p.rest, r: R.pentagramRadius * 0.86, centerDeg: deg + 36, size: g.radius * 0.022, color: text)
            }

        case .cross:
            let k = R.pentagramRadius * 0.3
            ctx.stroke(Path { p in
                p.move(to: g.pt(k, 0)); p.addLine(to: g.pt(k * 1.1, 180))
                p.move(to: g.pt(k * 0.75, 270)); p.addLine(to: g.pt(k * 0.75, 90))
            }, with: .color(line), lineWidth: lw)
            let s = g.radius * 0.016
            g.text(&ctx, "VA", r: k * 0.62, deg: 0, size: s, color: text, upright: true)
            g.text(&ctx, "LE", r: k * 0.55, deg: 270, size: s, color: text, upright: true, offsetY: -s * 0.8)
            g.text(&ctx, "NA", r: k * 0.55, deg: 90, size: s, color: text, upright: true, offsetY: -s * 0.8)
            g.text(&ctx, "el", r: k * 0.6, deg: 180, size: s, color: text, upright: true)
        }
    }

    /// Highlights a ring name: its cells, numbered, with arcs showing each count.
    private func drawPath(_ name: RingName, ctx: inout GraphicsContext, g: Geo) {
        let hl = palette.highlight
        for (n, idx) in name.path.enumerated() {
            let cell = SealData.ring[idx - 1]
            var wedge = Path()
            wedge.addArc(center: g.center, radius: g.radius * R.ringOuter, startAngle: .degrees(cell.centerDeg - 4.5 - 90),
                         endAngle: .degrees(cell.centerDeg + 4.5 - 90), clockwise: false)
            wedge.addArc(center: g.center, radius: g.radius * R.ringInner, startAngle: .degrees(cell.centerDeg + 4.5 - 90),
                         endAngle: .degrees(cell.centerDeg - 4.5 - 90), clockwise: true)
            wedge.closeSubpath()
            ctx.fill(wedge, with: .color(hl.opacity(0.35)))
            ctx.stroke(wedge, with: .color(hl), lineWidth: 2)
            g.text(&ctx, "\(n + 1)", r: R.ringInner - 0.035, deg: cell.centerDeg, size: g.radius * 0.035, color: hl, bold: true)

            guard n + 1 < name.path.count, let num = cell.number, let pos = cell.position else { continue }
            // arc along the inside of the ring, the way Michael counts
            let r = R.ringInner - 0.075 - Double(n % 3) * 0.02
            let start = cell.centerDeg
            let end = start + Double(num) * 9 * (pos == .above ? 1 : -1)
            var arc = Path()
            let steps = max(Int(abs(end - start) / 3), 2)
            for s in 0...steps {
                let d = start + (end - start) * Double(s) / Double(steps)
                if s == 0 { arc.move(to: g.pt(r, d)) } else { arc.addLine(to: g.pt(r, d)) }
            }
            ctx.stroke(arc, with: .color(hl), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5, 4]))
            // arrow head
            let tip = g.pt(r, end), back = g.pt(r, end - (pos == .above ? 3 : -3))
            let (l1, _) = g.offsetLine(back, tip, by: 5)
            let (l2, _) = g.offsetLine(back, tip, by: -5)
            ctx.fill(Path { p in p.move(to: tip); p.addLine(to: l1); p.addLine(to: l2); p.closeSubpath() }, with: .color(hl))
        }
    }
}

/// Polar geometry for the seal. Angles are degrees clockwise from 12 o'clock.
struct Geo {
    let center: CGPoint
    let radius: CGFloat

    func pt(_ r: Double, _ deg: Double) -> CGPoint {
        let a = deg * .pi / 180
        return CGPoint(x: center.x + CGFloat(r) * radius * CGFloat(sin(a)), y: center.y - CGFloat(r) * radius * CGFloat(cos(a)))
    }

    func rect(_ r: Double) -> CGRect {
        let d = CGFloat(r) * radius
        return CGRect(x: center.x - d, y: center.y - d, width: d * 2, height: d * 2)
    }

    func lerp(_ a: CGPoint, _ b: CGPoint, _ t: Double) -> CGPoint {
        CGPoint(x: a.x + (b.x - a.x) * CGFloat(t), y: a.y + (b.y - a.y) * CGFloat(t))
    }

    /// A point on the line at distance `apothem` from the centre, perpendicular to `midDeg`,
    /// moved `offset` (fraction of the radius) clockwise along it.
    func alongSide(apothem: Double, midDeg: Double, offset: Double) -> CGPoint {
        let m = pt(apothem, midDeg)
        let a = (midDeg + 90) * .pi / 180
        return CGPoint(x: m.x + CGFloat(offset * sin(a)) * radius, y: m.y - CGFloat(offset * cos(a)) * radius)
    }

    func polygon(_ n: Int, circumradius r: Double, startDeg: Double) -> Path {
        Path { p in
            for i in 0..<n {
                let q = pt(r, startDeg + Double(i) * 360 / Double(n))
                if i == 0 { p.move(to: q) } else { p.addLine(to: q) }
            }
            p.closeSubpath()
        }
    }

    func pentagram(_ r: Double) -> Path {
        Path { p in
            for i in 0...5 {
                let q = pt(r, Double(i * 2 % 5) * 72)
                if i == 0 { p.move(to: q) } else { p.addLine(to: q) }
            }
            p.closeSubpath()
        }
    }

    func offsetLine(_ a: CGPoint, _ b: CGPoint, by d: CGFloat) -> (CGPoint, CGPoint) {
        let dx = b.x - a.x, dy = b.y - a.y
        let len = max(sqrt(dx * dx + dy * dy), 0.001)
        let nx = -dy / len * d, ny = dx / len * d
        return (CGPoint(x: a.x + nx, y: a.y + ny), CGPoint(x: b.x + nx, y: b.y + ny))
    }

    /// Text centred at polar (r, deg), turned so its top points outward (as in Dee's drawing).
    func text(_ ctx: inout GraphicsContext, _ s: String, r: Double, deg: Double, size: CGFloat, color: Color,
              serif: Bool = false, bold: Bool = false, upright: Bool = false, offsetY: CGFloat = 0) {
        var p = pt(r, deg)
        p.y += offsetY
        text(&ctx, s, at: p, deg: upright ? 0 : deg, size: size, color: color, serif: serif, bold: bold)
    }

    func text(_ ctx: inout GraphicsContext, _ s: String, at p: CGPoint, deg: Double, size: CGFloat, color: Color,
              serif: Bool = false, bold: Bool = false) {
        var c = ctx
        c.translateBy(x: p.x, y: p.y)
        c.rotate(by: .degrees(deg))
        let font: Font = serif ? .system(size: max(size, 1), weight: bold ? .bold : .regular, design: .serif)
                               : .system(size: max(size, 1), weight: bold ? .bold : .medium)
        c.draw(Text(s).font(font).foregroundColor(color), at: .zero, anchor: .center)
    }

    /// Letters spread along an arc, clockwise, centred on `centerDeg`.
    func arcText(_ ctx: inout GraphicsContext, _ s: String, r: Double, centerDeg: Double, size: CGFloat, color: Color) {
        let letters = Array(s)
        let stepDeg = Double(size * 0.78) / (r * Double(radius)) * 180 / .pi
        let first = centerDeg - stepDeg * Double(letters.count - 1) / 2
        for (i, ch) in letters.enumerated() {
            text(&ctx, String(ch), r: r, deg: first + stepDeg * Double(i), size: size, color: color, serif: true)
        }
    }
}
