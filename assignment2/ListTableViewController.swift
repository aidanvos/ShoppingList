
import UIKit

class ListTableViewController: UITableViewController {
    
    let database : SQLiteDataBase = SQLiteDataBase(databaseName: "MyDatabase")
    
//    var callBackFunc: (() -> ())?

    var homeButton = UIButton()
    
    var addButton = UIButton()
    
    var list = [Item]()
    
    var listDetail : ListDetail?

    @IBOutlet var listTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createHomeButton()
        createAddButton()
        refreshList()
        self.navigationItem.title = "Edit \((listDetail?.name)!)"
    }

    func createHomeButton() {
        homeButton = UIButton(frame: CGRect(origin: CGPoint(x: 25, y: self.view.frame.size.height - 100), size: CGSize(width: 50, height: 50)))
        homeButton.setBackgroundImage(UIImage(named: "Home"), for: UIControlState.normal)
        homeButton.addTarget(self, action: #selector(self.homeButtonAction(_:)), for: .touchUpInside)
        self.navigationController?.view.addSubview(homeButton)
    }
    
    @objc func homeButtonAction (_: AnyObject) {
//        callBackFunc?()
        dismiss(animated: true, completion: nil)
    }
    
    func createAddButton() {
        addButton = UIButton(frame: CGRect(origin: CGPoint(x: self.view.frame.width/2 - 50, y: self.view.frame.size.height - 125), size: CGSize(width: 100, height: 100)))
        addButton.setBackgroundImage(UIImage(named: "Add"), for: UIControlState.normal)
        addButton.addTarget(self, action: #selector(self.addButtonAction(_:)), for: .touchUpInside)
        self.navigationController?.view.addSubview(addButton)
    }
    
    @objc func addButtonAction (_: AnyObject) {
        performSegue(withIdentifier: "toPopUpItemVCSegue", sender: self)
    }
    
    func refreshList () {
        list = database.selectAllItems(listId: (listDetail?.ID)!)
        print(list)
        listTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPopUpItemVCSegue" {
            let popup = segue.destination as! PopUpItemVC
            popup.listDetail = listDetail
            popup.delegate = self
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath)
        
        let item = list[indexPath.row]
        
        if let listCell = cell as? ListTableViewCell {
            listCell.titleLabel.text = item.name as String
        }
        
        return cell
    }
}

extension ListTableViewController: PopUpItemDelegate {
    func popupItemEntered() {
        refreshList()
    }
}
