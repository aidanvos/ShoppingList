//
//  ListsTableViewController.swift
//  assignment2
//
//  Created by Alex Viney on 1/5/18.
//  Copyright © 2018 Alex Viney. All rights reserved.
//

import UIKit

class ListsTableViewController: UITableViewController {
    
    @IBOutlet var listsTableView: UITableView!
    
    let database : SQLiteDataBase = SQLiteDataBase(databaseName: "MyDatabase")
    
    var newListButton = UIButton()
    
    var lists = [ListDetail]()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        createButton()
        
        createTable()
        
        createItemsTable()
        
        refreshList()
    }
    
    func createButton() {
        newListButton = UIButton(frame: CGRect(origin: CGPoint(x: self.view.frame.width/2 - 50, y: self.view.frame.size.height - 125), size: CGSize(width: 100, height: 100)))
        newListButton.setBackgroundImage(UIImage(named: "Add"), for: UIControlState.normal)
        newListButton.addTarget(self, action: #selector(self.newListButtonAction(_:)), for: .touchUpInside)
        self.navigationController?.view.addSubview(newListButton)
    }
    
    @objc func newListButtonAction(_: AnyObject) {
        performSegue(withIdentifier: "toPopUpVCSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Segue!!")
        if segue.identifier == "toPopUpVCSegue" {
            let popup = segue.destination as! PopUpVC
            popup.delegate = self
        }
        if segue.identifier == "toListSegue" {
            print("To new List")
            //let newListView = segue.destination as! ListTableViewController
            
            guard let navVC = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            let listTableViewController = navVC.viewControllers.first as! ListTableViewController 
            
            guard let selectedListCell = sender as? ListsTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            guard let indexPath = tableView.indexPath(for: selectedListCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let selectedList = lists[indexPath.row]
            listTableViewController.listDetail = selectedList

//            listTableViewController.callBackFunc = callBackFunc
        }
    }
    
//    func callBackFunc() -> () {
//        print("Call back worked!")
//    }
    
    func createTable() {
        database.dropTable(tableName: "Lists")
        let tableDetail = """
            Lists (ID INTEGER PRIMARY KEY AUTOINCREMENT, Name CHAR(255))
            """
        database.createTable(tableDetail: tableDetail)
    }
    
    func createItemsTable() {
        database.dropTable(tableName: "Items")
        let tableDetail = """
            Items (ID INTEGER PRIMARY KEY AUTOINCREMENT, ListId INTEGER, Quantity INTEGER, Price INTEGER, Name CHAR(255), DatePurchased CHAR(255))
            """
        database.createTable(tableDetail: tableDetail)
    }
    
    func refreshList() {
        lists = database.selectAllLists()
        listsTableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return lists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListsTableViewCell", for: indexPath)
        
        let list = lists[indexPath.row]
        
        if let listCell = cell as? ListsTableViewCell {
            listCell.titleLabel.text = list.name
        }
        
        return cell
    }
}

extension ListsTableViewController: PopUpDelegate {
    func popupValueEntered() {
        refreshList()
    }
    
    
}
