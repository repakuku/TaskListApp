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
    
    private init() {}
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print(error)
            }
        }
    }
    
    func fetchData() -> [Task] {
        let fetchRequest = Task.fetchRequest()
        var taskList: [Task] = []
        
        do {
            taskList = try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print(error)
        }
        
        return taskList
    }
    
    func save(_ taskName: String) {
        var taskList = fetchData()
        let task = Task(context: persistentContainer.viewContext)
        task.title = taskName
        taskList.append(task)
        saveContext()
    }
    
    func update(_ taskName: String, at index: Int) {
        let taskList = fetchData()
        taskList[index].title = taskName
        saveContext()
    }
    
    func move(at sourceIndex: Int, to destinationIndex: Int) {
        let taskList = fetchData()
        let tempTaskTitle = taskList[sourceIndex].title
        taskList[sourceIndex].title = taskList[destinationIndex].title
        taskList[destinationIndex].title = tempTaskTitle
        saveContext()
    }
    
    func delete(at index: Int) {
        var taskList = fetchData()
        let deletedTask = taskList.remove(at: index)
        persistentContainer.viewContext.delete(deletedTask)
        saveContext()
    }
    
}
