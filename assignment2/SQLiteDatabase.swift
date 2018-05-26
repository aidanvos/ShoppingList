import Foundation
import SQLite3

class SQLiteDataBase
{
    private var db: OpaquePointer?
    
    init (databaseName dbName: String) {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("\(dbName).sqlite")
        
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK {
            print("Successfully opened connection to database at \(fileURL.path)")
        }
        else {
            print("Unable to open database at \(fileURL.path)")
            printCurrentSQLErrorMessage (db)
        }
    }
    deinit {
        sqlite3_close(db)
    }
    
    func printCurrentSQLErrorMessage(_ db: OpaquePointer?) {
        let errorMessage = String.init(cString: sqlite3_errmsg(db))
        print("Error:\(errorMessage)")
    }
    
    // General Query
    
    func generalQuery (query: String, description: String, message: String) {
        var statement: OpaquePointer? = nil
        if (sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK) {
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("\(description) \(message)")
            } else {
                print("\(description) could not be \(message)")
                printCurrentSQLErrorMessage(db)
            }
        } else {
            print("\(description) statement could not be prepared")
            printCurrentSQLErrorMessage(db)
        }
        
        sqlite3_finalize(statement)
    }
    
    // Creating, dropping and inserting queries
    
    func createTable (tableName: String) {
        
        var query = ""
        
        switch tableName {
        case "Lists":
            query = """
            Lists (ID INTEGER PRIMARY KEY AUTOINCREMENT, Name CHAR(255))
            """
            break
        case "Items":
            query = """
            Items (ID INTEGER PRIMARY KEY AUTOINCREMENT, ListId INTEGER, Quantity INTEGER, Price INTEGER, Name CHAR(255), DatePurchased CHAR(255))
            """
            break
        case "History":
            query = """
            History (ID INTEGER PRIMARY KEY AUTOINCREMENT, ListId INTEGER, Quantity INTEGER, Price INTEGER, Name CHAR(255), DatePurchased CHAR(255))
            """
            break
        default:
            print("No Table Name given")
            break
        }
        
        let createTableQuery = """
                CREATE TABLE \(query);
            """
        
        generalQuery(query: createTableQuery, description: "\(tableName) table", message: "created")
    }

    func dropTable (tableName: String) {
        
        let dropTableQuery = "DROP TABLE \(tableName)"
        
        generalQuery(query: dropTableQuery, description: tableName, message: "dropped")
    }
    
    func deleteList (listId: Int32) {
        let deleteStatement = "DELETE FROM Lists WHERE id=\(listId);"
        
        generalQuery(query: deleteStatement, description: "List \(String(listId))", message: "deleted")
    }

    func insertList(listDetail: ListDetail) {

        let insertListQuery = "INSERT INTO Lists (ID, Name) VALUES (null, '\(listDetail.name)');"
        
        generalQuery(query: insertListQuery, description: listDetail.name, message: "inserted")
    }
   
    func insertItem(item: Item, table: String) {
        let insertItemQuery = "INSERT INTO \(table) (ID, ListId, Quantity, Price, Name, DatePurchased) VALUES (null, \(item.listId), \(item.quantity), \(item.price), '\(item.name)', '\(item.datePurchased)');"
        
        generalQuery(query: insertItemQuery, description: "Item \(item.name)", message: "inserted")
    }
    
    func updateItem(item: Item, table: String) {
        let updateItemQuery = "UPDATE \(table) SET Quantity = \(item.quantity), Price = \(item.price), Name = '\(item.name)', DatePurchased = '\(item.datePurchased)' WHERE id = \(item.ID);"
        
        generalQuery(query: updateItemQuery, description: "Item \(item.name)", message: "updated")
    }
    
    func deleteItem (itemId: Int32, table: String) {
        let deleteStatement = "DELETE FROM \(table) WHERE id=\(itemId);"
        
        generalQuery(query: deleteStatement, description: "Item \(String(itemId))", message: "deleted")
    }
    
    // Selecting queries
    
    func selectAllLists() -> [ListDetail] {
        var result = [ListDetail]()

        let selectStatementQuery = "SELECT id, name FROM Lists"

        var selectStatement: OpaquePointer? = nil

        if sqlite3_prepare_v2(db, selectStatementQuery, -1, &selectStatement, nil) == SQLITE_OK {
            while sqlite3_step(selectStatement) == SQLITE_ROW {
                let listDetail = ListDetail (
                    ID: sqlite3_column_int(selectStatement, 0),
                    name: String (cString:sqlite3_column_text(selectStatement, 1))
                )

                result += [listDetail]
            }
        }
        else {
            print("SELECT statement could not be prepared.")
            printCurrentSQLErrorMessage(db)
        }
        sqlite3_finalize(selectStatement)

        return result
    }
    
    func selectItems(listId: Int32) -> [Item] {
        var result = [Item]()
        
        let selectStatementQuery = "SELECT id, listId, quantity, price, name, datePurchased FROM Items WHERE listId=\(listId)"
        
        var selectStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, selectStatementQuery, -1, &selectStatement, nil) == SQLITE_OK {
            while sqlite3_step(selectStatement) == SQLITE_ROW {
                let item = Item (
                    ID: sqlite3_column_int(selectStatement, 0),
                    listId: sqlite3_column_int(selectStatement, 1),
                    quantity: Float32(sqlite3_column_double(selectStatement, 2)),
                    price: Float32(sqlite3_column_double(selectStatement, 3)),
                    name: String (cString:sqlite3_column_text(selectStatement, 4)),
                    datePurchased: String (cString:sqlite3_column_text(selectStatement, 5))
                    )
                result += [item]
            }
        }
        else {
            print("SELECT statement could not be prepared.")
            printCurrentSQLErrorMessage(db)
        }
        sqlite3_finalize(selectStatement)
        return result
    }
    
    func selectItemsFromHistory() -> [Item] {
        var result = [Item]()
        
        let selectStatementQuery = "SELECT id, listId, quantity, price, name, datePurchased FROM History"
        
        var selectStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, selectStatementQuery, -1, &selectStatement, nil) == SQLITE_OK {
            while sqlite3_step(selectStatement) == SQLITE_ROW {
                let item = Item (
                    ID: sqlite3_column_int(selectStatement, 0),
                    listId: sqlite3_column_int(selectStatement, 1),
                    quantity: Float32(sqlite3_column_double(selectStatement, 2)),
                    price: Float32(sqlite3_column_double(selectStatement, 3)),
                    name: String (cString:sqlite3_column_text(selectStatement, 4)),
                    datePurchased: String (cString:sqlite3_column_text(selectStatement, 5))
                )
                result += [item]
            }
        }
        else {
            print("SELECT statement could not be prepared.")
            printCurrentSQLErrorMessage(db)
        }
        sqlite3_finalize(selectStatement)
        return result
    }
}
