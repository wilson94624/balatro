import Foundation
import AVFoundation
import AudioToolbox
import UIKit

/// 音效管理器 (Singleton)
class AudioManager {
    static let shared = AudioManager()
    
    // 音效播放器快取
    private var players: [String: AVAudioPlayer] = [:]
    private var bgmPlayer: AVAudioPlayer?
    
    private init() {}
    
    /// 預定義音效名稱 (對應檔案名稱，不含副檔名)
    enum Sound: String {
        case select = "card-slide-1"      // 選牌/移動
        case chip = "chips-collide-1"     // 計分/籌碼撞擊
        case score = "chips-stack-1"      // 結算/籌碼堆疊
        case win = "chips-handle-4"       // 勝利/收籌碼
        case lose = "card-shove-1"        // 失敗/被推開
        case shuffle = "card-shuffle"     // 洗牌
    }
    
    /// 播放音效
    func playSound(_ sound: Sound) {
        // 檢查是否已有播放器，若無則嘗試載入
        if let player = players[sound.rawValue] {
            if player.isPlaying {
                player.stop()
                player.currentTime = 0
            }
            player.play()
        } else {
            // 嘗試尋找檔案，支援多種副檔名
            let extensions = ["wav", "mp3", "m4a", "ogg"]
            var url: URL?
            
            for ext in extensions {
                if let foundUrl = Bundle.main.url(forResource: sound.rawValue, withExtension: ext) {
                    url = foundUrl
                    break
                }
            }
            
            guard let validUrl = url else {
                print("Audio file not found: \(sound.rawValue)")
                return
            }
            
            do {
                let player = try AVAudioPlayer(contentsOf: validUrl)
                player.prepareToPlay()
                player.play()
                players[sound.rawValue] = player
            } catch {
                print("Failed to load audio: \(error)")
            }
        }
    }
    
    /// 震動回饋 (Haptics) - 輔助增強手感
    func playHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    /// 播放背景音樂 (循環)
    func playBackgroundMusic() {
        // 優先尋找 "Balatro Main Theme"
        let bgmNames = ["Balatro Main Theme", "joker_theme", "bgm"]
        let extensions = ["mp3", "wav", "m4a", "ogg"]
        var url: URL?
        
        // 雙重迴圈尋找檔案
        for name in bgmNames {
            for ext in extensions {
                if let foundUrl = Bundle.main.url(forResource: name, withExtension: ext) {
                    url = foundUrl
                    break
                }
            }
            if url != nil { break }
        }
        
        guard let validUrl = url else {
            print("Background music file not found.")
            return
        }
        
        do {
            bgmPlayer = try AVAudioPlayer(contentsOf: validUrl)
            bgmPlayer?.numberOfLoops = -1 // 無限循環
            bgmPlayer?.volume = 0.5 // 背景音樂稍微小聲一點
            bgmPlayer?.prepareToPlay()
            bgmPlayer?.play()
        } catch {
            print("Failed to load background music: \(error)")
        }
    }
    
    /// 停止背景音樂
    func stopBackgroundMusic() {
        bgmPlayer?.stop()
    }
}
