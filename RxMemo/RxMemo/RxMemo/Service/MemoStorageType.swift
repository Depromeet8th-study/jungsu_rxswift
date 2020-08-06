//
//  MemoStorageType.swift
//  RxMemo
//
//  Created by Yeojaeng on 2020/08/06.
//  Copyright © 2020 Yeojaeng. All rights reserved.
//

import Foundation
import RxSwift

// 기본적인 CRUD 작업을 처리하는 메소드 선언.
protocol MemoStorageType {
    @discardableResult
    func createMemo(content: String) -> Observable<Memo>
    
    @discardableResult
    func memoList() -> Observable<[Memo]>
    
    @discardableResult
    func update(memo: Memo, content: String) -> Observable<Memo>
    
    @discardableResult
    func delete(memo: Memo) -> Observable<Memo>
}
