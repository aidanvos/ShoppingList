//
//  PopUpItemVC.swift
//  assignment2
//
//  Created by Alex Viney on 8/5/18.
//  Copyright © 2018 Alex Viney. All rights reserved.
//

import UIKit

class EditItemModalVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var itemNameField: UITextField!
    @IBOutlet weak var quantityField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    
    let database : SQLiteDataBase = SQLiteDataBase(databaseName: "MyDatabase")
    let dateFormatter = DateFormatter()
    
    var delegate: PopUpItemDelegate?
    var listDetail : ListDetail?
    
    var quantity = Float(0)
    var price = Float(0)
    var name = ""
    var currentDate = ""

    var item: Item?
    var tableName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTime()
        itemNameField.delegate = self
        quantityField.delegate = self
        priceField.delegate = self
        
        if ((item) != nil) {
            FillFields()
        } else {
        }
    }
    
    func setTime() {
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        let date = Date()
        currentDate = dateFormatter.string(from: date)
    }
    
    @IBAction func addItemToRecent(_ sender: Any) {
        if (itemNameField.text != "") {
            GetItemData()
            database.insertItem(item: Item(ID: 0, listId: 0, quantity: quantity, price: price, name: name, datePurchased: currentDate), table: "Recent")
        }
    }
    
    @IBAction func closePopUp(_ sender: Any) {
        //AddNewItem()
        // EditItem()
        if (itemNameField.text != "") {
            GetItemData()
            
            if ((item) != nil) {
                EditItem()
            } else {
                AddNewItem()
            }
        }
        delegate?.popupItemEntered()
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {

    }
    
    @objc func donePressed() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        
        self.view.endEditing(true)
    }
    
    func FillFields() {
        itemNameField.text = item!.name
        quantityField.text = String(item!.quantity)
        priceField.text = String(item!.price)
    }
    
    func AddNewItem () {
        database.insertItem(item: Item(ID: 0, listId: (listDetail?.ID)!, quantity: quantity, price: price, name: name, datePurchased: currentDate), table: "Items")
    }

    func EditItem() {
        let listId: Int32
        listId = tableName == "History" ? 1 : (listDetail?.ID)!
        
        
        database.updateItem(item: Item(ID: item!.ID, listId: listId, quantity: quantity, price: price, name: name, datePurchased: currentDate), table: tableName!)
    }
    
    func GetItemData() {
        
        quantity = quantityField.text! == "" ? 1 : Float(quantityField.text!)!
        price = priceField.text == "" ? 0 : Float(priceField.text!)!
        name = itemNameField.text!

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        itemNameField.resignFirstResponder()
        quantityField.resignFirstResponder()
        priceField.resignFirstResponder()
        
        return (true)
    }
    
}
