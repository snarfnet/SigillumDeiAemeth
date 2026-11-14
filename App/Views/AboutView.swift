import SwiftUI

struct AboutView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        card(L("ディーとケリー", "Dee and Kelley"),
                             SealData.layerText["overview"].map { L($0.ja, $0.en) } ?? "")
                        card(L("実物の印章", "The real seal"),
                             L("1582年3月10日、ディーは清めた蜜蝋で印章を作るよう告げられました。直径9インチ（約23cm）、周囲27インチあまり、厚さ1と8分の1インチ（約3cm）、裏には十字。ディーの蝋の印章は今も大英博物館に収蔵されています。写本の図と実物には細かな違いがあるといわれ、このアプリは写本（Sloane MS 3188）の図に従っています。",
                               "On 10 March 1582 Dee was told to make the seal of clean, purified wax: 9 inches across, a little over 27 inches round, an inch and an eighth thick, with a cross on the back. Dee's wax seals survive in the British Museum. The wax seal is said to differ in details from the manuscript drawing; this app follows the drawing in Sloane MS 3188."))
                        card(L("このアプリで描いている図", "About this drawing"),
                             L("印章はすべてアプリの中で一から描いています。文字・数字・名前の位置は、ディーの記録の翻刻（J. H. Peterson 編、C. Holden 翻刻）と写本の図をつき合わせて決めました。資料によって違う箇所は、その層の説明に書いてあります。",
                               "Everything is drawn from scratch inside the app. The letters, numbers and names are placed by comparing transcriptions of Dee's record (ed. J. H. Peterson; transcribed by C. Holden) with the manuscript drawing. Where the sources disagree, the layer's notes say so."))
                        sources
                    }
                    .padding(14)
                }
            }
            .navigationTitle(L("由来", "Background"))
            .toolbarBackground(Theme.background, for: .navigationBar)
        }
    }

    private func card(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline).foregroundColor(Theme.gold)
            Text(body).font(.subheadline).foregroundColor(Theme.text).fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .themeCard()
    }

    private var sources: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L("出典", "Sources")).font(.headline).foregroundColor(Theme.gold)
            ForEach([
                "John Dee, Mysteriorum Liber Secundus, British Library Sloane MS 3188 (1582)",
                "Joseph H. Peterson (ed.), John Dee's Five Books of Mystery (2003)",
                "Clay Holden, transcription of Mysteriorum Liber Secundus, John Dee Publication Project (1996)",
                "David Richard Jones, In Operibus Sigillo Dei Aemeth",
            ], id: \.self) { Text("・" + $0).font(.caption).foregroundColor(Theme.faint) }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .themeCard()
    }
}
