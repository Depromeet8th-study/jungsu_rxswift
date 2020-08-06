//
//  Memo.swift
//  RxMemo
//
//  Created by Yeojaeng on 2020/08/06.
//  Copyright © 2020 Yeojaeng. All rights reserved.
//

import Foundation

struct Memo: Equatable {
    var content: String
    var insertDate: Date
    var identity: String            // 메모를 구분하기 위한 속성.
    
    
    init(content: String, insertDate: Date = Date()) {
        self.content = content
        self.insertDate = insertDate
        self.identity = "\(insertDate.timeIntervalSinceReferenceDate)"
    }
    
    init(original: Memo, updatedContent: String) {
        self = original
        self.content = updatedContent
    }
}
