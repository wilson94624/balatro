import SwiftUI
import Observation

/// 遊戲階段
enum GameState {
    case menu           // 主選單
    case playing        // 遊戲中 (出牌階段)
    case shopping       // 商店階段 (回合勝利後)
    case gameOver       // 遊戲結束
}

/// 核心遊戲狀態管理 (使用 @Observable)
@Observable
class GameModel {
    // MARK: - 遊戲進程屬性
    var state: GameState = .menu
    
    // 玩家屬性
    var money: Int = 0
    var jokers: [Joker] = []
    var maxJokers: Int = 5
    
    // 關卡 (Ante) 屬性
    var currentRound: Int = 1
    var targetScore: Int = 300 // 初始目標分數 (Blind)
    var currentScore: Int = 0  // 本回合累積分數
    
    // 回合內屬性
    var handsRemaining: Int = 4    // 剩餘出牌次數
    var discardsRemaining: Int = 3 // 剩餘棄牌次數
    
    // 牌庫管理
    var deck: [Card] = []      // 牌庫
    var hand: [Card] = []      // 手牌
    var selectedCards: Set<UUID> = [] // 玩家選中的牌
    
    // MARK: - 商店屬性
    var shopJokers: [Joker] = []
    var currentBoosterPack: BoosterPack?
    var packOpeningContent: [Joker]? // 若不為 nil，代表正在開卡包畫面
    
    struct BoosterPack: Identifiable {
        let id = UUID()
        let name: String
        let cost: Int
        let contents: [Joker]
    }
    
    // MARK: - 計分動畫狀態
    struct ScoringDetail {
        var chips: Int = 0
        var mult: Int = 0
        var total: Int = 0
        var description: String = ""
        var isAnimating: Bool = false
        var playedCards: [Card] = [] // 新增：紀錄當前計分的牌
    }
    var scoringDetail = ScoringDetail()
    
    // MARK: - 初始化
    init() {
        // startNewGame()
        state = .menu
    }
    
    // MARK: - 遊戲流程控制
    
    /// 開始新遊戲 (重置所有狀態)
    func startNewGame() {
        money = 0
        jokers = []
        currentRound = 1
        resetRound(target: 300)
        
        state = .playing // 這裡可以改回 .menu 如果有首頁的話，MVP 先直接開始
    }
    
    /// 開始新的回合 (重置牌庫與手牌)
    func resetRound(target: Int) {
        targetScore = target
        currentScore = 0
        handsRemaining = 4
        discardsRemaining = 3
        
        // 重置牌庫 (52張)
        deck = []
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                deck.append(Card(suit: suit, rank: rank))
            }
        }
        deck.shuffle()
        
        // 抽滿手牌 (假設手牌上限 8 張)
        hand = []
        drawCards(count: 8)
        selectedCards.removeAll()
    }
    
    /// 抽牌邏輯
    func drawCards(count: Int) {
        for _ in 0..<count {
            if let card = deck.popLast() {
                hand.append(card)
            }
        }
        // 排序手牌 (選用: 讓手牌整齊)
        sortHand()
    }
    
    // MARK: - 排序設定
    enum SortType {
        case rank
        case suit
    }
    var sortType: SortType = .rank
    
    /// 切換排序方式
    func toggleSort() {
        switch sortType {
        case .rank: sortType = .suit
        case .suit: sortType = .rank
        }
        sortHand()
        AudioManager.shared.playSound(.select) // 使用現有的音效
    }

    /// 排序手牌
    func sortHand() {
        hand.sort {
            switch sortType {
            case .rank:
                if $0.rank == $1.rank {
                    return $0.suit.id < $1.suit.id
                }
                return $0.rank < $1.rank
            case .suit:
                if $0.suit == $1.suit {
                    return $0.rank < $1.rank
                }
                return $0.suit.id < $1.suit.id
            }
        }
    }
    

    
    /// 選擇/取消選擇卡牌
    func toggleSelection(card: Card) {
        AudioManager.shared.playSound(.select)
        AudioManager.shared.playHaptic()
        
        if selectedCards.contains(card.id) {
            selectedCards.remove(card.id)
        } else {
            // 限制最多選 5 張
            if selectedCards.count < 5 {
                selectedCards.insert(card.id)
            }
        }
    }
    
    // MARK: - 更多邏輯
    
    /// 棄牌邏輯
    func discardHand() {
        guard state == .playing else { return }
        guard discardsRemaining > 0 else { return }
        guard !selectedCards.isEmpty else { return }
        
        AudioManager.shared.playSound(.shuffle)
        
        // 1. 移除選中的牌
        hand.removeAll { selectedCards.contains($0.id) }
        
        // 2. 抽新牌補滿 (假設維持手上牌數，或補滿到 8 張? Balatro 規則是補滿到 Hand Size)
        // 這裡實作補滿到 8 張
        let cardsNeeded = 8 - hand.count
        if cardsNeeded > 0 {
            drawCards(count: cardsNeeded)
        }
        
        // 3. 扣除次數
        discardsRemaining -= 1
        selectedCards.removeAll()
        sortHand()
    }
    
    /// 出牌邏輯 (非同步，因為要包含動畫延遲)
    func playHand() async {
        guard state == .playing else { return }
        guard handsRemaining > 0 else { return }
        guard !selectedCards.isEmpty else { return }
        
        // 1. 取得選中的牌
        let playedCards = hand.filter { selectedCards.contains($0.id) }
        
        // 2. 判定牌型 (考量 Joker 特殊效果)
        var handSizeParam = 5
        var blurSuits = false
        
        for joker in jokers {
            if case .allowFourCardHands = joker.effect {
                handSizeParam = 4
            }
            if case .blurredSuits = joker.effect {
                blurSuits = true
            }
        }
        
        let evaluation = PokerHandType.identify(cards: playedCards, handSizeParam: handSizeParam, blurSuits: blurSuits)
        
        // Start Animation State
        scoringDetail = ScoringDetail(
            chips: evaluation.baseChips,
            mult: evaluation.baseMult,
            total: 0,
            description: evaluation.handType.name,
            isAnimating: true,
            playedCards: playedCards // 傳入打出的牌
        )
        
        AudioManager.shared.playSound(.score)
        try? await Task.sleep(nanoseconds: 600_000_000)
        
        // 3. 計算分數 (逐步計分)
        await performScoringSequence(evaluation: evaluation)
        
        // 4. 結算
        // 更新當前分數
        currentScore += scoringDetail.total
        
        // 停止動畫
        try? await Task.sleep(nanoseconds: 500_000_000)
        scoringDetail.isAnimating = false
        
        // 金錢獎勵 (移除打牌給錢)
        // money += 1

        
        // 移除打出的牌
        hand.removeAll { selectedCards.contains($0.id) }
        selectedCards.removeAll()
        
        // 扣除出牌次數
        handsRemaining -= 1
        
        // 5. 補牌
        let cardsNeeded = 8 - hand.count
        if cardsNeeded > 0 {
            drawCards(count: cardsNeeded)
        }
        
        // 6. 判定勝負
        checkRoundEnd()
    }
    
    /// 逐步計分邏輯 (動畫用)
    private func performScoringSequence(evaluation: HandEvaluation) async {
        var currentChips = evaluation.baseChips
        var currentMult = evaluation.baseMult
        
        // 基礎分展示
        AudioManager.shared.playSound(.chip)
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // 套用 Jokers 效果
        
        // 分析打出的牌包含哪些 "Rank-based" 牌型 (Pair, 3-of-a-kind, etc.)
        let cardBasedTypes = calculateContainedTypes(cards: scoringDetail.playedCards)
        
        for joker in jokers {
            var triggered = false
            switch joker.effect {
            case .globalMult(let value):
                currentMult += value
                brandingJokerEffect(joker: joker, description: "+ \(value) Mult")
                triggered = true
                
            case .suitChips(let suit, let value):
                let count = evaluation.scoringCards.filter { $0.suit == suit }.count
                if count > 0 {
                    currentChips += value
                    brandingJokerEffect(joker: joker, description: "+ \(value) Chips")
                    triggered = true
                }
                
            case .typeMult(let type, let value):
                // 觸發條件：最終牌型包含目標 (Hierarchy) 或 打出的牌包含目標 (Rank analysis)
                if evaluation.handType.contains(type) || cardBasedTypes.contains(type) {
                    currentMult += value
                    brandingJokerEffect(joker: joker, description: "+ \(value) Mult")
                    triggered = true
                }
                
            case .typeChips(let type, let value):
                if evaluation.handType.contains(type) || cardBasedTypes.contains(type) {
                    currentChips += value
                    brandingJokerEffect(joker: joker, description: "+ \(value) Chips")
                    triggered = true
                }
                
            case .allowFourCardHands, .blurredSuits:
                // 被動效果，已經在 identify 階段生效，計分時不需額外動作
                break
            }
            
            if triggered {
                updateScoringState(chips: currentChips, mult: currentMult)
                AudioManager.shared.playSound(.chip)
                try? await Task.sleep(nanoseconds: 600_000_000)
            }
        }
        
        // 最終計算
        let finalScore = currentChips * currentMult
        scoringDetail.chips = currentChips
        scoringDetail.mult = currentMult
        scoringDetail.total = finalScore
        scoringDetail.description = "Total"
        AudioManager.shared.playSound(.score)
        AudioManager.shared.playHaptic()
    }
    
    private func brandingJokerEffect(joker: Joker, description: String) {
        scoringDetail.description = "\(joker.name): \(description)"
    }
    
    private func updateScoringState(chips: Int, mult: Int) {
        scoringDetail.chips = chips
        scoringDetail.mult = mult
        scoringDetail.total = chips * mult
    }
    
    // 舊的 calculateScore 可以移除或保留做為純邏輯驗證，這裡直接用 performScoringSequence 取代了核心流程
    
    /// 檢查回合是否結束
    private func checkRoundEnd() {
        if currentScore >= targetScore {
            // 勝利 -> 進入商店
            print("Round Win!")
            print("Round Win!")
            AudioManager.shared.playSound(.win)
            
            // 計算通關獎勵
            let baseReward = 4
            let handsBonus = handsRemaining
            let interest = min(5, money / 5) // 利息上限 $5
            let totalReward = baseReward + handsBonus + interest
            
            money += totalReward
            print("Round Win! Reward: Base \(baseReward) + Hands \(handsBonus) + Interest \(interest) = $\(totalReward)")
            
            saveHighScores() // 儲存最高紀錄
            generateShop() // 生成商店內容
            state = .shopping
        } else if handsRemaining == 0 {
            // 失敗 -> Game Over
            print("Game Over")
            AudioManager.shared.playSound(.lose)
            state = .gameOver
        }
    }
    
    /// 進入下一關
    func startNextRound() {
        // 提高目標分數
        let growthFactor = 1.5
        targetScore = Int(Double(targetScore) * growthFactor)
        currentRound += 1
        
        // 恢復遊戲狀態
        resetRound(target: targetScore)
        state = .playing
    }
    
    /// 購買 Joker
    func buyJoker(_ joker: Joker) {
        guard money >= joker.cost else { return }
        guard jokers.count < maxJokers else { return }
        
        money -= joker.cost
        jokers.append(joker)
        
        // 移除已買的
        if let index = shopJokers.firstIndex(where: { $0.id == joker.id }) {
            shopJokers.remove(at: index)
        }
    }
    
    /// 販賣 Joker
    func sellJoker(_ joker: Joker) {
        if let index = jokers.firstIndex(where: { $0.id == joker.id }) {
            jokers.remove(at: index)
            let sellPrice = max(1, joker.cost / 2) // 至少賣 $1
            money += sellPrice
            AudioManager.shared.playSound(.chip) 
        }
    }
    
    // MARK: - 商店邏輯
    
    func generateShop() {
        shopJokers = []
        
        // 生成 2 張普通/非普通卡 (不重複已擁有的)
        var pool = Joker.demoJokers.filter { joker in
            joker.rarity != .rare &&
            joker.rarity != .legendary &&
            !jokers.contains(where: { $0.name == joker.name })
        }
        
        // 洗牌以獲得隨機性
        pool.shuffle()
        
        // 取前 2 張
        for i in 0..<min(2, pool.count) {
            var newJoker = pool[i]
            newJoker.id = UUID() // 確保唯一
            shopJokers.append(newJoker)
        }
        
        // 生成 1 包卡包 (包含稀有卡的機會)
        generateBoosterPack()
    }
    
    func generateBoosterPack() {
        // 卡包內含 3 張卡，可能包含 Rare
        // 從完整池中隨機不重複抽取 3 張
        var pool = Joker.demoJokers.shuffled()
        var potentialContents: [Joker] = []
        
        for _ in 0..<3 {
            if !pool.isEmpty {
                let joker = pool.removeFirst()
                var newJoker = joker
                newJoker.id = UUID()
                potentialContents.append(newJoker)
            }
        }
        
        currentBoosterPack = BoosterPack(name: "Standard Pack", cost: 4, contents: potentialContents)
    }
    
    func buyBoosterPack() {
        guard let pack = currentBoosterPack else { return }
        guard money >= pack.cost else { return }
        
        money -= pack.cost
        currentBoosterPack = nil // 買完就沒了
        
        // 設定開包內容，觸發 UI 顯示選擇畫面
        packOpeningContent = pack.contents
    }
    
    func selectBoosterCard(_ joker: Joker) {
        guard jokers.count < maxJokers else {
            // 如果滿了，暫時直接關閉或替換邏輯? 
            // MVP: 滿了就不能選? 或者允許替換?
            // Balatro 允許替換。這裡簡化：如果沒滿直接加。如果滿了... 先不做替換，視為放棄?
            // 還是刪除第一張?
            // 簡單處理：如果滿了，加入失敗 (User needs to sell first).
            // 但這是在 Pack 畫面...
            // 讓我們允許暫時加入，或是假設 UI 檢查了 hand size?
            // 這裡直接加入，如果 UI 有擋就可以。
            return 
        }
        
        var newJoker = joker
        newJoker.id = UUID()
        jokers.append(newJoker)
        
        // 關閉選擇畫面
        packOpeningContent = nil
    }
    
    func skipBoosterSelection() {
        packOpeningContent = nil
    }

    // MARK: - Persistence (High Score)
    
    var highScoreRound: Int {
        UserDefaults.standard.integer(forKey: "HighScore_MaxRound")
    }
    
    var highScoreTarget: Int {
        UserDefaults.standard.integer(forKey: "HighScore_MaxTargetScore")
    }
    
    func saveHighScores() {
        let savedRound = UserDefaults.standard.integer(forKey: "HighScore_MaxRound")
        if currentRound > savedRound {
            UserDefaults.standard.set(currentRound, forKey: "HighScore_MaxRound")
        }
        
        // 只有在過關時才記錄該關卡的目標分數
        // 如果是 Game Over，代表這關沒過，不應該記錄這關的目標分數?
        // 題目說: "最高打過幾分的敵人" -> means BEATEN target score.
        // 所以應該在 Win 的時候存。
        let savedTarget = UserDefaults.standard.integer(forKey: "HighScore_MaxTargetScore")
        if targetScore > savedTarget {
            UserDefaults.standard.set(targetScore, forKey: "HighScore_MaxTargetScore")
        }
    }

    // MARK: - Helper Methods
    
    /// 分析手牌中包含的 Rank 牌型 (Pair, Set, etc.)，不考慮花色
    private func calculateContainedTypes(cards: [Card]) -> Set<PokerHandType> {
        var types: Set<PokerHandType> = [.highCard]
        let counts = Dictionary(grouping: cards, by: { $0.rank }).mapValues { $0.count }
        
        let pairs = counts.filter { $0.value >= 2 }.count
        let trips = counts.filter { $0.value >= 3 }.count
        let quads = counts.filter { $0.value >= 4 }.count
        
        if pairs >= 1 { types.insert(.pair) }
        if pairs >= 2 { types.insert(.twoPair) }
        if trips >= 1 { types.insert(.threeOfAKind) }
        if quads >= 1 { types.insert(.fourOfAKind) }
        
        // Full House: 至少一組 3 張，且至少有兩個 Rank 數量 >= 2 (其一為 3 張的那組，另一為 Pair)
        let hasThree = counts.values.contains { $0 >= 3 }
        let rankGroupsAtLeastTwo = counts.values.filter { $0 >= 2 }.count
        if hasThree && rankGroupsAtLeastTwo >= 2 {
            types.insert(.fullHouse)
        }
        
        return types
    }
}
