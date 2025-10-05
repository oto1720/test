import SwiftUI
import SwiftData

struct ContentView: View {
    // SwiftDataの操作を行うためのモデルコンテキストを環境から取得します。
    @Environment(\.modelContext) private var modelContext

    // 保存されている全てのMemoオブジェクトを取得し、作成日時の降順でソートします。
    // この@Queryが、CRUDの「Read」操作を自動的に行います。
    @Query(sort: \Memo.createdAt, order: .reverse) private var memos: [Memo]

    // メモ編集用のシートを表示するかどうかを管理するState。
    @State private var isShowingEditor = false
    // 編集対象のメモを保持するState。
    @State private var selectedMemo: Memo? = nil

    var body: some View {
        NavigationStack {
            List {
                // 取得したメモの一覧を表示します。
                ForEach(memos) { memo in
                    VStack(alignment: .leading) {
                        Text(memo.content)
                            .lineLimit(3)
                        Text(memo.createdAt, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // メモをタップすると編集対象として設定します。
                        // これがCRUDの「Update」操作の開始点です。
                        selectedMemo = memo
                    }
                }
                // リストの項目をスワイプして削除する機能を有効にします。
                // これがCRUDの「Delete」操作です。
                .onDelete(perform: deleteMemos)
            }
            .navigationTitle("CRUD Memo")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // 新規作成のため、選択中のメモをnilにしてエディタを表示します。
                        // これがCRUDの「Create」操作の開始点です。
                        selectedMemo = nil
                        isShowingEditor = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            // isShowingEditorかselectedMemoが変更されたときにシートを表示します。
            .sheet(isPresented: $isShowingEditor) {
                MemoEditorView(memo: $selectedMemo)
            }
            .onChange(of: selectedMemo) { oldValue, newValue in
                // selectedMemoがnilでなくなり、かつエディタが表示されていない場合に表示する
                if newValue != nil && !isShowingEditor {
                    isShowingEditor = true
                }
            }
            .onChange(of: isShowingEditor) {
                // シートが閉じたときに選択を解除する
                if !isShowingEditor {
                    selectedMemo = nil
                }
            }
        }
    }

    /// 選択されたインデックスのメモを削除します。
    private func deleteMemos(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                // modelContextに削除を指示します。
                modelContext.delete(memos[index])
            }
        }
    }
}

/// メモを新規作成または編集するためのビュー。
struct MemoEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // 編集対象のメモ。ContentViewから渡される。
    @Binding var memo: Memo?
    
    // 編集中のテキストを保持するState。
    @State private var content: String = ""

    var body: some View {
        NavigationStack {
            VStack {
                TextEditor(text: $content)
                    .padding()
            }
            .navigationTitle(memo == nil ? "New Memo" : "Edit Memo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                }
            }
            .onAppear {
                // ビューが表示されたときに、編集対象のメモの内容をStateに設定します。
                content = memo?.content ?? ""
            }
        }
    }

    /// メモを保存します。
    private func save() {
        if let memo {
            // すでに存在するメモの場合、内容を更新します。
            // これがCRUDの「Update」操作の実行部分です。
            memo.content = content
        } else {
            // 新規メモの場合、新しいMemoオブジェクトを作成してコンテキストに挿入します。
            // これがCRUDの「Create」操作の実行部分です。
            let newMemo = Memo(content: content, createdAt: .now)
            modelContext.insert(newMemo)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Memo.self, inMemory: true)
}