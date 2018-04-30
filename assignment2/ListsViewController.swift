//
//  FirstViewController.swift
//  assignment2
//
//  Created by Alex Viney on 30/4/18.
//  Copyright © 2018 Alex Viney. All rights reserved.
//

import UIKit

class ListsViewController: UIViewController {
    
    var lists = [List]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let database : SQLiteDataBase = SQLiteDataBase(databaseName: "MyDatabase")
        database.dropListsTable()
        database.createListsTable()
        database.insert(list: List(ID: 0, name:"List 1"))
        database.insert(list: List(ID: 1, name: "Dinner List"))
        
        lists = database.selectAllLists()
        
        print(lists)
    }
}

