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
    
    var lists = [List]()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        createButton()
        
        setupDatabase()
        
        refreshList()
        
        print(lists)
    }
    
    func createButton() {
        let newListButton = UIButton(frame: CGRect(origin: CGPoint(x: self.view.frame.width/2 - 25, y: self.view.frame.size.height - 70), size: CGSize(width: 50, height: 50)))
        newListButton.backgroundColor = UIColor.black
        newListButton.addTarget(self, action: #selector(self.newListButtonAction(_:)), for: .touchUpInside)
        self.navigationController?.view.addSubview(newListButton)
    }
    
    @objc func newListButtonAction(_: AnyObject) {
        print("Button Tapped")
        performSegue(withIdentifier: "toPopUpVCSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPopUpVCSegue" {
            let popup = segue.destination as! PopUpVC
            popup.delegate = self
        }
    }
    
    func setupDatabase() {
        database.dropListsTable()
        database.createListsTable()
        
//        database.insert(list: List(ID: 0, name:"List 1"))
//        database.insert(list: List(ID: 1, name: "Dinner List"))

    }
    
    func refreshList() {
        lists = database.selectAllLists()
        listsTableView.reloadData()
        print(lists)
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
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        super.prepare(for: segue, sender: sender)
//
//        if segue.identifier == "ShowMovieDetailSegue" {
//            guard let detailViewController = segue.destination as? DetailViewController else {
//                fatalError("Unexpected destination: \(segue.destination)")
//            }
//
//            guard let selectedMovieCell = sender as? MovieUITableViewCell else {
//                fatalError("Unexpected sender: \(String(describing: sender))")
//            }
//            guard let indexPath = tableView.indexPath(for: selectedMovieCell) else {
//                fatalError("The selected cell is not being displayed by the table")
//            }
//            let selectedMovie = movies[indexPath.row]
//            detailViewController.movie = selectedMovie
//        }
//    }

}

extension ListsTableViewController: PopUpDelegate {
    func popupValueEntered(value: String) {
        refreshList()
        print(value);
    }
    
    
}
