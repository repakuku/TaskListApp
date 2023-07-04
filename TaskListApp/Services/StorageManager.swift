//
//  StorageManager.swift
//  TaskListApp
//
//  Created by Алексей Турулин on 6/29/23.
//

import CoreData

final class StorageManager {
    static let shared = StorageManager()
    
    private let persistentContainer: NSPersistentContainer = {
    
        let container = NSPersistentContainer(name: "TaskListApp")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    private let context: NSManagedObjectContext
    
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
        let sortDescriptor = NSSortDescriptor(key: "index", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let taskList = try context.fetch(fetchRequest)
            completion(.success(taskList))
        } catch {
            completion(.failure(error))
        }
    }
    
    func save(_ taskName: String, at index: Int, _ completion: (Task) -> Void) {
        let task = Task(context: context)
        task.title = taskName
        task.index = Int64(index)
        completion(task)
        saveContext()
    }
    
    func update(_ task: Task, with title: String) {
        task.title = title
        saveContext()
    }
    
    func delete(_ task: Task) {
        context.delete(task)
        saveContext()
    }
    
    func move(_ task: Task, from sourceIndex: Int, to destinationIndex: Int) {
        var taskList: [Task] = []
        
        fetchData() { result in
            switch result {
            case .success(let data):
                taskList = data
            case .failure(let error):
                print(error)
            }
        }
        
        task.index = Int64(destinationIndex)
        
        if sourceIndex > destinationIndex {
            for index in destinationIndex..<sourceIndex {
                taskList[index].index += 1
            }
        } else if destinationIndex > sourceIndex {
            for index in sourceIndex+1...destinationIndex {
                taskList[index].index -= 1
            }
        }
        
        saveContext()
    }
    
}
