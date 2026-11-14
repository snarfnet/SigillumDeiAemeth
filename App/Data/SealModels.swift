import SwiftUI

enum NumberPosition { case above, below }

/// One of the 40 cells of the outer ring, numbered clockwise from 12 o'clock.
struct RingCell: Identifiable {
    let index: Int
    let letter: String
    let number: Int?
    let position: NumberPosition?
    let uncertain: Bool
    var id: Int { index }
    var centerDeg: Double { (Double(index) - 0.5) * 9 }
}

/// A name read around the ring by Michael's counting rule.
struct RingName: Identifiable, Hashable {
    let name: String
    let path: [Int]
    var id: String { name }

    /// "T 4↻ → h 22↻ → …"
    var steps: [String] {
        path.map { i in
            let c = SealData.ring[i - 1]
            guard let n = c.number, let p = c.position else { return c.letter + " ■" }
            return "\(c.letter) \(n)\(p == .above ? "↻" : "↺")"
        }
    }
}

struct Sigil {
    let order: Int
    let letter: String
    let number: Int?
    let centerDeg: Double
    let ringCell: Int
}

/// A cell of the second 7 x 7 table: a letter, a small number, or both ("I(21/8.)").
struct TableToken {
    let letter: String
    let note: String?

    init(_ raw: String) {
        if let open = raw.firstIndex(of: "(") {
            letter = String(raw[..<open])
            note = String(raw[raw.index(after: open)...]).replacingOccurrences(of: ")", with: "").replacingOccurrences(of: ".", with: "")
        } else if raw.first?.isNumber == true {
            letter = ""
            note = raw.replacingOccurrences(of: ".", with: "")
        } else {
            letter = raw
            note = nil
        }
    }
}

struct Cell2: Hashable {
    let r: Int
    let c: Int
}

/// A group of names read from one of the two 7 x 7 tables.
struct TableReading: Identifiable, Hashable {
    let id: String
    let title: String
    let table: Int
    let names: [String]
    let cells: [[Cell2]]
    let reconstructed: Bool
}

enum SealData {
    static let tokens: [[TableToken]] = table2.map { $0.map(TableToken.init) }

    /// Table 1 read down the columns as one stream, cut into the seven angel names (and the closing cross).
    static let table1Reading: TableReading = {
        let stream = (0..<7).flatMap { c in (0..<7).map { r in Cell2(r: r, c: c) } }
        var cells: [[Cell2]] = []
        var i = 0
        for name in table1Angels {
            cells.append(Array(stream[i..<i + name.count]))
            i += name.count
        }
        return TableReading(id: "angels1", title: L("七人の天使", "The Seven Angels"), table: 1,
                            names: table1Angels, cells: cells, reconstructed: false)
    }()

    static let table2Readings: [TableReading] = {
        let rows = (0..<7).map { r in (0..<7).map { Cell2(r: r, c: $0) } }
        let godNames = tokens.map { row in row.map { $0.letter.isEmpty ? "·" : $0.letter }.joined() }
        let dCells = (0..<7).map { k in (0...k).map { Cell2(r: $0, c: 6 - k + $0) } }
        let sCells = (0..<7).map { k in (0...k).map { Cell2(r: 6 - k + $0, c: $0) } }
        let dd = (0..<7).map { k in (0...k).map { Cell2(r: $0, c: k - $0) } }
        let ss = (0..<7).map { k in (0...k).map { Cell2(r: 6 - $0, c: 6 - k + $0) } }
        // One stream of anti-diagonals (top-right to bottom-left), cut by the number of cells in each name.
        let stream = (0...12).flatMap { k in (max(0, k - 6)...min(k, 6)).map { Cell2(r: $0, c: k - $0) } }
        var heavens: [[Cell2]] = []
        var i = 0
        for n in [7, 8, 7, 7, 7, 6, 7] { heavens.append(Array(stream[i..<i + n])); i += n }
        return [
            TableReading(id: "god", title: L("神の名（各行）", "Names of God (rows)"), table: 2,
                         names: godNames, cells: rows, reconstructed: false),
            TableReading(id: "daughters", title: L("光の娘たち", "Daughters of Light"), table: 2,
                         names: daughters, cells: dCells, reconstructed: false),
            TableReading(id: "sons", title: L("光の息子たち", "Sons of Light"), table: 2,
                         names: sons, cells: sCells, reconstructed: false),
            TableReading(id: "dd", title: L("光の娘たちの娘たち", "Daughters of the Daughters"), table: 2,
                         names: daughtersOfDaughters, cells: dd, reconstructed: false),
            TableReading(id: "ss", title: L("光の息子たちの息子たち", "Sons of the Sons"), table: 2,
                         names: sonsOfSons, cells: ss, reconstructed: false),
            TableReading(id: "heavens", title: L("七つの天の天使", "Angels of the Seven Heavens"), table: 2,
                         names: table2Angels, cells: heavens, reconstructed: true),
        ]
    }()
}

enum Layer: String, CaseIterable, Identifiable {
    case ring = "L1_outerRing"
    case sigils = "L2_galethogSigils"
    case band = "L3_outerHeptagonBand"
    case godNames = "L4_namesOfGod"
    case heptagram = "L5_heptagram"
    case daughtersOfDaughters = "L6_daughtersOfDaughters"
    case sonsOfSons = "L7_sonsOfSons"
    case zabathiel = "L8_zabathiel"
    case pentagram = "L9_pentagram"
    case cross = "L10_centerCross"

    var id: String { rawValue }
    var number: Int { Layer.allCases.firstIndex(of: self)! + 1 }

    var title: String {
        switch self {
        case .ring: return L("外輪の40の区画", "The Outer Ring of 40")
        case .sigils: return L("ガレトグの7つの記号", "The Seven Signs of Galethog")
        case .band: return L("七角形の49文字", "The 49 Letters of the Heptagon")
        case .godNames: return L("7つの神の名", "Seven Names of God")
        case .heptagram: return L("七芒星：光の娘と息子", "Heptagram: Daughters and Sons of Light")
        case .daughtersOfDaughters: return L("光の娘たちの娘たち", "Daughters of the Daughters")
        case .sonsOfSons: return L("光の息子たちの息子たち", "Sons of the Sons")
        case .zabathiel: return L("ザバティエル", "Zabathiel")
        case .pentagram: return L("五芒星の5人の天使", "Five Angels of the Pentagram")
        case .cross: return L("中心の十字：レヴァナエル", "Central Cross: Levanael")
        }
    }

    var date: String {
        switch self {
        case .ring: return L("1582年3月19日", "19 March 1582")
        case .sigils, .band: return L("1582年3月20日", "20 March 1582")
        default: return L("1582年3月21日", "21 March 1582")
        }
    }

    var text: String {
        guard let t = SealData.layerText[rawValue] else { return "" }
        return L(t.ja, t.en)
    }
}

/// Japanese when the device prefers Japanese, otherwise English.
func L(_ ja: String, _ en: String) -> String {
    (Locale.preferredLanguages.first ?? "en").hasPrefix("ja") ? ja : en
}
