import SwiftUI

/// How the names are read: around the ring, and out of the two 7 x 7 tables.
struct ReadingView: View {
    enum Mode: String, CaseIterable { case ring, table1, table2 }

    @State private var mode: Mode
    @State private var ringName: RingName
    @State private var reading: TableReading
    @State private var index = 0
    @AppStorage("palette") private var paletteID = SealPalette.wax.id

    init(mode: Mode = .ring) {
        _mode = State(initialValue: mode)
        _ringName = State(initialValue: SealData.ringNames[0])
        _reading = State(initialValue: mode == .table1 ? SealData.table1Reading : SealData.table2Readings[1])
    }

    private var palette: SealPalette { SealPalette.all.first { $0.id == paletteID } ?? .wax }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        Picker("", selection: $mode) {
                            Text(L("外輪の名", "Ring")).tag(Mode.ring)
                            Text(L("七人の天使", "Seven Angels")).tag(Mode.table1)
                            Text(L("神の名の表", "Table of Names")).tag(Mode.table2)
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: mode) { _, m in
                            index = 0
                            if m == .table1 { reading = SealData.table1Reading }
                            if m == .table2 { reading = SealData.table2Readings[1] }
                        }

                        switch mode {
                        case .ring: ringSection
                        case .table1, .table2: tableSection
                        }
                    }
                    .padding(12)
                }
            }
            .navigationTitle(L("名前を読む", "Reading the Names"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.background, for: .navigationBar)
        }
    }

    // MARK: Ring

    private var ringSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SealCanvas(palette: palette, visibleLayers: 1, ringName: ringName)
            chips(SealData.ringNames.map(\.name), selected: SealData.ringNames.firstIndex(of: ringName) ?? 0) {
                ringName = SealData.ringNames[$0]
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(ringName.name).font(.system(size: 28, weight: .bold, design: .serif)).foregroundColor(Theme.gold)
                Text(ringName.steps.joined(separator: "  →  "))
                    .font(.system(.subheadline, design: .serif)).foregroundColor(Theme.text)
                Text(L("大文字から始め、数字が文字の上（外側）にあれば右回り ↻、下（内側）にあれば左回り ↺ に、その数だけ進みます。数字のない文字（■）で名前が終わります。名前の途中で a が2つ続いたら、前の a は読みません。",
                       "Start at a capital. If the number stands above the letter (outside), count that many cells clockwise ↻; if below (inside), counter-clockwise ↺. A letter with no number (■) ends the name. When two a's meet inside a name, the first is not read."))
                    .font(.caption).foregroundColor(Theme.faint)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .themeCard()
        }
    }

    // MARK: Tables

    private var tableSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if mode == .table2 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(SealData.table2Readings) { r in
                            Button { reading = r; index = 0 } label: {
                                Text(r.title).font(.footnote.weight(.semibold))
                                    .foregroundColor(reading == r ? Theme.background : Theme.gold)
                                    .padding(.horizontal, 11).padding(.vertical, 7)
                                    .background(Capsule().fill(reading == r ? Theme.gold : Theme.card))
                            }
                        }
                    }
                }
            }
            TableGrid(table: mode == .table1 ? 1 : 2, highlight: reading.cells[index])
            chips(reading.names, selected: index) { index = $0 }
            VStack(alignment: .leading, spacing: 8) {
                Text(reading.names[index]).font(.system(size: 28, weight: .bold, design: .serif)).foregroundColor(Theme.gold)
                Text(explanation).font(.caption).foregroundColor(Theme.faint)
                    .fixedSize(horizontal: false, vertical: true)
                if reading.reconstructed {
                    Text(L("ディーの記録に読み方が書かれているのはザバティエルだけです。残り6人の並びは、49マスをちょうど1回ずつ使って7人の名前がすべて出る読み方として再構成したものです。",
                           "Dee's record gives the path only for Zabathiel. The paths for the other six are a reconstruction that uses all 49 cells exactly once and yields every name."))
                        .font(.caption).foregroundColor(Theme.ember)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .themeCard()
        }
    }

    private var explanation: String {
        switch reading.id {
        case "angels1":
            return L("7羽の鳥が見せた49文字を7×7に並べ、左の列から順に上から下へ読み続けると、7人の天使の名前が続けて現れます（最後は十字）。",
                     "Set the 49 letters shown by the seven birds in a 7 × 7 table and read down the columns, one after another: the seven angel names follow in turn, ending with a cross.")
        case "god":
            return L("各行を左から右へ読んだものが神の名です。ウリエルは、天使にも知られず、人には発音できない名だと語りました。小さな数字は文字を表します（8＝l、30＝l、21＝e）。",
                     "Each row read left to right is a name of God which, Uriel said, the angels do not know and no one can speak. Small numbers stand for letters (8 = l, 30 = l, 21 = e).")
        case "daughters":
            return L("右上の角から始まる斜めの列を、左上から右下へ読みます。",
                     "Diagonals starting from the top-right corner, read from upper left to lower right.")
        case "sons":
            return L("左下の角から始まる斜めの列を、左上から右下へ読みます。最後の Stimcul は光の娘と共通です。",
                     "Diagonals starting from the bottom-left corner, read from upper left to lower right. The last, Stimcul, is shared with the Daughters.")
        case "dd":
            return L("左上の角から始まる逆斜めの列を、右上から左下へ読みます。",
                     "Anti-diagonals starting from the top-left corner, read from upper right to lower left.")
        case "ss":
            return L("右下の角から始まる逆斜めの列を、左下から右上へ読みます。",
                     "Anti-diagonals starting from the bottom-right corner, read from lower left to upper right.")
        default:
            return L("左上の角から逆斜めの列を順に、右上から左下へ読み続けます。数字は文字として読みます（21/8＝el、26＝l）。",
                     "Read the anti-diagonals one after another from the top-left corner, each from upper right to lower left. Numbers are read as letters (21/8 = el, 26 = l).")
        }
    }

    private func chips(_ names: [String], selected: Int, pick: @escaping (Int) -> Void) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 92), spacing: 6)], spacing: 6) {
            ForEach(names.indices, id: \.self) { i in
                Button { withAnimation(.easeOut(duration: 0.2)) { pick(i) } } label: {
                    Text(names[i]).font(.system(.subheadline, design: .serif).weight(.semibold))
                        .lineLimit(1).minimumScaleFactor(0.6)
                        .foregroundColor(i == selected ? Theme.background : Theme.gold)
                        .frame(maxWidth: .infinity, minHeight: 36)
                        .background(RoundedRectangle(cornerRadius: 6).fill(i == selected ? Theme.gold : Theme.card))
                }
            }
        }
    }
}

struct TableGrid: View {
    let table: Int
    let highlight: [Cell2]

    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<7, id: \.self) { r in
                HStack(spacing: 2) {
                    ForEach(0..<7, id: \.self) { c in cell(Cell2(r: r, c: c)) }
                }
            }
        }
        .padding(4)
        .background(RoundedRectangle(cornerRadius: 8).fill(Theme.card))
    }

    private func cell(_ cell: Cell2) -> some View {
        let order = highlight.firstIndex(of: cell)
        let token: TableToken = table == 1
            ? TableToken(String(Array(SealData.table1[cell.r])[cell.c]))
            : SealData.tokens[cell.r][cell.c]
        return ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 4).fill(order != nil ? Theme.gold : Theme.background.opacity(0.6))
            VStack(spacing: 0) {
                if !token.letter.isEmpty {
                    Text(token.letter).font(.system(size: 20, weight: .semibold, design: .serif))
                }
                if let note = token.note {
                    Text(note).font(.system(size: token.letter.isEmpty ? 14 : 9, weight: .medium))
                }
            }
            .foregroundColor(order != nil ? Theme.background : Theme.text)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            if let order {
                Text("\(order + 1)").font(.system(size: 8, weight: .bold)).foregroundColor(Theme.background.opacity(0.8)).padding(2)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
