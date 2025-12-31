import SwiftUI

struct ContentView: View {
    @State private var game = GameModel()
    
    var body: some View {
        Group {
            if game.state == .menu {
                LobbyView()
                    .transition(.opacity)
            } else {
                GameView()
                    .transition(.opacity)
                    .fullScreenCover(isPresented: Binding(
                        get: { game.state == .shopping },
                        set: { _ in }
                    )) {
                        ShopView()
                    }
                    .sheet(isPresented: Binding(
                        get: { game.state == .gameOver },
                        set: { _ in }
                    )) {
                        GameOverView()
                            .interactiveDismissDisabled()
                    }
            }
        }
        .environment(game)
        .environment(game)
        .animation(.default, value: game.state)
        .onAppear {
            AudioManager.shared.playBackgroundMusic()
        }
    }
}

// 暫時的 ShopView 佔位符，稍後可移至獨立檔案


// 暫時的 GameOverView 佔位符
struct GameOverView: View {
    @Environment(GameModel.self) var game
    
    var body: some View {
        VStack(spacing: 20) {
            Text("遊戲結束")
                .font(.system(size: 60, weight: .heavy))
                .foregroundStyle(.red)
            
            Text("分數: \(game.currentScore)")
                .font(.title)
            
            Text("回合: \(game.currentRound)")
                .font(.title2)
            
            Button("重新開始") {
                game.startNewGame()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.extraLarge)
            
            Button("返回大廳") {
                game.state = .menu
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .previewInterfaceOrientation(.landscapeLeft)
}
