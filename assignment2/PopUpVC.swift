//
//  PopUpVC.swift
//  assignment2
//
//  Created by Alex Viney on 30/4/18.
//  Copyright © 2018 Alex Viney. All rights reserved.
//

import UIKit

class PopUpVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var listNameTextField: UITextField!
    
    let database : SQLiteDataBase = SQLiteDataBase(databaseName: "MyDatabase")
    
    var delegate: PopUpDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listNameTextField.delegate = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func closePopUp(_ sender: Any) {
        MakeNewList()
        dismiss(animated: true, completion: nil)
    }
    
    func MakeNewList() {
        
        if (listNameTextField.text == "") {
            return
        }
        database.insertList(listDetail: ListDetail(ID: 0, name: listNameTextField.text!))
        
        delegate?.popupValueEntered()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        listNameTextField.resignFirstResponder()
        
        return (true)
    }

}
