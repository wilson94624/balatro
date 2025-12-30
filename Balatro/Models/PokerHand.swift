import Foundation

/// 牌型定義 (由小到大排列)
enum PokerHandType: Int, CaseIterable, Codable, Comparable {
    case highCard = 1
    case pair
    case twoPair
    case threeOfAKind
    case straight
    case flush
    case fullHouse
    case fourOfAKind
    case straightFlush
    // Royal Flush 算作 Straight Flush 的特例，簡化 MVP
    
    /// 牌型名稱
    var name: String {
        switch self {
        case .highCard: return "High Card"
        case .pair: return "Pair"
        case .twoPair: return "Two Pair"
        case .threeOfAKind: return "Three of a Kind"
        case .straight: return "Straight"
        case .flush: return "Flush"
        case .fullHouse: return "Full House"
        case .fourOfAKind: return "Four of a Kind"
        case .straightFlush: return "Straight Flush"
        }
    }
    
    /// 基礎分數設定 (Chips, Mult) - 參考 Balatro 數值
    var baseScore: (chips: Int, mult: Int) {
        switch self {
        case .highCard: return (5, 1)
        case .pair: return (10, 2)
        case .twoPair: return (20, 2)
        case .threeOfAKind: return (30, 3)
        case .straight: return (30, 4)
        case .flush: return (35, 4)
        case .fullHouse: return (40, 4)
        case .fourOfAKind: return (60, 7)
        case .straightFlush: return (100, 8)
        }
    }
    
    static func < (lhs: PokerHandType, rhs: PokerHandType) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    /// 檢查此牌型是否包含另一種牌型 (例如 Full House 包含 Pair, Two Pair, Three of a Kind)
    func contains(_ other: PokerHandType) -> Bool {
        if self == other { return true }
        
        switch self {
        case .straightFlush:
            return [.flush, .straight, .threeOfAKind, .twoPair, .pair, .highCard].contains(other) // Straight Flush contains everything? logic check:
            // Balatro logic:
            // Straight Flush contains Flush and Straight.
            // Does it contain Pair? No, unless the specific cards do, but Straight Flush cards are distinct.
            // Wait, Balatro "Contains" logic usually refers to the *hand type* hierarchy or if the hand *is made of* that.
            // Actually, in Balatro:
            // "Pair" Joker triggers if the hand *contains* a pair.
            // A Full House (3,3,3, 2,2) definitely contains a Pair (and a 3oak).
            // A Four of a Kind (4,4,4,4) contains a Pair and 3oak.
            // A Straight Flush does NOT contain a pair (unless played 5 cards happen to, but standard straight flush doesn't).
            // However, the user request says: "because it is a hand type derived from a pair".
            // So logic:
            // Pair <= Two Pair, Three of a Kind, Full House, Four of a Kind.
            // Straight? No. Flush? No. Straight Flush? No.
            
            // Let's implement strict hierarchy based on "X is composed of Y" logic.
            
        case .fourOfAKind:
            return [.threeOfAKind, .pair, .highCard].contains(other)
            
        case .fullHouse:
            return [.threeOfAKind, .twoPair, .pair, .highCard].contains(other)
            
        case .threeOfAKind:
            return [.pair, .highCard].contains(other)
            
        case .twoPair:
            return [.pair, .highCard].contains(other)
            
        case .pair:
            return other == .highCard
            
        default:
            return other == .highCard
        }
    }
    
    // MARK: - 牌型判定邏輯
    
    /// 根據傳入的卡牌判定最佳牌型
    /// - Parameters:
    ///   - cards: 玩家打出的牌
    ///   - handSizeParam: 構成同花/順子所需的最少張數 (預設 5，"Four Fingers" 為 4)
    ///   - blurSuits: 是否模糊花色 (預設 false，"Smeared Joker" 為 true)
    static func identify(cards: [Card], handSizeParam: Int = 5, blurSuits: Bool = false) -> HandEvaluation {
        // 如果有效牌過少，直接回傳 High Card
        // 注意：High Card 即使只有 1 張也算
        guard !cards.isEmpty else {
            return HandEvaluation(handType: .highCard, scoringCards: [], otherCards: [])
        }
        
        // 為了計算順子與其他邏輯，先排序
        let sortedCards = cards.sorted { $0.rank > $1.rank }
        
        // 計算點數分佈
        var rankCounts: [Rank: Int] = [:]
        for card in cards {
            rankCounts[card.rank, default: 0] += 1
        }
        
        // --- 判定 Flush ---
        // 根據 blurSuits 決定如何統計花色
        // 如果 blurSuits = true:
        //   Hearts, Diamonds -> 視為同一組 (例如都歸類到 Hearts)
        //   Spades, Clubs -> 視為同一組 (例如都歸類到 Spades)
        // 否則各自獨立
        
        var suitCounts: [Suit: Int] = [:]
        for card in cards {
            let effectiveSuit: Suit
            if blurSuits {
                switch card.suit {
                case .diamonds: effectiveSuit = .hearts
                case .clubs: effectiveSuit = .spades
                default: effectiveSuit = card.suit
                }
            } else {
                effectiveSuit = card.suit
            }
            suitCounts[effectiveSuit, default: 0] += 1
        }
        
        // 檢查是否有任一花色數量 >= handSizeParam
        let maxSuitCount = suitCounts.values.max() ?? 0
        let isFlush = maxSuitCount >= handSizeParam
        
        // --- 判定 Straight ---
        // 檢查是否有連續 handSizeParam 張
        let (isStraight, straightCards) = checkStraight(sortedCards, requiredCount: handSizeParam)
        
        // 找出構成 Flush 的牌 (用於 Straight Flush 判定)
        // 注意：如果 blurSuits，我們要找出所有符合該 "大花色" 的牌
        var flushCards: [Card] = []
        if isFlush {
            // 找到那個數量足夠的花色
            if let flushSuit = suitCounts.first(where: { $0.value >= handSizeParam })?.key {
                flushCards = sortedCards.filter { card in
                    let effective: Suit
                    if blurSuits {
                        switch card.suit {
                        case .diamonds: effective = .hearts
                        case .clubs: effective = .spades
                        default: effective = card.suit
                        }
                    } else {
                        effective = card.suit
                    }
                    return effective == flushSuit
                }
            }
        }
        
        // --- 1. Straight Flush ---
        // 必須同時滿足 Flush 和 Straight
        // 且構成 Flush 的那些牌裡面，必須包含一個 Straight
        // (Balatro 規則：Flush House 也算 Straight Flush 的一種，但這裡先標準 Straight Flush)
        if isFlush && isStraight {
            // 進一步檢查：FlushCards 裡面是否有 Straight
            let (flushHasStraight, flushStraightCards) = checkStraight(flushCards, requiredCount: handSizeParam)
            if flushHasStraight {
                // 優先取用 "Straight Flush" 的那幾張作為 scoring
                // 若有多餘的同花牌，歸為 scoring 還是 other?
                // Balatro 規則：Straight Flush 只有那 5 張 (或 4 張) 計分。
                // 這裡簡化：取 flushStraightCards 為主
                let others = sortedCards.filter { !flushStraightCards.contains($0) }
                return HandEvaluation(handType: .straightFlush, scoringCards: flushStraightCards, otherCards: others)
            }
        }
        
        // --- 2. Four of a Kind ---
        if let rank = rankCounts.first(where: { $0.value >= 4 })?.key {
            // 只要有 4 張一樣即可，不受 handSizeParam 影響 (依題目描述 4張規則只影響同花/順子)
            let scoring = sortedCards.filter { $0.rank == rank } // 取出這4張 (或更多)
            // 取前4張
            let finalScoring = Array(scoring.prefix(4))
            let others = sortedCards.filter { !finalScoring.contains($0) }
            return HandEvaluation(handType: .fourOfAKind, scoringCards: finalScoring, otherCards: others)
        }
        
        // --- 3. Full House ---
        // 3 + 2
        let threes = rankCounts.filter { $0.value >= 3 }.keys
        let twos = rankCounts.filter { $0.value >= 2 }.keys
        
        if let threeRank = threes.first {
            // 找另一個 Pair (不能是同一個 Rank)
            if let twoRank = twos.first(where: { $0 != threeRank }) {
                let scoringThree = sortedCards.filter { $0.rank == threeRank }.prefix(3)
                let scoringTwo = sortedCards.filter { $0.rank == twoRank }.prefix(2)
                let scoring = Array(scoringThree) + Array(scoringTwo)
                let others = sortedCards.filter { !scoring.contains($0) }
                return HandEvaluation(handType: .fullHouse, scoringCards: scoring, otherCards: others)
            }
        }
        
        // --- 4. Flush ---
        if isFlush {
            // flushCards 包含了所有符合花色的牌 (可能 > 5)
            // 應該只取前 5 張 (或 handSizeParam) 計分嗎？
            // Balatro 規則：Flush 計分所有符合花色的牌 (如果是打 5 張)。
            // 但如果 "Four Fingers" 打 5 張 (4紅1黑)，則只計 4 紅?
            // Balatro: If valid hand is Flush, all cards count IF they match suit?
            // No, usually only the played hand type cards score.
            // 這裡簡單處理：flushCards 全部計分
            let others = sortedCards.filter { !flushCards.contains($0) }
            return HandEvaluation(handType: .flush, scoringCards: flushCards, otherCards: others)
        }
        
        // --- 5. Straight ---
        if isStraight {
            let others = sortedCards.filter { !straightCards.contains($0) }
            return HandEvaluation(handType: .straight, scoringCards: straightCards, otherCards: others)
        }
        
        // --- 6. Three of a Kind ---
        if let rank = rankCounts.first(where: { $0.value >= 3 })?.key {
            let scoring = sortedCards.filter { $0.rank == rank }.prefix(3)
            let finalScoring = Array(scoring)
            let others = sortedCards.filter { !finalScoring.contains($0) }
            return HandEvaluation(handType: .threeOfAKind, scoringCards: finalScoring, otherCards: others)
        }
        
        // --- 7. Two Pair ---
        let pairs = rankCounts.filter { $0.value >= 2 }.keys.sorted(by: >)
        if pairs.count >= 2 {
            let pair1 = pairs[0]
            let pair2 = pairs[1]
            let s1 = sortedCards.filter { $0.rank == pair1 }.prefix(2)
            let s2 = sortedCards.filter { $0.rank == pair2 }.prefix(2)
            let scoring = Array(s1) + Array(s2)
            let others = sortedCards.filter { !scoring.contains($0) }
            return HandEvaluation(handType: .twoPair, scoringCards: scoring, otherCards: others)
        }
        
        // --- 8. Pair ---
        if let rank = rankCounts.first(where: { $0.value >= 2 })?.key {
            let scoring = sortedCards.filter { $0.rank == rank }.prefix(2)
            let finalScoring = Array(scoring)
            let others = sortedCards.filter { !finalScoring.contains($0) }
            return HandEvaluation(handType: .pair, scoringCards: finalScoring, otherCards: others)
        }
        
        // --- 9. High Card ---
        // 所有牌都列為 scoring，因為 High Card 概念就是雜牌組合
        return HandEvaluation(handType: .highCard, scoringCards: sortedCards, otherCards: [])
    }
    
    // 檢查是否為順子 (回傳: 是否符合, 構成順子的那幾張牌)
    private static func checkStraight(_ sortedCards: [Card], requiredCount: Int) -> (Bool, [Card]) {
        // 先去重 rank (順子不看花色，且對子無助於順子長度)
        // 但需要保留原本的 Card 物件以便回傳
        // 策略：取 unique ranks，檢查是否有連續 requiredCount 個
        
        let uniqueRankCards = sortedCards.reduce(into: [Card]()) { result, card in
            if !result.contains(where: { $0.rank == card.rank }) {
                result.append(card)
            }
        }
        
        // 必須至少有 requiredCount 張不重複點數的牌
        if uniqueRankCards.count < requiredCount {
            return (false, [])
        }
        
        let ranks = uniqueRankCards.map { $0.rank.rawValue }
        
        // 檢查連續序列
        // 因為是 sorted descending (大到小)，例如 10, 9, 8, 7...
        // 滑動視窗
        for i in 0...(uniqueRankCards.count - requiredCount) {
            let subset = Array(uniqueRankCards[i..<i+requiredCount])
            let subsetRanks = subset.map { $0.rank.rawValue }
            
            // 檢查是否連續 (由大到小，差值為 1)
            var isSeq = true
            for k in 0..<subsetRanks.count - 1 {
                if subsetRanks[k] - subsetRanks[k+1] != 1 {
                    isSeq = false
                    break
                }
            }
            
            if isSeq {
                return (true, subset)
            }
            
            // 特殊檢查：A-Low Straight (例如 A, 5, 4, 3, 2)
            // 如果 requiredCount 是 5: 14, 5, 4, 3, 2
            // 如果 requiredCount 是 4: 14, [any], 3, 2, 1? No.
            // A, 5, 4, 3 -> 14, 5, 4, 3
            // A, 4, 3, 2 -> 14, 4, 3, 2 ?? No usually standard straight logic.
            // 這裡保留 A, 5, 4, 3, 2 的標準判斷 (如果是 5 張)
            // 如果是 4 張： A, 5, 4, 3 ? (Wheel straight subset)
            // 簡單起見：檢查 subsetRanks 是否包含 14, 5, 4, 3 (如果是4張)
        }
        
        // 比較麻煩的 Special Case: Ace Low Straight
        // 如果 ranks 包含 14 (Ace) 且包含 2, 3, 4, 5...
        // 嘗試把 14 當作 1
        if uniqueRankCards.contains(where: { $0.rank == .ace }) {
            // 建構一個把 Ace 當 1 的陣列
            // 重新檢查
            // 這裡邏輯較繁瑣，簡化處理：
            // 如果是 5 張：檢查 [14, 5, 4, 3, 2] 存在
            // 如果是 4 張：檢查 [14, 5, 4, 3] 或 [14, 4, 3, 2] ?
            // Balatro 裡 Four Fingers 能用 A, 2, 3, 4 嗎? 可以。
            
            // 讓我們手動檢查這種特定組合
            let hasAce = uniqueRankCards.contains { $0.rank == .ace }
            let has2 = uniqueRankCards.contains { $0.rank == .two }
            let has3 = uniqueRankCards.contains { $0.rank == .three }
            let has4 = uniqueRankCards.contains { $0.rank == .four }
            let has5 = uniqueRankCards.contains { $0.rank == .five }
            
            if requiredCount == 5 {
                if hasAce && has2 && has3 && has4 && has5 {
                    // 找出對應的卡
                    let s = uniqueRankCards.filter { [.ace, .five, .four, .three, .two].contains($0.rank) }
                    return (true, s)
                }
            } else if requiredCount == 4 {
                // A, 2, 3, 4
                if hasAce && has2 && has3 && has4 {
                    let s = uniqueRankCards.filter { [.ace, .four, .three, .two].contains($0.rank) }
                    return (true, s)
                }
                // A, 5, 4, 3 (Ace high but ends low?? No standard straight is A-K-Q-J-10 or 5-4-3-2-A)
                // Actually A, 2, 3, 4 is valid (Ace as 1).
                // 5, 4, 3, 2 is valid normally.
            }
        }
        
        return (false, [])
    }

    
}

/// 牌型計算結果
struct HandEvaluation {
    let handType: PokerHandType
    let scoringCards: [Card] // 實際構成牌型的牌 (例如 Two Pair 就只有那 4 張)
    let otherCards: [Card] // 不計分的手牌 (但可能觸發其他效果)
    
    // 初始計算分數 (尚未包含 Joker 加成)
    var baseChips: Int {
        // 牌型基礎籌碼 + 每一張計分牌的籌碼
        let typeChips = handType.baseScore.chips
        let cardChips = scoringCards.reduce(0) { $0 + $1.chips }
        return typeChips + cardChips
    }
    
    var baseMult: Int {
        handType.baseScore.mult
    }
}
