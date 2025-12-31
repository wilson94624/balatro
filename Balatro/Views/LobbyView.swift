import SwiftUI

struct LobbyView: View {
    @Environment(GameModel.self) var game
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            ZStack {
                // Background
                LinearGradient(colors: [Color(hex: 0x0f172a), Color(hex: 0x1e293b)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                // Particles
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 500, height: 500)
                    .offset(x: -200, y: -200)
                
                Circle()
                    .fill(Color.purple.opacity(0.1))
                    .frame(width: 400, height: 400)
                    .offset(x: 200, y: 200)
                
                if isLandscape {
                    // Landscape Layout (Side-by-Side)
                    HStack(spacing: 40) {
                        // Left: Title Area
                        VStack(spacing: 16) {
                            Text("Balatro Lite")
                                .font(.system(size: 60, weight: .black, design: .serif))
                                .foregroundStyle(
                                    LinearGradient(colors: [.white, .gray], startPoint: .top, endPoint: .bottom)
                                )
                                .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
                            
                            Text("Roguelike Poker")
                                .font(.title2)
                                .foregroundStyle(.white.opacity(0.6))
                                .tracking(2)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Right: Stats & Action
                        VStack(spacing: 30) {
                            HStack(spacing: 24) {
                                ScoreCard(title: "最高關卡", value: "\(game.highScoreRound)")
                                ScoreCard(title: "最強敵人", value: "\(game.highScoreTarget)")
                            }
                            
                            Button(action: {
                                withAnimation {
                                    game.startNewGame()
                                }
                            }) {
                                Text("Play Game")
                                    .font(.title)
                                    .bold()
                                    .foregroundStyle(.white)
                                    .frame(width: 220, height: 60)
                                    .background(
                                        LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing)
                                    )
                                    .cornerRadius(16)
                                    .shadow(color: .blue.opacity(0.4), radius: 8, x: 0, y: 4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                } else {
                    // Portrait Layout (Vertical Stack)
                    // Portrait Layout (Vertical Stack)
                    VStack(spacing: 0) {
                        Spacer()
                        
                        VStack(spacing: 12) {
                            Text("Balatro Lite")
                                .font(.system(size: 50, weight: .black, design: .serif))
                                .foregroundStyle(
                                    LinearGradient(colors: [.white, .gray], startPoint: .top, endPoint: .bottom)
                                )
                                .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
                            
                            Text("Roguelike Poker")
                                .font(.title3)
                                .foregroundStyle(.white.opacity(0.6))
                                .tracking(2)
                        }
                        .multilineTextAlignment(.center)
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Image(systemName: "iphone.landscape")
                                .font(.title2)
                            Text("請將手機橫置以獲得最佳體驗")
                                .font(.headline)
                        }
                        .foregroundStyle(.yellow)
                        .padding()
                        .background(Color.yellow.opacity(0.1))
                        .cornerRadius(12)
                        
                        Spacer()
                        
                        HStack(spacing: 30) {
                            ScoreCard(title: "最高關卡", value: "\(game.highScoreRound)")
                            ScoreCard(title: "最強敵人", value: "\(game.highScoreTarget)")
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                game.startNewGame()
                            }
                        }) {
                            Text("Play Game")
                                .font(.title)
                                .bold()
                                .foregroundStyle(.white)
                                .frame(width: 240, height: 70)
                                .background(
                                    LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(20)
                                .shadow(color: .blue.opacity(0.4), radius: 10, x: 0, y: 5)
                        }
                        .padding(.bottom, 40)
                    }
                    .padding()
                }

            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct ScoreCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white.opacity(0.7))
            
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(width: 140, height: 100)
        .background(Material.ultraThin)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    LobbyView()
        .environment(GameModel())
        .previewInterfaceOrientation(.landscapeLeft)
}
