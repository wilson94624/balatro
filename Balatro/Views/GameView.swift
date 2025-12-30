import SwiftUI

struct GameView: View {
    @Environment(GameModel.self) var game
    @State private var isPaused = false
    @State private var selectedJoker: Joker?
    
    // 為了預覽方便，這裡用個 timer 模擬一下
    // 實際上我們會用 ContentView 來包
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack(spacing: 0) {
                // MARK: - 左側資訊欄 (分數、關卡)
                VStack(spacing: 20) {
                    // 分數面板
                    VStack(alignment: .leading, spacing: 8) {
                        Text("目標分數")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(game.targetScore)")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(.red)
                        
                        Divider()
                            .background(Color.white)
                        
                        Text("目前分數")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(game.currentScore)")
                            .font(.largeTitle)
                            .bold()
                            .contentTransition(.numericText(value: Double(game.currentScore)))
                            .animation(.snappy, value: game.currentScore)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    
                    // 回合資訊
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack {
                                Text("Hands")
                                    .font(.caption)
                                Text("\(game.handsRemaining)")
                                    .font(.title2)
                                    .bold()
                                    .foregroundStyle(.blue)
                            }
                            Spacer()
                            VStack {
                                Text("Discards")
                                    .font(.caption)
                                Text("\(game.discardsRemaining)")
                                    .font(.title2)
                                    .bold()
                                    .foregroundStyle(.orange)
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Money")
                            Spacer()
                            Text("$\(game.money)")
                                .foregroundStyle(.yellow)
                                .bold()
                        }
                        
                        HStack {
                            Text("Round")
                            Spacer()
                            Text("\(game.currentRound)")
                                .bold()
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    
                    Spacer()
                }
                .frame(width: 180)
                .padding()
                
                // MARK: - 中央遊戲區
                VStack {
                    // 上方：Jovkers 區
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(game.jokers) { joker in
                                ZStack {
                                    if let uiImage = UIImage(named: joker.imageName) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 80, height: 80)
                                            .cornerRadius(10)
                                    } else {
                                        Text(joker.name)
                                            .font(.caption2)
                                            .fixedSize(horizontal: false, vertical: true)
                                            .multilineTextAlignment(.center)
                                            .padding(2)
                                    }
                                }
                                .frame(width: 80, height: 80)
                                .background(Color.purple.opacity(0.3))
                                .cornerRadius(10)
                                .shadow(radius: 2)
                                .onTapGesture {
                                    selectedJoker = joker
                                }
                            }
                            if game.jokers.isEmpty {
                                Text("No Jokers")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(height: 70)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 100)
                    
                    Spacer()
                    
                    // 中央：牌桌 / 計分區
                    ZStack {
                        if game.scoringDetail.isAnimating {
                            VStack(spacing: 6) {
                                // 顯示打出的牌 (Showdown)
                                HStack(spacing: -14) {
                                    ForEach(game.scoringDetail.playedCards) { card in
                                        CardView(card: card, isSelected: false)
                                            .scaleEffect(0.65)
                                            .transition(.push(from: .bottom))
                                    }
                                }
                                .padding(.bottom, 4)
                                .padding(.top, 10)
                                
                                // 描述文字 (例如 "Joker: +4 Mult") - 移到中間避免被手牌遮擋
                                Text(game.scoringDetail.description)
                                    .font(.headline)
                                    .foregroundStyle(.white.opacity(0.9))
                                    .shadow(radius: 2)
                                
                                // 計分面板 (單行設計)
                                HStack(spacing: 12) {
                                    // Chips
                                    HStack(spacing: 2) {
                                        Text("\(game.scoringDetail.chips)")
                                            .font(.system(size: 28, weight: .black, design: .rounded))
                                            .foregroundStyle(Color(hex: 0x60a5fa))
                                            .contentTransition(.numericText(value: Double(game.scoringDetail.chips)))
                                        Text("Chips")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                            .offset(y: 4)
                                    }
                                    
                                    Text("X")
                                        .font(.title3)
                                        .bold()
                                        .foregroundStyle(.white.opacity(0.6))
                                    
                                    // Mult
                                    HStack(spacing: 2) {
                                        Text("\(game.scoringDetail.mult)")
                                            .font(.system(size: 28, weight: .black, design: .rounded))
                                            .foregroundStyle(Color(hex: 0xf87171))
                                            .contentTransition(.numericText(value: Double(game.scoringDetail.mult)))
                                        Text("Mult")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                            .offset(y: 4)
                                    }
                                    
                                    Text("=")
                                        .font(.title3)
                                        .bold()
                                        .foregroundStyle(.white.opacity(0.6))
                                    
                                    // Total
                                    Text("\(game.scoringDetail.total)")
                                        .font(.system(size: 32, weight: .black, design: .rounded))
                                        .foregroundStyle(.yellow)
                                        .shadow(color: .orange.opacity(0.8), radius: 5)
                                        .contentTransition(.numericText(value: Double(game.scoringDetail.total)))
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Material.ultraThin)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                                .shadow(radius: 10)
                            }
                            .padding(.bottom, 20) // 額外往上推一點
                            .transition(.scale.combined(with: .opacity))
                            .zIndex(1)
                        } else {
                            VStack(spacing: 8) {
                                Text("Balatro Lite")
                                    .font(.system(size: 32, weight: .bold, design: .serif)) // Smaller font
                                    .foregroundStyle(
                                        LinearGradient(colors: [.white, .white.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                                    )
                                    .shadow(radius: 5)
                                
                                Text("Select up to 5 cards to play")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                        }
                    }
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: game.scoringDetail.isAnimating)
                    .animation(.snappy, value: game.scoringDetail.chips)
                    .animation(.snappy, value: game.scoringDetail.mult)
                    .frame(height: 160) // Reduced Fixed Height (previously 250)

                    
                    Spacer()
                    
                    // 下方：手牌區 (Scrollable or Overlapping)
                    // 下方：手牌區 (Scrollable or Overlapping)
                    HStack(spacing: 0) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: -35) {
                                ForEach(game.hand) { card in
                                    CardView(card: card, isSelected: game.selectedCards.contains(card.id))
                                        .scaleEffect(0.9)
                                        .onTapGesture {
                                            game.toggleSelection(card: card)
                                        }
                                }
                            }
                            .padding(.top, 30)
                            .padding(.bottom, 10)
                            .padding(.horizontal)
                            .frame(minWidth: geometry.size.width - 260) // Adjusted width for button
                        }
                        
                        // Sort Button
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                game.toggleSort()
                            }
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "arrow.up.arrow.down")
                                    .font(.title3)
                                Text(game.sortType == .rank ? "Rank" : "Suit") // These are short enough to not localize or can generally be understood, but user asked for traditional chinese previously? But here they asked "small to large or by suit". I'll use English for now or "Rank"/"Suit".
                                    .font(.caption2)
                                    .bold()
                            }
                            .foregroundStyle(.white)
                            .frame(width: 50, height: 60)
                            .background(Material.ultraThin)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .padding(.trailing, 16)
                    }
                    .frame(height: 130)
                    .layoutPriority(1)

                }
                
                // MARK: - 右側動作欄
                VStack(spacing: 20) {
                    Spacer()
                    
                    Button {
                        Task {
                            await game.playHand()
                        }
                    } label: {
                        VStack {
                            Text("Play")
                                .font(.headline)
                            Text("Hand")
                                .font(.caption)
                        }
                        .frame(width: 80, height: 60)
                        .background(game.selectedCards.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(game.selectedCards.isEmpty || game.handsRemaining <= 0)
                    
                    Button {
                        game.discardHand()
                    } label: {
                        VStack {
                            Text("Discard")
                                .font(.headline)
                        }
                        .frame(width: 80, height: 50)
                        .background(game.selectedCards.isEmpty ? Color.gray : Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(game.selectedCards.isEmpty || game.discardsRemaining <= 0)
                    
                    Spacer()
                }
                .padding()
                .frame(width: 100)

                } // End of Main HStack
                
                // MARK: - Top Right Controls (Pause)
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation { isPaused = true }
                        }) {
                            Image(systemName: "pause.circle.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.white.opacity(0.5))
                                .background(Color.black.opacity(0.2))
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(.top, 20)
                        .padding(.trailing, 60) // Avoid overlapping with dynamic island or rounded corners
                    }
                    Spacer()
                }
                .zIndex(80)

                // MARK: - Pause Overlay
                if isPaused {
                    Color.black.opacity(0.6).ignoresSafeArea().zIndex(190)
                    
                    VStack(spacing: 30) {
                        Text("Paused")
                            .font(.system(size: 40, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                        
                        Button(action: {
                            withAnimation { isPaused = false }
                        }) {
                            Text("Resume")
                                .font(.title2)
                                .bold()
                                .frame(width: 200, height: 60)
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .cornerRadius(16)
                        }
                        
                        Button(action: {
                            game.state = .menu
                        }) {
                            Text("Back to Lobby")
                                .font(.headline)
                                .frame(width: 200, height: 50)
                                .background(Color.red.opacity(0.8))
                                .foregroundStyle(.white)
                                .cornerRadius(16)
                        }
                    }
                    .padding(40)
                    .background(Material.ultraThin)
                    .cornerRadius(24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(200)
                }

                // MARK: - Tooltip Overlay
                if let joker = selectedJoker {
                    Color.black.opacity(0.01) // 透明遮罩，點擊空白處關閉
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.2)) {
                                selectedJoker = nil
                            }
                        }
                    
                    VStack(spacing: 8) {
                        Text(joker.name)
                            .font(.title3)
                            .bold()
                            .foregroundStyle(.white)
                        
                        Divider().background(Color.white)
                        
                        Text(joker.description)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 4)
                        
                        // 模擬 "稀有" 標籤 (Mock)
                        // 稀有度標籤
                        Text(joker.rarity.rawValue.capitalized)
                            .font(.caption2)
                            .bold()
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                joker.rarity == .common ? Color.blue :
                                joker.rarity == .uncommon ? Color.green :
                                joker.rarity == .rare ? Color.red : Color.purple
                            )
                            .cornerRadius(4)
                        
                        Divider().background(Color.white.opacity(0.5))
                        
                        // 販賣按鈕
                        Button(action: {
                            game.sellJoker(joker)
                            withAnimation {
                                selectedJoker = nil
                            }
                        }) {
                            Text("Sell for $\(max(1, joker.cost / 2))")
                                .font(.headline)
                                .foregroundStyle(.red)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.white)
                                .cornerRadius(8)
                        }
                        .padding(.top, 4)
                    }
                    .padding()
                    .frame(width: 220)
                    .background(Color(hex: 0x333333))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .shadow(radius: 10)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2 - 50) // 顯示在比較中間偏上的位置
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(100)
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.2)) {
                            selectedJoker = nil
                        }
                    }
                }
            }
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color(hex: 0x2c3e50), Color(hex: 0x4ca1af)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
        )
        // 強制橫向佈局的視覺設計，但在 iOS App 中仍需由外部控制旋轉，
        // 不過既然要求橫向遊玩，我們就假設使用者會轉過來。

    }
}

// 擴充 Color 方便使用 Hex
extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255,
            opacity: alpha
        )
    }
}

#Preview { // Landscape Preview
    GameView()
        .environment(GameModel())
        .previewInterfaceOrientation(.landscapeLeft)
}
