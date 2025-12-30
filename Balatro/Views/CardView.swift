import SwiftUI

struct CardView: View {
    let card: Card
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            // 卡牌背景
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .shadow(radius: isSelected ? 4 : 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.blue : Color.gray, lineWidth: isSelected ? 3 : 1)
                )
            
            // 卡牌內容 (簡單佈局)
            VStack {
                HStack {
                    Text(card.rank.label)
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                    Text(card.suit.symbol)
                }
                .padding(4)
                
                Spacer()
                
                Text(card.suit.symbol)
                    .font(.largeTitle)
                
                Spacer()
                
                HStack {
                    Text(card.suit.symbol)
                    Spacer()
                    Text(card.rank.label)
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .padding(4)
                .rotationEffect(.degrees(180))
            }
            .foregroundColor(card.suit.color)
        }
        .frame(width: 70, height: 100) // 標準撲克牌比例
        .offset(y: isSelected ? -20 : 0) // 選中時向上浮動
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

#Preview {
    HStack {
        CardView(card: Card(suit: .hearts, rank: .ace), isSelected: false)
        CardView(card: Card(suit: .spades, rank: .ten), isSelected: true)
    }
    .padding()
    .background(Color.green)
}
