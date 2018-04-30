//
//  PopUpVC.swift
//  assignment2
//
//  Created by Alex Viney on 30/4/18.
//  Copyright © 2018 Alex Viney. All rights reserved.
//

import UIKit

class PopUpVC: UIViewController {

    @IBOutlet weak var listName: UITextField!
    
//    var newListName = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closePopUp(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "toPopUpVCSegue" {
//            let popup = segue.destination as! ListsViewController
//            popup.newListName = listName.text!
//        }
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
