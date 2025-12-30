import SwiftUI

struct ShopView: View {
    @Environment(GameModel.self) var game
    @Environment(\.dismiss) var dismiss
    
    var body: some View {

        GeometryReader { geometry in
            ZStack {
                // MARK: - Main Shop Interface
                VStack(spacing: 0) {
                    // MARK: - Header (Compact)
                    HStack {
                        Text("Shop")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Text("Money:")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.8))
                            Text("$\(game.money)")
                                .font(.title2)
                                .bold()
                                .foregroundStyle(.yellow)
                                .contentTransition(.numericText(value: Double(game.money)))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(8)
                    }
                    .padding()
                    .background(Material.ultraThin)
                    
                    // MARK: - Horizontal Shop Content
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 24) {
                            Spacer().frame(width: 10)
                            
                            // 1. Booster Pack
                            if let pack = game.currentBoosterPack {
                                BoosterPackItem(pack: pack)
                                    .frame(width: 200)
                                
                                Divider()
                                    .frame(height: 200)
                                    .background(Color.white.opacity(0.3))
                            }
                            
                            // 2. Joker Cards
                            ForEach(game.shopJokers) { joker in
                                JokerShopItem(joker: joker)
                                    .frame(width: 180)
                            }
                            
                            if game.shopJokers.isEmpty && game.currentBoosterPack == nil {
                                Text("Sold Out")
                                    .font(.title)
                                    .foregroundStyle(.white.opacity(0.5))
                                    .frame(width: geometry.size.width - 40)
                            }
                            
                            Spacer().frame(width: 10)
                        }
                        .padding(.vertical, 20)
                    }
                    .frame(maxHeight: .infinity)
                    
                    Spacer(minLength: 0)
                    
                    // MARK: - Footer (Next Round Action)
                    VStack {
                        Button(action: {
                            game.startNextRound()
                            dismiss()
                        }) {
                            Text("Next Round")
                                .font(.headline)
                                .bold()
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .frame(maxWidth: 300)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 50)
                }
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color(hex: 0x1a2a6c), Color(hex: 0xb21f1f), Color(hex: 0xfdbb2d)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        .opacity(0.8)
                        .ignoresSafeArea()
                )
                
                // MARK: - Pack Opening Overlay
                if let content = game.packOpeningContent {
                    ZStack {
                        Color.black.opacity(0.9).ignoresSafeArea()
                        
                        VStack(spacing: 15) {
                            Text("Choose One")
                                .font(.largeTitle)
                                .bold()
                                .foregroundStyle(.white)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(content) { joker in
                                        JokerSelectionItem(joker: joker)
                                            .onTapGesture {
                                                withAnimation {
                                                    game.selectBoosterCard(joker)
                                                }
                                            }
                                    }
                                }
                                .padding()
                            }
                            
                            Button("Skip") {
                                withAnimation {
                                    game.skipBoosterSelection()
                                }
                            }
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(.bottom, 30) // Push it up slightly from absolute bottom if needed, or just less spacing above
                        }
                    }
                    .transition(.opacity)
                    .zIndex(100)
                }
            }
        }
    }
}

// MARK: - Subviews

struct BoosterPackItem: View {
    let pack: GameModel.BoosterPack
    @Environment(GameModel.self) var game
    
    var body: some View {
        Button(action: {
            withAnimation {
                game.buyBoosterPack()
            }
        }) {
            VStack(spacing: 12) {
                // Visual
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing))
                    
                    Image(systemName: "cube.box.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .frame(height: 120)
                .shadow(radius: 5)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(pack.name)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("Contains 3 Cards")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                    
                    HStack {
                        Spacer()
                        Text("$\(pack.cost)")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(.yellow)
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.yellow.opacity(0.5), lineWidth: 2)
            )
        }
        .disabled(game.money < pack.cost)
        .opacity(game.money < pack.cost ? 0.6 : 1)
        .buttonStyle(.plain)
    }
}

struct JokerSelectionItem: View {
    let joker: Joker
    @Environment(GameModel.self) var game
    
    var rarityColor: Color {
        switch joker.rarity {
        case .common: return .blue
        case .uncommon: return .green
        case .rare: return .red
        case .legendary: return .purple
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Rarity Header
            Text(joker.rarity.rawValue.capitalized)
                .font(.caption)
                .bold()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
                .background(rarityColor)
                .foregroundStyle(.white)
            
            VStack(spacing: 10) {
                // Visual
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(rarityColor.opacity(0.3))
                    
                    if let uiImage = UIImage(named: joker.imageName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(6)
                            .padding(4)
                    } else {
                        // Fallback
                        Text(joker.name.prefix(1))
                            .font(.system(size: 40, weight: .bold, design: .serif))
                            .foregroundStyle(.white)
                    }
                }
                .frame(height: 100)
                
                Text(joker.name)
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Text(joker.description)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.8))
                    .frame(height: 40)
                
                Text("Select")
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .foregroundStyle(rarityColor)
                    .cornerRadius(8)
            }
            .padding()
            .background(Color.black.opacity(0.8))
        }
        .frame(width: 180, height: 260)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(rarityColor, lineWidth: 3)
        )
        .shadow(color: rarityColor.opacity(0.5), radius: 10)
    }
}


// MARK: - Subviews

struct JokerShopItem: View {
    let joker: Joker
    @Environment(GameModel.self) var game
    
    var isOwned: Bool {
        game.jokers.contains(where: { $0.name == joker.name })
    }
    
    var canBuy: Bool {
        game.money >= joker.cost && game.jokers.count < game.maxJokers && !isOwned
    }
    
    var rarityColor: Color {
        switch joker.rarity {
        case .common: return .blue
        case .uncommon: return .green
        case .rare: return .red
        case .legendary: return .purple
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Rarity Badge
            Text(joker.rarity.rawValue.capitalized)
                .font(.caption2)
                .bold()
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(rarityColor)
                .foregroundStyle(.white)
                .cornerRadius(4)
                .frame(maxWidth: .infinity, alignment: .topTrailing)
            
            // Joker Visual
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(colors: [rarityColor.opacity(0.6), rarityColor], startPoint: .topLeading, endPoint: .bottomTrailing))
                
                if let uiImage = UIImage(named: joker.imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(6)
                        .padding(4)
                } else {
                    Text(joker.name.prefix(1))
                        .font(.system(size: 30, weight: .bold, design: .serif))
                        .foregroundStyle(.white.opacity(0.3))
                }
            }
            .frame(height: 100)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(joker.name)
                    .font(.subheadline) // Smaller font
                    .bold()
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text(joker.description)
                    .font(.caption2) // Smaller font
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(height: 36, alignment: .top) // Fixed height for description
                
                Spacer(minLength: 0)
                
                HStack {
                    Text(joker.cost == 0 ? "Free" : "$\(joker.cost)")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.yellow)
                    
                    Spacer()
                    
                    if isOwned {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else {
                        Button(action: {
                            game.buyJoker(joker)
                        }) {
                            Text("Buy")
                                .font(.caption2)
                                .bold()
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(rarityColor)
                        .disabled(!canBuy)
                    }
                }
            }
        }
        .padding(10)
        .background(Color.black.opacity(0.6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(rarityColor.opacity(0.7), lineWidth: 2)
        )
    }
}

#Preview {
    ShopView()
        .environment(GameModel())
        .previewInterfaceOrientation(.landscapeLeft)
}
