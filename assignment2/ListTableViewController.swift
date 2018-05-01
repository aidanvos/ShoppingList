
import UIKit

class ListTableViewController: UITableViewController {
    
    var callBackFunc: (() -> ())?

    var homeButton = UIButton()
    
    var list = [Item]()
    
    var listDatabaseNumber = Int()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("List Detail ***")
        print(listDatabaseNumber)
        createHomeButton()
    }

    func createHomeButton() {
        homeButton = UIButton(frame: CGRect(origin: CGPoint(x: self.view.frame.width/2 - 25, y: self.view.frame.size.height - 100), size: CGSize(width: 50, height: 50)))
        homeButton.backgroundColor = UIColor.black
        homeButton.addTarget(self, action: #selector(self.homeButtonAction(_:)), for: .touchUpInside)
        self.view.addSubview(homeButton)
    }
    
    @objc func homeButtonAction (_: AnyObject) {
        print("Home")
        callBackFunc?()
        dismiss(animated: true, completion: nil)
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
        
        if let listCell = cell as? ListsTableViewCell {
            listCell.titleLabel.text = item.name
        }
        
        return cell
    }
}
