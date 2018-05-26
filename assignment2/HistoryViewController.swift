//
//  HistoryViewController.swift
//  assignment2
//
//  Created by Alex Viney on 14/5/18.
//  Copyright © 2018 Alex Viney. All rights reserved.
//

import UIKit
import EventKit

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    let database : SQLiteDataBase = SQLiteDataBase(databaseName: "MyDatabase")

    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var historyTableView: UITableView!
    
    let datePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    var selectedTextField: UITextField?
    
    var fromDate = Date()
    var toDate = Date()
    
    var tempData = [Item]()
    var historyList = [Item]()
    
    var selectedItem: Item?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        historyTableView.delegate = self
        historyTableView.dataSource = self
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        createDatePicker()
        setDefaultTimes()
        
        refreshList()
    }
    
    func calculateTotal(data: [Item]) {
        var total = Float()
        for item in data {
            let temp = item.quantity * item.price
            total += temp
        }
        totalLabel.text = String(total)
    }
    
    @IBAction func homeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func textFieldDidBeginEditing(_ textField: UITextField) {
        selectedTextField = textField
        let date = dateFormatter.date(from: (selectedTextField?.text!)!)
        datePicker.date = date!
    }
    
    func refreshList () {
        tempData = database.selectItemsFromHistory()
        historyList.removeAll()
        for item in tempData {
            let range = fromDate...toDate
            let current = dateFormatter.date(from: item.datePurchased)
            if (range.contains(current!)) {
                historyList += [item]
                
            }
        }
        calculateTotal(data: historyList)
        historyTableView.reloadData()
    }
    
    func createDatePicker() {
        
        datePicker.datePickerMode = .date
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: false)
        
        fromTextField.inputAccessoryView = toolbar
        toTextField.inputAccessoryView = toolbar
        
        fromTextField.inputView = datePicker
        toTextField.inputView = datePicker
    }
    
    func setDefaultTimes() {
        
        let currentDate = Date()
        var dateComponent = DateComponents()
        dateComponent.day = -7
        
        let pastDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
        
        fromDate = pastDate!
        toDate = currentDate
        fromTextField.text = dateFormatter.string(from: pastDate!)
        toTextField.text = dateFormatter.string(from: currentDate)
    }
    
    @objc func donePressed() {
        if (selectedTextField == fromTextField) {
            fromDate = datePicker.date
            fromTextField.text = dateFormatter.string(from: datePicker.date)
        } else {
            toDate = datePicker.date
            toTextField.text = dateFormatter.string(from: datePicker.date)
        }
        
        refreshList()

        self.view.endEditing(true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath)
        
        if let itemCell = cell as? HistoryTableViewCell {
            itemCell.itemLabel.text = historyList[indexPath.row].name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let item = historyList[indexPath.row]
            
            database.deleteItem(itemId: item.ID, table: "History")
            
            historyList = database.selectItemsFromHistory()
            
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Not used in our example, but if you were adding a new row, this is where you would do it.
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

        selectedItem = historyList[indexPath.row]
        
        self.performSegue(withIdentifier: "editHistoryItemSegue", sender: self)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editHistoryItemSegue" {
            let popup = segue.destination as! EditItemModalVC
            popup.item = selectedItem
            popup.tableName = "History"
            popup.delegate = self
        }
    }
}
extension HistoryViewController: PopUpItemDelegate {
    func popupItemEntered() {
        refreshList()
    }
}