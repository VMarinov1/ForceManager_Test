//
//  DatabaseManager.m
//  ForceManager_Test
//
//  Created by Vladimir Marinov on 17.05.16.
//  Copyright © 2016 Vladimir Marinov. All rights reserved.
//

#import "DatabaseManager.h"
#import "Constants.h"
#import <sqlite3.h>
#import "GeolocatedElement.h"
#import <CoreLocation/CoreLocation.h>

@interface DatabaseManager()

@property (nonatomic, strong) NSString *dbFileName;
@property (nonatomic, strong) NSString *dbDestinationPath;
@property (nonatomic, strong) NSMutableArray *arrResults;
@property (nonatomic, strong) NSMutableArray *arrColumnNames;
@property (nonatomic) int affectedRows;
@property (nonatomic) long long lastInsertedRowID;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

- (instancetype)initWithDatabaseFilename:(NSString*)dbName;
- (void)copyDatabaseIntoDocumentsDirectory;
- (void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable withMaping:(void(^)( sqlite3_stmt *pStmt))codeMaping;
- (void)executeQuery:(NSString *)query;
- (NSArray *)loadDataFromDB:(NSString *)query;
- (GeolocatedElement*)serializeElement:(NSArray*)item;
- (void)clearResultList;

@end


@implementation DatabaseManager

- (instancetype)initWithDatabaseFilename:(NSString*)dbName{
    if(self = [super init]){
        _dbFileName = dbName;
        _dateFormatter = [[NSDateFormatter alloc]init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
        [self copyDatabaseIntoDocumentsDirectory];
        return self;
    }
    return nil;
}
/*!
 * @discussion Clear list for the result
 */
- (void)clearResultList{
    if (self.arrResults != nil) {
        [self.arrResults removeAllObjects];
        self.arrResults = nil;
    }
    self.arrResults = [[NSMutableArray alloc] init];
    
    if (self.arrColumnNames != nil) {
        [self.arrColumnNames removeAllObjects];
        self.arrColumnNames = nil;
    }
    self.arrColumnNames = [[NSMutableArray alloc] init];
}
/*!
 * @discussion Run Query to database
 * @param query
 * @return queryExecutable should the Query execute
 * @param codeMaping Mapping block
 */
- (void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable withMaping:(void(^)( sqlite3_stmt *pStmt))codeMaping{
    [self clearResultList];
    sqlite3 *sqlite3Database;
    // Open the database.
    int openDatabaseResult = sqlite3_open([_dbDestinationPath UTF8String], &sqlite3Database);
    if(openDatabaseResult == SQLITE_OK) {
        sqlite3_stmt *compiledStatement;
        int prepareStatementResult = sqlite3_prepare_v2(sqlite3Database, query, -1, &compiledStatement, NULL);
        if(codeMaping != nil){
            codeMaping(compiledStatement);
        }
        if(prepareStatementResult == SQLITE_OK) {
            if (!queryExecutable){
                NSMutableArray *arrDataRow;
                // Loop through the results and add them to the results array row by row.
                while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                    arrDataRow = [[NSMutableArray alloc] init];
                    int totalColumns = sqlite3_column_count(compiledStatement);
                    for (int i = 0; i < totalColumns; i++){
                        char *dbDataAsChars = (char *)sqlite3_column_text(compiledStatement, i);
                        if (dbDataAsChars != NULL) {
                            [arrDataRow addObject:[NSString  stringWithUTF8String:dbDataAsChars]];
                        }
                        if (self.arrColumnNames.count != totalColumns) {
                            dbDataAsChars = (char *)sqlite3_column_name(compiledStatement, i);
                            [self.arrColumnNames addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                        }
                    }
                    if (arrDataRow.count > 0) {
                        [self.arrResults addObject:arrDataRow];
                    }
                }
            }
            else {
                int executeQueryResults = sqlite3_step(compiledStatement);
                if (executeQueryResults == SQLITE_DONE) {
                    self.affectedRows = sqlite3_changes(sqlite3Database);
                    self.lastInsertedRowID = sqlite3_last_insert_rowid(sqlite3Database);
                }
                else {
                    NSLog(@"DB Error: %s", sqlite3_errmsg(sqlite3Database));
                }
            }
        }
        else {
            NSLog(@"%s", sqlite3_errmsg(sqlite3Database));
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(sqlite3Database);
}
/*!
 * @discussion Update Element in DB
 * @param element Element to update
 * @return return result
 */
- (BOOL)updateElement:(GeolocatedElement*)element{
       NSString *query = @"UPDATE element set name = ?, creation_date = ?, description = ?, type = ?, distance_to_user = ?, longitude = ?, latitude = ? WHERE mId = ?" ;
    [self runQuery:[query UTF8String] isQueryExecutable:YES withMaping:^(sqlite3_stmt *ppStmt) {
        sqlite3_bind_text(ppStmt, 1, [element.name  UTF8String], -1, SQLITE_TRANSIENT);
        NSString *dateStr = [_dateFormatter stringFromDate:element.creationDate];
        sqlite3_bind_text(ppStmt, 2, [dateStr UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(ppStmt, 3, [element.textDescription UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(ppStmt, 4, [element.type UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(ppStmt, 5, element.distanceToUser);
        sqlite3_bind_double(ppStmt, 6, element.location.coordinate.longitude);
        sqlite3_bind_double(ppStmt, 7, element.location.coordinate.latitude);
        sqlite3_bind_int64(ppStmt, 8, element.mId);
    }];
    return self.affectedRows != 0;
}
/*!
 * @discussion Element to insert
 * @param element
 * @return last inserted id
 */
- (long long)insertElement:(GeolocatedElement *)element{
    NSString *query = @"INSERT INTO  element VALUES(null , ?, ?, ?, ?, ?, ?, ? )" ;
    [self runQuery:[query UTF8String] isQueryExecutable:YES withMaping:^(sqlite3_stmt *ppStmt) {
        sqlite3_bind_text(ppStmt, 1, [element.name  UTF8String], -1, SQLITE_TRANSIENT);
        NSString *dateStr = [_dateFormatter stringFromDate:element.creationDate];
        sqlite3_bind_text(ppStmt, 2, [dateStr UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(ppStmt, 3, [element.textDescription UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(ppStmt, 4, [element.type UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(ppStmt, 5, element.distanceToUser);
        sqlite3_bind_double(ppStmt, 6, element.location.coordinate.longitude);
        sqlite3_bind_double(ppStmt, 7, element.location.coordinate.latitude);
    }];

    if (self.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.affectedRows);
    }
    else{
        NSLog(@"Could not execute the query.");
    }
    return self.lastInsertedRowID;
}
/*!
 * @discussion Serialize Dictionary to Element object
 * @param dict dictionary
 * @return return Element
 */
- (GeolocatedElement*)serializeElement:(NSArray*)item{
    GeolocatedElement *result = [[GeolocatedElement alloc] init];
    result.mId = [[item objectAtIndex:0] longLongValue];
    result.name = [item objectAtIndex:1];
    result.creationDate = [_dateFormatter dateFromString:[item objectAtIndex:2]];
    result.textDescription = [item objectAtIndex:3];
    result.type = [item objectAtIndex:4];
    result.distanceToUser = [[item objectAtIndex:5] doubleValue];
    result.location = [[CLLocation alloc] initWithLatitude:[[item objectAtIndex:6] doubleValue] longitude:[[item objectAtIndex:7] doubleValue]];
    return result;
}
/*!
 * @discussion Load data from DB and parse it
 * @param query Query to Execute
 */
- (NSArray *)loadDataFromDB:(NSString *)query{
    [self runQuery:[query UTF8String] isQueryExecutable:NO withMaping:nil];
    return (NSArray *)self.arrResults;
}

/*!
 * @discussion Load all elements from database
 * @return return All elements in database
 */
- (NSArray<GeolocatedElement*>*)loadAllElements{
    NSMutableArray<GeolocatedElement*> *result = [[NSMutableArray alloc] init];
    // Form the query.
    NSString *query = @"SELECT * FROM element";
    NSArray *queryResut = [self loadDataFromDB:query];
    for(NSArray *itemDict in queryResut){
        GeolocatedElement* element = [self serializeElement:itemDict];
        [result addObject:element];
    }
    return result;
}
/*!
 * @discussion DELETE element from DB
 * @param element Element
 * @return return result of operation
 */
- (BOOL)deleteElement:(GeolocatedElement*)element{
    NSString *query = [NSString stringWithFormat:@"DELETE FROM element WHERE mId = %lld", element.mId];
    [self runQuery:[query UTF8String] isQueryExecutable:YES withMaping:nil];
    return self.affectedRows  > 0;
}

/*!
 * @discussion Check if the database file exists in the documents directory
 */
- (void)copyDatabaseIntoDocumentsDirectory{
    NSURL *documentDirectoryUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                            inDomains:NSUserDomainMask] lastObject];
    
    self.dbDestinationPath  = [documentDirectoryUrl.path stringByAppendingPathComponent:self.dbFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.dbDestinationPath]) {
        NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.dbFileName];
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:self.dbDestinationPath error:&error];
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
}
/*!
 * @discussion Return Singleton Instance from DB Manager
 * @return Singleton Instance from DB Manager
 */
+ (instancetype)DBInstance{
    static DatabaseManager *sharedInstace = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstace = [[DatabaseManager alloc] initWithDatabaseFilename:DATABASE_FILE_NAME];
    });
    return sharedInstace;
}
@end
