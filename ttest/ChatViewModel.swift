//
//  ChatViewModel.swift
//  ttest
//
//  Created by Bruce on 2025/3/4.
//

import Foundation

class ChatViewModel: ObservableObject {
    @Published var messages: [String] = []
    @Published var planTitle: String = "" // 新增計畫標題
    @Published var subjectRange: String = "" // 新增科目範圍
    @Published var deadline: Date = Date() // 改為 Date 類型
    @Published var preferredTime: String = "" // 新增讀書偏好時間
    @Published var note: String = "" // 新增備注
    
    @Published var isPlanTitleEmpty: Bool = false
    @Published var isSubjectRangeEmpty: Bool = false

    private func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/M/d"
        return formatter.string(from: Date())
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/M/d"
        return formatter.string(from: date)
    }

    func sendMessage() {
        // 檢查必填欄位
        isPlanTitleEmpty = planTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        isSubjectRangeEmpty = subjectRange.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        // 如果有必填欄位未填寫，不發送消息
        if isPlanTitleEmpty || isSubjectRangeEmpty {
            return
        }

        let prompt = """
請依據以下資訊，為我規劃一份詳細且可實際執行的讀書計劃：
- 閱讀標題：\(planTitle)
- 閱讀範圍總量：\(subjectRange)
  （例如：「第 1～200 頁」或「第 1～10 章」，請以實際可拆分的區段視為單位）
- 目前進度：0%（尚未開始）
- 當前時間：\(getCurrentTime())
- 完成截止日期：\(formatDate(deadline))（必須在此日期前完成）
- 偏好讀書時段：\(preferredTime)
- 其他備註：\(note)

請執行下列步驟：
1. 計算從今天（含）到截止日期（含）之間的總天數。
2. 根據「閱讀範圍總量」的實際單位（如頁數或章節），將其平均分配到這些天數，並依序列出每一天對應的閱讀區段（例如，第 1-10 頁、第 11-20 頁；或第 1-2 章、第 3-4 章）。
3. 若有餘數或拆分不均，請將剩餘部分分配到其中一些天，使得所有閱讀都能在截止日期之前完成。若平均分配後仍不足以在截止日前讀完，則在部分天數上額外增加更大區段。
4. 最後，請僅使用以下格式逐日列出結果（無須任何額外解釋或其他文字）：
{YYYY-MM-DD}: {閱讀標題} - {該日對應的閱讀區段}

例如：
2025-03-21: 計算機科學導論 - 第 1～10 頁
2025-03-22: 計算機科學導論 - 第 11～20 頁
... 以此類推，直到全部範圍分配完畢。

請謹記：不得添加與此無關的內容，否則後果將非常嚴重。務必確保在截止日前可讀完所有內容。
"""




        
        // 先顯示 prompt
        DispatchQueue.main.async {
            self.messages.append("Prompt: \(prompt)")
        }
        
        OpenAIService.fetchGPTResponse(prompt: prompt) { response in
            DispatchQueue.main.async {
                if let response = response {
                    self.messages.append(response)
                } else {
                    self.messages.append("AI 無法回應")
                }
            }
        }
    }
}
