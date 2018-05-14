//
//  PopUpItemVC.swift
//  assignment2
//
//  Created by Alex Viney on 8/5/18.
//  Copyright © 2018 Alex Viney. All rights reserved.
//

import UIKit

class PopUpItemVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var itemNameField: UITextField!
    @IBOutlet weak var quantityField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    
    
    let database : SQLiteDataBase = SQLiteDataBase(databaseName: "MyDatabase")
    
    var delegate: PopUpItemDelegate?
    
    var listDetail : ListDetail?
    
    var quantity: Float32?
    var price: Float32?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemNameField.delegate = self
        quantityField.delegate = self
        priceField.delegate = self

    }
    
    
    @IBAction func closePopUp(_ sender: Any) {
        AddNewItem()
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("Ended Editing...")

    }

    func AddNewItem() {

        if (itemNameField.text == "") {
            return
        }
        
        quantity = quantityField.text! == "" ? 1 : Float(quantityField.text!)!
        price = priceField.text == "" ? 0 : Float(priceField.text!)!
        
        database.insertItem(item: Item(ID: 0, listId: (listDetail?.ID)!, quantity: quantity!, price: price!, name: itemNameField.text!, datePurchased: "20/05/2018"))
        
        delegate?.popupItemEntered()
        
    }
    
}
