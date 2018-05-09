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
    
    func createTable (tableDetail: String) {
        
        let createTableQuery = """
                CREATE TABLE \(tableDetail);
            """

        var createTableStatement: OpaquePointer? = nil
        if (sqlite3_prepare_v2(db, createTableQuery, -1, &createTableStatement, nil) == SQLITE_OK) {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Lists table created.")
            }
            else {
                print("Lists table could not be created.")
                printCurrentSQLErrorMessage(db)
            }
        }
        else {
            print("CREATE TABLE statement could not be prepared.")
            printCurrentSQLErrorMessage(db)
        }
        
        sqlite3_finalize(createTableStatement)
    }

    func dropTable (tableName: String) {

        let dropTableQuery = "DROP TABLE \(tableName)"
        var dropTableStatement: OpaquePointer? = nil
        if (sqlite3_prepare_v2(db, dropTableQuery, -1, &dropTableStatement, nil) == SQLITE_OK) {
            if sqlite3_step(dropTableStatement) == SQLITE_DONE {
                print("\(tableName) table dropped.")
            }
            else {
                print("\(tableName) table could not be dropped.")
                printCurrentSQLErrorMessage(db)
            }
        }
        else {
            print("DROP TABLE statement could not be prepared.")
            printCurrentSQLErrorMessage(db)
        }

        sqlite3_finalize(dropTableStatement)
    }
//
    func insert(listDetail: ListDetail) {

        let insertStatementQuery = "INSERT INTO Lists (ID, Name) VALUES (?, ?);"

        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementQuery, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_null(insertStatement, 1)
            sqlite3_bind_text(insertStatement, 2, listDetail.name, -1, nil)
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            }
            else {
                print("Could not insert row.")
                printCurrentSQLErrorMessage(db)
            }
        }
        else {
            print("INSERT statement could not be prepared.")
            printCurrentSQLErrorMessage(db)
        }

        sqlite3_finalize(insertStatement)
    }
   
    func insertItem(item: Item) {
        
        let insertStatementQuery = "INSERT INTO Items (ID, ListId, Quantity, Price, Name, DatePurchased) VALUES (?, ?, ?, ?, ?, ?);"
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementQuery, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_null(insertStatement, 1)
            sqlite3_bind_int(insertStatement, 2, item.listId)
            sqlite3_bind_int(insertStatement, 3, item.quantity)
            sqlite3_bind_int(insertStatement, 4, item.price)
            sqlite3_bind_text(insertStatement, 5, item.name.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 6, item.datePurchased.utf8String, -1, nil)
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            }
            else {
                print("Could not insert row.")
                printCurrentSQLErrorMessage(db)
            }
        }
        else {
            print("INSERT statement could not be prepared.")
            printCurrentSQLErrorMessage(db)
        }
        
        sqlite3_finalize(insertStatement)
    }
    
    
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
    
    func selectAllItems(listId: Int32) -> [Item] {
        var result = [Item]()
        
        let selectStatementQuery = "SELECT id, listId, quantity, price, name, datePurchased FROM Items WHERE listId=\(listId)"
        
        var selectStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, selectStatementQuery, -1, &selectStatement, nil) == SQLITE_OK {
            while sqlite3_step(selectStatement) == SQLITE_ROW {
                let item = Item (
                    ID: sqlite3_column_int(selectStatement, 0),
                    listId: sqlite3_column_int(selectStatement, 1),
                    quantity: sqlite3_column_int(selectStatement, 2),
                    price: sqlite3_column_int(selectStatement, 3),
                    name: String (cString:sqlite3_column_text(selectStatement, 4)) as NSString,
                    datePurchased: String (cString:sqlite3_column_text(selectStatement, 5)) as NSString
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
