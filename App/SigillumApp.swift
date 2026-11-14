import SwiftUI

enum Theme {
    static let background = Color(red: 0.10, green: 0.04, blue: 0.04)
    static let card = Color(red: 0.20, green: 0.08, blue: 0.07)
    static let gold = Color(red: 0.95, green: 0.78, blue: 0.45)
    static let text = Color(red: 0.97, green: 0.90, blue: 0.78)
    static let faint = Color(red: 0.75, green: 0.62, blue: 0.52)
    static let ember = Color(red: 1.0, green: 0.55, blue: 0.40)
}

extension View {
    func themeCard() -> some View {
        padding(14)
            .background(RoundedRectangle(cornerRadius: 12).fill(Theme.card))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.gold.opacity(0.25)))
    }
}

@main
struct SigillumApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(screenshotIndex: Self.screenshotIndex)
                .preferredColorScheme(.dark)
                .tint(Theme.gold)
        }
    }

    /// SCREENSHOT_MODE_1..3 launch arguments open a prepared screen.
    static var screenshotIndex: Int? {
        for i in 1...3 where CommandLine.arguments.contains("SCREENSHOT_MODE_\(i)") { return i }
        return nil
    }
}

struct ContentView: View {
    let screenshotIndex: Int?
    @State private var tab = 0

    var body: some View {
        TabView(selection: $tab) {
            SealView(focus: screenshotIndex == 2 ? .heptagram : nil)
                .tabItem { Label(L("印章", "Seal"), systemImage: "seal") }
                .tag(0)
            ReadingView(mode: screenshotIndex == 3 ? .table2 : .ring)
                .tabItem { Label(L("名前を読む", "Read"), systemImage: "text.magnifyingglass") }
                .tag(1)
            AboutView()
                .tabItem { Label(L("由来", "About"), systemImage: "book.closed") }
                .tag(2)
        }
        .onAppear {
            if screenshotIndex == 3 { tab = 1 }
        }
    }
}
