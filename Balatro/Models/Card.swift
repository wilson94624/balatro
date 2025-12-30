import Foundation
import SwiftUI

/// 撲克牌花色
enum Suit: String, CaseIterable, Codable, Identifiable {
    case spades, hearts, diamonds, clubs
    
    var id: String { rawValue }
    
    /// 顯示符號
    var symbol: String {
        switch self {
        case .spades: return "♠️"
        case .hearts: return "♥️"
        case .diamonds: return "♦️"
        case .clubs: return "♣️"
        }
    }
    
    /// 顏色 (紅/黑)
    var color: Color {
        switch self {
        case .spades, .clubs: return .black
        case .hearts, .diamonds: return .red
        }
    }
}

/// 撲克牌點數
enum Rank: Int, CaseIterable, Codable, Comparable, Identifiable { // Int rawValue 方便比較大小
    case two = 2, three, four, five, six, seven, eight, nine, ten
    case jack = 11, queen = 12, king = 13, ace = 14
    
    var id: Int { rawValue }
    
    /// 顯示文字
    var label: String {
        switch self {
        case .jack: return "J"
        case .queen: return "Q"
        case .king: return "K"
        case .ace: return "A"
        default: return "\(rawValue)"
        }
    }
    
    /// 基礎籌碼值 (Balatro 規則：2-9 為面額, 10/J/Q/K 為 10, A 為 11)
    var baseChips: Int {
        switch self {
        case .ace: return 11
        case .jack, .queen, .king: return 10
        default: return rawValue
        }
    }
    
    static func < (lhs: Rank, rhs: Rank) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

/// 撲克牌資料結構
struct Card: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    let suit: Suit
    let rank: Rank
    
    /// 基礎籌碼 (可被 Joker 修改，但此處先回傳 Rank 預設值)
    var chips: Int {
        rank.baseChips
    }
    
    // 用於顯示的字串
    var description: String {
        "\(suit.symbol)\(rank.label)"
    }
    
    // Hashable 實作
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        lhs.id == rhs.id
    }
}
