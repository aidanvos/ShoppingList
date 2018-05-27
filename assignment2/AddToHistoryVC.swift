//
//  AddToHistoryVC.swift
//  assignment2
//
//  Created by Alex Viney on 28/5/18.
//  Copyright © 2018 Alex Viney. All rights reserved.
//

import UIKit

class AddToHistoryVC: UIViewController {
    
     var delegate: ToHistoryDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

       
    }

    @IBAction func closePopupAction(_ sender: Any) {
        delegate?.clearCheckMarks()
        self.dismiss(animated: true, completion: nil)
    }
    

}
