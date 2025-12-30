import Foundation

/// Joker 的效果類型定義
enum JokerEffect: Codable {
    case globalMult(Int)       // 例如：所有牌 +4 倍率
    case suitChips(Suit, Int)  // 例如：如果是紅心 +50 籌碼
    case typeMult(PokerHandType, Int) // 例如：如果是 Pair +10 倍率
    case typeChips(PokerHandType, Int) // 例如：如果是 3oak +300 籌碼
    case allowFourCardHands    // 特殊：允許 4 張牌組成同花/順子
    case blurredSuits          // 特殊：模糊花色 (紅=紅, 黑=黑)
}

/// Joker (小丑牌) 定義
struct Joker: Identifiable, Codable {
    var id: UUID = UUID()
    let name: String
    let description: String
    let effect: JokerEffect
    let cost: Int // 商店購買價格
    var rarity: Rarity = .common
    let imageName: String
    
    enum Rarity: String, Codable {
        case common, uncommon, rare, legendary
        
        var color: String {
            switch self {
            case .common: return "Gray"
            case .uncommon: return "Green"
            case .rare: return "Red"
            case .legendary: return "Purple"
            }
        }
    }
    
    static let demoJokers: [Joker] = [
        // Common
        Joker(name: "小丑牌", description: "+4 倍率 (Mult)", effect: .globalMult(4), cost: 2, rarity: .common, imageName: "joker_common_basic"),
        Joker(name: "貪婪小丑", description: "打出的紅心牌給予 +50 籌碼", effect: .suitChips(.hearts, 50), cost: 3, rarity: .common, imageName: "joker_greedy_hearts"),
        Joker(name: "色慾小丑", description: "打出的方塊牌給予 +50 籌碼", effect: .suitChips(.diamonds, 50), cost: 3, rarity: .common, imageName: "joker_lustful_diamonds"),
        Joker(name: "暴怒小丑", description: "打出的黑桃牌給予 +50 籌碼", effect: .suitChips(.spades, 50), cost: 3, rarity: .common, imageName: "joker_wrathful_spades"),
        Joker(name: "暴食小丑", description: "打出的梅花牌給予 +50 籌碼", effect: .suitChips(.clubs, 50), cost: 3, rarity: .common, imageName: "joker_gluttonous_clubs"),
        
        // Uncommon
        Joker(name: "雙人組", description: "若打出的牌包含對子 (Pair)，+10 倍率", effect: .typeMult(.pair, 10), cost: 4, rarity: .uncommon, imageName: "joker_the_duo_pair"),
        Joker(name: "三人行", description: "若打出的牌包含三條 (Three of a Kind)，+300 籌碼", effect: .typeChips(.threeOfAKind, 300), cost: 6, rarity: .uncommon, imageName: "joker_the_trio_three"),
        
        // Rare
        Joker(name: "家族", description: "若打出的牌包含四條 (Four of a Kind)，+50 倍率", effect: .typeMult(.fourOfAKind, 50), cost: 8, rarity: .rare, imageName: "joker_the_family_four"),
        Joker(name: "四指", description: "所有同花和順子可以只用 4 張牌湊成", effect: .allowFourCardHands, cost: 10, rarity: .rare, imageName: "joker_four_fingers"),
        Joker(name: "歪臉小丑", description: "紅心和方塊視為相同花色，黑桃和梅花視為相同花色", effect: .blurredSuits, cost: 10, rarity: .rare, imageName: "joker_smeared_suits")
    ]
}
