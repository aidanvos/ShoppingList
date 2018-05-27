import Foundation

protocol PopUpDelegate {
    func popupValueEntered()
}

protocol PopUpItemDelegate {
    func popupItemEntered()
}

protocol ListViewDelegate {
    func popupValueEntered()
}

protocol RecentItemDelegate {
    func newItem(modal: RecentItemsVC)
    func itemAdded()
}

