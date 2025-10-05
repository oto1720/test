import Foundation
import SwiftData

/// アプリケーションで管理するメモのデータを表現するモデル。
/// @Modelマクロにより、SwiftDataがこのクラスを永続化の対象として認識します。
@Model
final class Memo {
    
    /// メモの内容。
    var content: String
    
    /// メモが作成された日時。
    var createdAt: Date
    
    init(content: String, createdAt: Date) {
        self.content = content
        self.createdAt = createdAt
    }
}
