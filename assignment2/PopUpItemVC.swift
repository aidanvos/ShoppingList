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
    
    let database : SQLiteDataBase = SQLiteDataBase(databaseName: "MyDatabase")
    
    var delegate: PopUpItemDelegate?
    
    var listDetail : ListDetail?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemNameField.delegate = self

    }
    
    @IBAction func closePopUp(_ sender: Any) {
        AddNewItem()
        dismiss(animated: true, completion: nil)
    }

    func AddNewItem() {

        if (itemNameField.text == "") {
            return
        }
        database.insertItem(item: Item(ID: 0, listId: (listDetail?.ID)!, quantity: 2, price: 4, name: itemNameField.text as! NSString, datePurchased: "20/05/2018"))
        
        delegate?.popupItemEntered()
        
    }
    
}
