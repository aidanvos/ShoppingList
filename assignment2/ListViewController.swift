
import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UISearchBarDelegate {
    
    let database : SQLiteDataBase = SQLiteDataBase(databaseName: "MyDatabase")
    
    var list = [Item]()
    
    var itemsToPurchase = [Item]()
    
    var listDetail : ListDetail?
    
    var selectedItem: Item?
    
    var delegate: PopUpDelegate?
    
    var filteredList = [Item]()
    
    var isSearching = false

    @IBOutlet var listTableView: UITableView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listTableView.delegate = self
        listTableView.dataSource = self
        searchBar.delegate = self
        
        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.showsCancelButton = true
        
        refreshList()
        titleField.delegate = self
        titleField.text = (listDetail?.name)!
    }
    
    @IBAction func homeButtonAction(_ sender: Any) {
        delegate?.popupValueEntered()
        dismiss(animated: true, completion: nil)
    }
    @IBAction func addButtonAction(_ sender: Any) {
        performSegue(withIdentifier: "toRecentItemsSegue", sender: self)
    }
    
    @IBAction func purchaseButtonAction(_ sender: Any) {
        addItemsToHistory()
    }
    
    func addNewItem() {
        selectedItem = nil
        performSegue(withIdentifier: "editItemSegue", sender: self)
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
            
            // Do I still need this?
            if ((selectedItem) != nil) {
                popup.item = selectedItem
                popup.tableName = "Items"
            }
        } else if segue.identifier == "toRecentItemsSegue" {
            let recentModal = segue.destination as! RecentItemsVC
            recentModal.listDetail = listDetail
            recentModal.delegate = self
        }
        
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            print("FilteredLISTCOUNT:  \(filteredList.count)")
            return filteredList.count
        }
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        var item: Item!
        if isSearching {
            item = filteredList[indexPath.row]
        } else {
            item = list[indexPath.row]
        }
        
        if let listCell = cell as? ListTableViewCell {
            listCell.titleLabel.text = item.name as String
            listCell.quantityLabel.text = String(item.quantity)
            listCell.priceLabel.text = String(item.price)
            let total = item.quantity * item.price
            listCell.totalLabel.text = String(format: "%.2f", total)
            listCell.checkButton.tag = indexPath.row
            listCell.checkButton.addTarget(self, action: #selector(self.checkCell(_:)), for: .touchUpInside)
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
    
    func showFilteredList() {
        isSearching = true
        
        for item in list {
            let itemTags = item.tags.components(separatedBy: ",")
            print("Tags: \(itemTags)")
            if itemTags.contains(searchBar.text!) {
                filteredList += [item]
            }
        }
        
        listTableView.reloadData()
    }
    
    func clearFilteredList() {
        filteredList.removeAll()
        isSearching = false
        view.endEditing(true)
        
        listTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" || searchText == nil {
            clearFilteredList()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != "" {
            showFilteredList()
        }
    }
    
    @IBAction func checkCell(_ sender: UIButton) {
       
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
            database.insertItem(item: Item(ID: 0, listId: item.listId, quantity: item.quantity, price: item.price, name: item.name, datePurchased: item.datePurchased,
                                           tags: item.tags), table: "History")
        }
    }
}
extension ListViewController: PopUpItemDelegate, RecentItemDelegate {
    
    
    func popupItemEntered() {
        refreshList()
    }
    
    func newItem(modal: RecentItemsVC) {
        modal.dismiss(animated: true, completion: nil)
        addNewItem()
    }
    
    func itemAdded() {
        refreshList()
    }
    
}
