//
//  Created by Zsombor Szabo on 27/04/2020.
//  Copyright © 2020 Covid Watch. All rights reserved.
//

import Foundation
import CoreData
import os.log

extension PersistentContainer {
    // Fills the Core Data store with initial fake data
    // If onlyIfNeeded is true, only does so if the store is empty
    func loadInitialData(onlyIfNeeded: Bool = true) {
        let context = newBackgroundContext()
        context.perform {
            do {
                let allEntriesRequest: NSFetchRequest<NSFetchRequestResult> = ManagedExposureInfo.fetchRequest()
                if !onlyIfNeeded {
                    // Delete all data currently in the store
                    let deleteAllRequest = NSBatchDeleteRequest(fetchRequest: allEntriesRequest)
                    deleteAllRequest.resultType = .resultTypeObjectIDs
                    let result = try context.execute(deleteAllRequest) as? NSBatchDeleteResult
                    NSManagedObjectContext.mergeChanges(
                        fromRemoteContextSave: [NSDeletedObjectsKey: result?.result as Any],
                        into: [self.viewContext]
                    )
                }
                if try !onlyIfNeeded || context.count(for: allEntriesRequest) == 0 {
                    let now = Date()
                    let start = now - (14 * 24 * 60 * 60)
                    let end = now - (60 * 60)
                    
                    _ = generateFakeExposureInfos(from: start, to: end).map { ManagedExposureInfo(context: context, exposureInfo: $0) }
                    try context.save()
                }
            } catch {
                os_log("Loading initial data failed=%@", log: .app, error as CVarArg)                
            }
        }
    }
}
