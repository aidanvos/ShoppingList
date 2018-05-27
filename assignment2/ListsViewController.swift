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

    override func viewDidLoad() {
        super.viewDidLoad()
        listsTableView.delegate = self
        listsTableView.dataSource = self
        
        createTables()
        
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
    
    func createTables() {
//        database.dropTable(tableName: "Lists")
//        database.dropTable(tableName: "Items")
//        database.dropTable(tableName: "History")
//        database.dropTable(tableName: "Recent")
        
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
            
        } else if editingStyle == .insert {
            // Not used in our example, but if you were adding a new row, this is where you would do it.
        }
    }
}

extension ListsViewController: PopUpDelegate {
    func popupValueEntered() {
        refreshList()
    }

    
}
