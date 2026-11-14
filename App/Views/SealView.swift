import SwiftUI

struct SealView: View {
    @AppStorage("palette") private var paletteID = SealPalette.wax.id
    @State private var focus: Layer?
    @State private var visible = Layer.allCases.count
    @State private var building = false
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    init(focus: Layer? = nil) { _focus = State(initialValue: focus) }

    private var palette: SealPalette { SealPalette.all.first { $0.id == paletteID } ?? .wax }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 14) {
                        seal
                        layerChips
                        layerCard
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle(L("神の真理の印章", "Sigillum Dei Aemeth"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.background, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { build() } label: { Label(L("組み立て", "Build"), systemImage: "play.circle") }
                        .disabled(building)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker(L("色", "Colours"), selection: $paletteID) {
                            ForEach(SealPalette.all) { Text($0.title).tag($0.id) }
                        }
                    } label: { Image(systemName: "paintpalette") }
                }
            }
        }
    }

    private var seal: some View {
        SealCanvas(palette: palette, visibleLayers: visible, focus: focus)
            .scaleEffect(scale)
            .offset(offset)
            .gesture(MagnificationGesture()
                .onChanged { scale = min(max(lastScale * $0, 1), 8) }
                .onEnded { _ in lastScale = scale; if scale == 1 { offset = .zero; lastOffset = .zero } })
            .simultaneousGesture(DragGesture()
                .onChanged { v in
                    guard scale > 1 else { return }
                    offset = CGSize(width: lastOffset.width + v.translation.width, height: lastOffset.height + v.translation.height)
                }
                .onEnded { _ in lastOffset = offset })
            .onTapGesture(count: 2) {
                withAnimation(.spring) { scale = scale > 1 ? 1 : 3; lastScale = scale; offset = .zero; lastOffset = .zero }
            }
            .clipShape(Rectangle())
            .overlay(alignment: .bottomTrailing) {
                if scale == 1 {
                    Text(L("ピンチで拡大", "Pinch to zoom"))
                        .font(.caption2).foregroundColor(Theme.faint).padding(6)
                }
            }
    }

    private var layerChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                chip(nil, L("全体", "All"))
                ForEach(Layer.allCases) { chip($0, "\($0.number). " + $0.title) }
            }
        }
    }

    private func chip(_ layer: Layer?, _ title: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) { focus = layer }
        } label: {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundColor(focus == layer ? Theme.background : Theme.gold)
                .padding(.horizontal, 12).padding(.vertical, 7)
                .background(Capsule().fill(focus == layer ? Theme.gold : Theme.card))
        }
    }

    @ViewBuilder private var layerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let focus {
                Text("\(focus.number). " + focus.title).font(.headline).foregroundColor(Theme.gold)
                Text(focus.date).font(.caption.weight(.semibold)).foregroundColor(Theme.faint)
                Text(focus.text).font(.subheadline).foregroundColor(Theme.text)
                    .fixedSize(horizontal: false, vertical: true)
                if let note = focusNote(focus) {
                    Text(note).font(.caption).foregroundColor(Theme.faint)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                Text(L("ジョン・ディーの印章", "John Dee's seal")).font(.headline).foregroundColor(Theme.gold)
                Text(SealData.layerText["overview"].map { L($0.ja, $0.en) } ?? "")
                    .font(.subheadline).foregroundColor(Theme.text)
                    .fixedSize(horizontal: false, vertical: true)
                Text(L("上の帯から層を選ぶと、その部分が光ります。左上の ▶ で、ディーが受け取った順に組み立てます。",
                       "Pick a layer above to light it up. Tap ▶ to build the seal in the order Dee received it."))
                    .font(.caption).foregroundColor(Theme.faint)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .themeCard()
    }

    private func focusNote(_ layer: Layer) -> String? {
        switch layer {
        case .ring:
            return L("22番の y の下の数は、口述では15、清書では14です（ここでは14）。40番の ω の数は本文に明記がありません。",
                     "Cell 22 (y): dictated with 15 below, drawn with 14 (14 shown here). The number for cell 40 (ω) is not stated in the text.")
        case .sigils:
            return L("記号の正確な形は写本の図にしか残っていません。ここでは文字・十字・数字の組み合わせとして簡略に描いています。",
                     "The exact shapes survive only in the manuscript drawing; here each sign is drawn simply as its letter, cross and number.")
        case .daughtersOfDaughters, .sonsOfSons:
            return L("名前の両側の小さな十字の数は本文にないため、1つずつにしています。",
                     "The text does not give how many small crosses pad each name, so one is drawn on each side.")
        default:
            return nil
        }
    }

    private func build() {
        building = true
        focus = nil
        visible = 0
        for i in 1...Layer.allCases.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.9) {
                withAnimation(.easeIn(duration: 0.4)) {
                    visible = i
                    focus = Layer.allCases[i - 1]
                }
                if i == Layer.allCases.count {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        withAnimation { focus = nil }
                        building = false
                    }
                }
            }
        }
    }
}
