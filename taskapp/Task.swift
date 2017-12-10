//
//  Task.swift
//  taskapp
//
//  Created by Chihiro Endo on 2017/11/30.
//  Copyright © 2017年 Chihiro Endo. All rights reserved.
//


import RealmSwift

class Task: Object {
    // 管理用 ID。プライマリーキー
    dynamic var id = 0
    
    // タイトル
    dynamic var title = ""
    
    //カテゴリー
    dynamic var category = ""
    
    // 内容
    dynamic var contents = ""
    
    /// 日時
    dynamic var date = NSDate()
    
    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
    }
}
