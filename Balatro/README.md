# 🃏 Balatro Lite (SwiftUI Edition)

**Balatro Lite** 是一個基於 iOS SwiftUI 開發的 Roguelike 撲克卡牌遊戲，致敬了知名獨立遊戲《Balatro》。玩家需要透過打出撲克牌型來獲得籌碼，並利用強大的「小丑牌 (Jokers)」來強化牌組與得分倍率，目標是擊敗不斷增強的關卡敵人（盲注）。

![Game Screenshot](https://via.placeholder.com/800x400?text=Balatro+Lite+Screenshot) 
*(請自行替換為實際遊戲截圖)*

## ✨ 核心特色 (Features)

### 🎮 Roguelike 撲克玩法
- **牌型計分**：支援標準撲克牌型（同花、順子、葫蘆等），並結合 **籌碼 (Chips)** 與 **倍率 (Mult)** 的計分機制。
- **動態難度**：每一回合的目標分數會指數級成長，考驗玩家的構築能力。
- **智慧手牌管理**：支援按「點數」或「花色」一鍵排序手牌。

### 🤡 深度小丑牌系統 (Joker System)
- **多樣化效果**：包含加分、加倍率、條件觸發等多種小丑牌。
- **進階判斷邏輯**：小丑牌不僅看最終牌型，還會分析手牌結構（例如：打出同花但包含一對，也能觸發「一對」相關的小丑）。
- **商店與經濟**：
  - **買賣機制**：可購買隨機生成的小丑牌，或販賣舊牌以騰出空間。
  - **補充包 (Booster Packs)**：經典的「三選一」開包機制。
  - **利息系統**：每回合結束根據存款提供利息獎勵，鼓勵存錢策略。

### 📱 現代化 UI/UX
- **響應式設計**：完美支援橫向 (Landscape) 與 直向 (Portrait) 遊玩，大廳介面自動適配。
- **精緻視覺**：全應用採用玻璃擬態 (Glassmorphism) 風格與流暢動畫。
- **觸覺回饋**：出牌、得分與購買時皆有細緻的 Haptic Feedback。
- **繁體中文化**：完整在地化的卡牌名稱與效果說明。

## 🛠 技術堆疊 (Tech Stack)

- **語言**：Swift 5.9+
- **框架**：SwiftUI
- **架構**：MVVM (Model-View-ViewModel)
- **狀態管理**：使用 iOS 26 最新 `@Observable` 宏 (Macro)，移除傳統 `ObservableObject`。
- **數據持久化**：使用 `UserDefaults` 儲存最高分紀錄。

## 🚀 如何執行 (How to Run)

1. 確保你的 Mac 安裝了 **Xcode 15+**。
2. 雙擊開啟 `Balatro.xcodeproj`。
3. 選擇模擬器（建議 iPhone 15 Pro / Max）或實體裝置。
4. 按下 `Cmd + R` 執行專案。

## 📝 開發日誌與更新

- **v1.0**：基礎玩法實現，包含計分與出牌邏輯。
- **v1.1**：新增商店系統與經濟循環。
- **v1.2**：實作小丑牌「包含判定」邏輯與販賣功能。
- **v1.3**：優化大廳 UI 與橫向適配。

## 📜 聲明 (Disclaimer)

本專案為 iOS 開發練習作品，核心玩法與設計概念致敬 LocalThunk 的遊戲《Balatro》。素材與程式碼僅供學習交流使用。

---
*Created by 01257150劉耀升*
