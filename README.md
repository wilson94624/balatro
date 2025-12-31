# 🃏 Balatro Lite (iOS SwiftUI Edition)

**Balatro Lite** 是一個基於 iOS SwiftUI 開發的 Roguelike 撲克卡牌遊戲，致敬了知名獨立遊戲《Balatro》。玩家需要透過打出撲克牌型來獲得籌碼，並利用強大的「小丑牌 (Jokers)」來強化牌組與得分倍率，目標是擊敗不斷增強的關卡敵人（盲注）。

## ✨ 核心特色 (Features)

### 🎮 深度 Roguelike 撲克玩法
- **動態牌型計分**：支援標準撲克牌型（同花、順子、葫蘆等），並結合 **籌碼 (Chips)** 與 **倍率 (Mult)** 的次世代計分機制。
- **指數級難度成長**：每一關卡的目標分數會隨進度指數上升，考驗玩家的構築極限。
- **特殊牌型判定**：
  - **四指 (Four Fingers)**：允許 4 張牌組成同花或順子。
  - **歪臉 (Smeared Joker)**：紅心/方塊、黑桃/梅花 視為相同花色。

### 🤡 完整的小丑牌系統 (Joker System)
- **10+ 種獨特小丑**：包含基本的加分小丑，以及改變遊戲規則的稀有小丑（如上述的四指與歪臉）。
- **精美 Pixel Art 視覺**：每一張小丑牌都有獨一無二的像素藝術圖案（由 AI 輔助生成）。
- **商店與經濟循環**：
  - **補充包 (Booster Packs)**：經典的「三選一」開包機制，獲取稀有卡牌的主要途徑。
  - **利息系統**：每回合結束根據存款提供利息 (Interest)，鼓勵存錢策略。

### 📱 極致的視聽體驗
- **現代化 UI/UX**：
  - **Glassmorphism 設計**：全應用採用玻璃擬態風格，介面通透且極具質感。
  - **流暢動畫**：計分火焰特效、卡牌發牌與翻轉動畫。
  - **自適應佈局**：完美支援 iPhone 直向 (Portrait) 與 橫向 (Landscape) 遊玩。
- **沉浸式音效**：
  - 整合了選牌、出牌、籌碼碰撞、洗牌等真實音效。
  - 具備背景音樂 (BGM) 與勝利/失敗音效。

## 🛠 技術堆疊 (Tech Stack)

- **語言**：Swift 5.9+
- **框架**：SwiftUI
- **架構**：MVVM (Model-View-ViewModel)
- **狀態管理**：使用 iOS 17+ `@Observable` 宏 (Observation Framework)，移除傳統 `ObservableObject`。
- **音訊引擎**：`AVFoundation` (AVAudioPlayer)
- **數據持久化**：`UserDefaults` (最高分紀錄)

## 📂 專案結構
- `Models/`: 核心資料結構 (`Card`, `Joker`, `PokerHand`, `GameModel`)
- `Views/`: SwiftUI 視圖 (`GameView`, `ShopView`, `LobbyView`, `CardView`)
- `Managers/`: 系統管理器 (`AudioManager`)
- `Assets.xcassets/`: 圖片與 icon 資源
- `Music/`: 音效檔案

## 🚀 如何執行 (How to Run)

1. 確保你的 Mac 安裝了 **Xcode 15+**。
2. 雙擊開啟 `Balatro.xcodeproj`。
3. 選擇模擬器（建議 iPhone 15/16 Pro Max）或實體裝置。
4. 按下 `Cmd + R` 執行專案。

## 📝 開發歷程 (Changelog)

- **v1.3 (Current)**：
    - 新增 10 張小丑牌的 Pixel Art 圖片。
    - 實作完整的音效系統 (BGM + SFX)。
    - 優化 `GameView` 佈局，解決計分面板遮擋手牌的問題。
    - 改進商店介面，新增「下一回合」按鈕的防誤觸間距。
- **v1.2**：實作特殊小丑邏輯 (Four Fingers, Smeared Joker) 與補充包機制。
- **v1.1**：新增商店系統與經濟循環。
- **v1.0**：基礎玩法實現，包含計分與出牌邏輯。

## 📜 聲明 (Disclaimer)
本專案為 iOS 開發練習作品，核心玩法與設計概念致敬 LocalThunk 的遊戲《Balatro》。素材與程式碼僅供學習交流使用。

---
*Created by Wilson*
