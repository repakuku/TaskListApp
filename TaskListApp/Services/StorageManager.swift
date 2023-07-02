//
//  StorageManager.swift
//  TaskListApp
//
//  Created by Алексей Турулин on 6/29/23.
//

import Foundation
import CoreData

final class StorageManager {
    static let shared = StorageManager()
    
    var persistentContainer: NSPersistentContainer = {
    
        let container = NSPersistentContainer(name: "TaskListApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    let context: NSManagedObjectContext
    
    private init() {
        context = persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print(error)
            }
        }
    }
    
    func fetchData(_ completion: (Result<[Task], Error>) -> Void) {
        let fetchRequest = Task.fetchRequest()
        var taskList: [Task] = []
        
        do {
            taskList = try context.fetch(fetchRequest)
            completion(.success(taskList))
        } catch {
            completion(.failure(error))
        }
    }
    
    func save(_ taskName: String, _ completion: (Task) -> Void) {
        let task = Task(context: context)
        task.title = taskName
        saveContext()
        completion(task)
    }
    
    func update(_ task: Task, with title: String) {
        task.title = title
        saveContext()
    }
    
    func delete(_ task: Task) {
        context.delete(task)
        saveContext()
    }
    
}
