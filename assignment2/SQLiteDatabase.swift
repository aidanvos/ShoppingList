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
    
    func createListsTable () {
        
        let createTableQuery = """
                CREATE TABLE Lists (
                    ID INTEGER PRIMARY KEY NOT NULL,
                    Name CHAR(255)
                );
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

    func dropListsTable () {

        let dropTableQuery = "DROP TABLE Lists"
        var createTableStatement: OpaquePointer? = nil
        if (sqlite3_prepare_v2(db, dropTableQuery, -1, &createTableStatement, nil) == SQLITE_OK) {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Lists table dropped.")
            }
            else {
                print("Lists table could not be dropped.")
                printCurrentSQLErrorMessage(db)
            }
        }
        else {
            print("DROP TABLE statement could not be prepared.")
            printCurrentSQLErrorMessage(db)
        }

        sqlite3_finalize(createTableStatement)
    }
//
    func insert(list: List) {

        let insertStatementQuery = "INSERT INTO Lists (ID, Name) VALUES (?, ?);"

        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementQuery, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(insertStatement, 1, list.ID)
            sqlite3_bind_text(insertStatement, 2, list.name, -1, nil)
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
    
    func selectAllLists() -> [List] {
        var result = [List]()

        let selectStatementQuery = "SELECT id, name FROM Lists"

        var selectStatement: OpaquePointer? = nil

        if sqlite3_prepare_v2(db, selectStatementQuery, -1, &selectStatement, nil) == SQLITE_OK {
            while sqlite3_step(selectStatement) == SQLITE_ROW {
                let list = List (
                    ID: sqlite3_column_int(selectStatement, 0),
                    name: String (cString:sqlite3_column_text(selectStatement, 1))
                )

                result += [list]
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
