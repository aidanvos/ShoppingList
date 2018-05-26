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
    @IBOutlet weak var dateField: UITextField!
    
    
    let datePicker = UIDatePicker()
    
    let database : SQLiteDataBase = SQLiteDataBase(databaseName: "MyDatabase")
    
    var delegate: PopUpItemDelegate?
    
    var listDetail : ListDetail?
    
    var quantity: Float32?
    var price: Float32?
    var name: String?
    
    var item: Item?
    var tableName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemNameField.delegate = self
        quantityField.delegate = self
        priceField.delegate = self
        dateField.delegate = self
        
        createDatePicker()
        
        if ((item) != nil) {
            FillFields()
        } else {
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
    
    func createDatePicker() {
        
        datePicker.datePickerMode = .date
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: false)
        
        dateField.inputAccessoryView = toolbar
        
        dateField.inputView = datePicker
    }
    
    @objc func donePressed() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        dateField.text = dateFormatter.string(from: datePicker.date)
        
        self.view.endEditing(true)
    }
    
    func FillFields() {
        itemNameField.text = item!.name
        quantityField.text = String(item!.quantity)
        priceField.text = String(item!.price)
        dateField.text = item!.datePurchased
    }
    
    func AddNewItem () {
        database.insertItem(item: Item(ID: 0, listId: (listDetail?.ID)!, quantity: quantity!, price: price!, name: name!, datePurchased: dateField.text!), table: "Items")
    }

    func EditItem() {
        let listId: Int32
        listId = tableName == "History" ? 1 : (listDetail?.ID)!
        
        
        database.updateItem(item: Item(ID: item!.ID, listId: listId, quantity: quantity!, price: price!, name: name!, datePurchased: dateField.text!), table: tableName!)
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
        dateField.resignFirstResponder()
        
        return (true)
    }
    
}
