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
            let result = try? self.context.execute(insertRequest) as? NSBatchInsertResult
            
            if let objectIDs = result?.result as? [NSManagedObjectID], !objectIDs.isEmpty {
                let save = [NSInsertedObjectsKey: objectIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: save, into: [CoreDataStack.shared.mainContext])
            }
            completion(nil)
        }
        
        
    }
    
    private func update(entry: Entry, with entryRep: EntryRepresentation) {
        entry.title = entryRep.title
        entry.bodyText = entryRep.bodyText
        entry.mood = entryRep.mood
        entry.timestamp = entryRep.timestamp?.timeIntervalSinceReferenceDate as! Double
        entry.identifier = entryRep.identifier
    }
    
    private func fetchSingleEntryFromPersistentStore(with identifier: String?, in context: NSManagedObjectContext) -> Entry? {
        
        guard let identifier = identifier else { return nil }
        
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
        
        var result: Entry? = nil
        do {
            result = try context.fetch(fetchRequest).first
        } catch {
            NSLog("Error fetching single entry: \(error)")
        }
        return result
    }
    
    private func fetchEntriesFromPersistentStore(with identifiers: [String], in context: NSManagedObjectContext) -> [Entry] {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiers)
        
        do {
            let entries = try context.fetch(fetchRequest)
            return entries
        } catch {
            NSLog("Error fetching entries: \(error)")
            return []
        }
    }
    
    let context: NSManagedObjectContext
}
