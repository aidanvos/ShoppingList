//
//  RecentItemsVC.swift
//  assignment2
//
//  Created by Alex Viney on 26/5/18.
//  Copyright © 2018 Alex Viney. All rights reserved.
//

import UIKit

class RecentItemsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let database : SQLiteDataBase = SQLiteDataBase(databaseName: "MyDatabase")
    
    var listDetail: ListDetail?

    var delegate: RecentItemDelegate?
    
    var recentList = [Item]()
    
    var selectedItem: Item?
    
    @IBOutlet weak var recentTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recentTableView.dataSource = self
        recentTableView.delegate = self
        
        refresh()
    }

    @IBAction func newItemAction(_ sender: Any) {
        delegate?.newItem(modal: self)
    }
    
    @IBAction func closeModalAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func refresh() {
        recentList = database.selectAllItems(tableName: "Recent")
        recentTableView.reloadData()
    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "newItemSegue" {
//            let editItemModal = segue.destination as! EditItemModalVC
//            editItemModal.listDetail = listDetail
//        }
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentItemCell", for: indexPath)
        let reversedList = Array(recentList.reversed())
        if let itemCell = cell as? RecentItemsTVC {
            itemCell.titleLabel.text = reversedList[indexPath.row].name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let item = recentList[indexPath.row]
            
            database.deleteItem(itemId: item.ID, table: "Recent")
            
            recentList = database.selectAllItems(tableName: "Recent")
            
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } 
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedItem = recentList[indexPath.row]
        
        selectedItem?.listId = (listDetail?.ID)!
        database.insertItem(item: selectedItem!, table: "Items")

        delegate?.itemAdded()
        closeModalAction(self)
        
    }

}
