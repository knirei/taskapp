//
//  Task.swift
//  taskapp
//
//  Created by 楡井謙一 on 2018/05/01.
//  Copyright © 2018年 knirei. All rights reserved.
//

import RealmSwift

class Task: Object {
    @objc dynamic var id = 0
    
    @objc dynamic var title = ""
    
    @objc dynamic var contents = ""
    
    @objc dynamic var date = Date()
    
    @objc dynamic var category = ""

    override static func primaryKey() -> String? {
        return "id"
    }
}
