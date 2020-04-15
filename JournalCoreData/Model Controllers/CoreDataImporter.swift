//
//  CoreDataImporter.swift
//  JournalCoreData
//
//  Created by Andrew R Madsen on 9/10/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataImporter {
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func sync(entryDicts: [[String: Any]], completion: @escaping (Error?) -> Void = { _ in }) {
        
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        self.context.perform {
            let insertRequest = NSBatchInsertRequest(entity: Entry.entity(), objects: entryDicts)
            insertRequest.resultType = NSBatchInsertRequestResultType.objectIDs
            
            do {
                let result = try self.context.execute(insertRequest) as? NSBatchInsertResult
                
                if let objectIDs = result?.result as? [NSManagedObjectID], !objectIDs.isEmpty {
                    let save = [NSInsertedObjectsKey: objectIDs]
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: save, into: [CoreDataStack.shared.mainContext])
                }
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    let context: NSManagedObjectContext
}
