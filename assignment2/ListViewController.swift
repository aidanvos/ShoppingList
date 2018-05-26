
import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    let database : SQLiteDataBase = SQLiteDataBase(databaseName: "MyDatabase")
    
    var list = [Item]()
    
    var itemsToPurchase = [Item]()
    
    var listDetail : ListDetail?
    
    var selectedItem: Item?
    
    var delegate: PopUpDelegate?

    @IBOutlet var listTableView: UITableView!
    @IBOutlet weak var titleField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listTableView.delegate = self
        listTableView.dataSource = self
        refreshList()
        titleField.delegate = self
        titleField.text = (listDetail?.name)!
    }
    @IBAction func homeButtonAction(_ sender: Any) {
        delegate?.popupValueEntered()
        dismiss(animated: true, completion: nil)
    }
    @IBAction func addButtonAction(_ sender: Any) {
        selectedItem = nil
        performSegue(withIdentifier: "editItemSegue", sender: self)
    }
    
    @IBAction func purchaseButtonAction(_ sender: Any) {
        addItemsToHistory()
    }
    
    func refreshList () {
        list = database.selectItems(listId: (listDetail?.ID)!)
        listTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editItemSegue" {
            let popup = segue.destination as! EditItemModalVC
            popup.listDetail = listDetail
            popup.delegate = self
            
            if ((selectedItem) != nil) {
                popup.item = selectedItem
                popup.tableName = "Items"
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        listDetail?.name = textField.text!
        database.updateList(listDetail: listDetail!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleField.resignFirstResponder()
        return (true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath)
        let item = list[indexPath.row]
        
        if let listCell = cell as? ListTableViewCell {
            listCell.titleLabel.text = item.name as String
            listCell.quantityLabel.text = String(item.quantity)
            listCell.priceLabel.text = String(item.price)
            let total = item.quantity * item.price
            listCell.totalLabel.text = String(format: "%.2f", total)
            
            listCell.checkButton.tag = indexPath.row
            listCell.checkButton.addTarget(self, action: #selector(ListViewController.checkCell(_:)), for: .touchUpInside)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let item = list[indexPath.row]
            
            database.deleteItem(itemId: item.ID, table: "Items")
            
            list = database.selectItems(listId: (listDetail?.ID)!)
            
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Not used in our example, but if you were adding a new row, this is where you would do it.
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedItem = list[indexPath.row]
        
        self.performSegue(withIdentifier: "editItemSegue", sender: self)
    }
    
    @IBAction func checkCell(_ sender: UIButton) {
       
//        if (itemsToPurchase.contains(where: { (item) -> Bool in
//            item.ID == list[sender.tag].ID
//        })) {
        if let index = itemsToPurchase.index(where: { (item) -> Bool in
            item.ID == list[sender.tag].ID
        }) {
            itemsToPurchase.remove(at: index)
            sender.setBackgroundImage(UIImage(named: "Add"), for: UIControlState.normal)
        } else {
            itemsToPurchase.append(list[sender.tag])
            sender.setBackgroundImage(UIImage(named: "Add"), for: UIControlState.normal)
        }

        listTableView.reloadData()
        
    }
    
    func addItemsToHistory () {
        
        for item in itemsToPurchase {
            database.insertItem(item: Item(ID: 0, listId: item.listId, quantity: item.quantity, price: item.price, name: item.name, datePurchased: item.datePurchased), table: "History")
        }
    }
}
extension ListViewController: PopUpItemDelegate {
    func popupItemEntered() {
        refreshList()
    }
}
