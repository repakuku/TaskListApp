//
//  ViewController.swift
//  TaskListApp
//
//  Created by Vasichko Anna on 29.06.2023.
//

import UIKit

final class TaskListViewController: UITableViewController {
    
    private let storageManager = StorageManager.shared
    
    private let cellID = "task"
    private var taskList: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavigationBar()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        fetchTaskList()
    }
    
    @objc private func addNewTask() {
        showAlert()
    }
    
    private func fetchTaskList() {
        storageManager.fetchData { result in
            switch result {
            case .success(let value):
                taskList = value
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func save(_ taskName: String, at index: Int) {
        storageManager.save(taskName, at: index) { task in
            taskList.append(task)
        }
        
        tableView.insertRows(
            at: [IndexPath(row: taskList.count - 1, section: 0)],
            with: .automatic
        )
    }
    
    private func update(_ task: Task, with title: String) {
        storageManager.update(task, with: title)
        let index = Int(task.index)

        tableView.reloadRows(
            at: [IndexPath(row: index, section: 0)],
            with: .automatic
        )
    }
    
    private func delete(_ task: Task, at indexPath: IndexPath) {
        storageManager.delete(task)

        taskList.remove(at: indexPath.row)
        
        tableView.deleteRows(
            at: [indexPath],
            with: .automatic
        )
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = taskList[indexPath.row]
        showAlert(for: task) {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = taskList[indexPath.row]
            delete(task, at: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let task = taskList[sourceIndexPath.row]
        storageManager.move(task, from: sourceIndexPath.row, to: destinationIndexPath.row, in: taskList)
    }
}

// MARK: - Setup UI
private extension TaskListViewController {
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = UIColor(named: "MainBlue")
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )

        navigationController?.navigationBar.tintColor = .white
    }
}

// MARK: - Alert Controller
extension TaskListViewController {
    
    private func showAlert(for task: Task? = nil, completion: (() -> Void)? = nil) {
        let alertFactory = AlertControllerFactory(
            userAction: task != nil ? .editTask : .newTask,
            taskTitle: task?.title)
        let alert = alertFactory.createAlert { [weak self] title in
            if let task, let completion {
                self?.storageManager.update(task, with: title)
                completion()
                return
            }
            
            self?.save(title, at: self?.taskList.count ?? 0)
        }
        
        present(alert, animated: true)
    }
}
