//
//  ListsTableViewController.swift
//  assignment2
//
//  Created by Alex Viney on 1/5/18.
//  Copyright © 2018 Alex Viney. All rights reserved.
//

import UIKit
class ListsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    let database : SQLiteDataBase = SQLiteDataBase(databaseName: "MyDatabase")
    
    @IBOutlet weak var listsTableView: UITableView!
    
    var lists = [ListDetail]()
    
    // Set to true to enable seeds.
    var dev = false

    override func viewDidLoad() {
        super.viewDidLoad()
        listsTableView.delegate = self
        listsTableView.dataSource = self
        
        if (dev) {
            // Generate seeds for testing.
            createSeeds()
        } else {
            // Comment out if you have just tested and want to clear seeds.
            // dropTables()
            createTables()
        }

        refreshList()
    }
    
    @IBAction func historyButton(_ sender: Any) {
        performSegue(withIdentifier: "toHistorySegue", sender: self)
    }
    @IBAction func addListButton(_ sender: Any) {
        performSegue(withIdentifier: "toPopUpVCSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPopUpVCSegue" {
            let popup = segue.destination as! PopUpVC
            popup.delegate = self
        }
        if segue.identifier == "toListSegue" {
            guard let listViewController = segue.destination as? ListViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }

            guard let selectedListCell = sender as? ListsTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            guard let indexPath = listsTableView.indexPath(for: selectedListCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let selectedList = lists[indexPath.row]
            listViewController.listDetail = selectedList
            listViewController.delegate = self
        }
    }
    
    func createSeeds() {
        dropTables()
        createTables()
        var counter = 0
        let items = ["Bread": "5/28/18", "Milk": "5/25/18", "Beef": "3/12/18", "Chicken": "11/11/17"]
        let tags = ["Carbs", "Dairy", "Meat", "Meat"]
        let tables = ["Items", "History"]
        database.insertList(listDetail: ListDetail(ID: 0, name: "Test List"))
        for table in tables {
            for (item, date) in items {
                database.insertItem(item: Item(ID: 0, listId: 1, quantity: 2, price: 2.50, name: item, datePurchased: date,
                                               tags: tags[counter]), table: table)
                counter += 1
            }
            counter = 0
        }
    }
    
    func dropTables() {
        database.dropTable(tableName: "Lists")
        database.dropTable(tableName: "Items")
        database.dropTable(tableName: "History")
        database.dropTable(tableName: "Recent")
    }
    
    func createTables() {
        database.createTable(tableName: "Lists")
        database.createTable(tableName: "Items")
        database.createTable(tableName: "History")
        database.createTable(tableName: "Recent")
    }
    
    func refreshList() {
        lists = database.selectAllLists()
        listsTableView.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return lists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListsTableViewCell", for: indexPath)
        
        let list = lists[indexPath.row]
        
        if let listCell = cell as? ListsTableViewCell {
            listCell.titleLabel.text = list.name
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let selectedList = lists[indexPath.row]
            
            database.deleteList(listId: selectedList.ID)
            
            lists = database.selectAllLists()
            
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } 
    }
}

extension ListsViewController: PopUpDelegate {
    func popupValueEntered() {
        refreshList()
    }

    
}
