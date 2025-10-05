//
//  testApp.swift
//  test
//
//  Created by 乙津孝太朗 on 2025/10/02.
//

import SwiftUI
import SwiftData

@main
struct testApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Memoモデルの永続化コンテナを環境に設定します。
        // これにより、アプリ内のどのビューからでもデータにアクセスできるようになります。
        .modelContainer(for: Memo.self)
    }
}
