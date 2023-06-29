//
//  ViewController.swift
//  TaskListApp
//
//  Created by Vasichko Anna on 29.06.2023.
//

import UIKit

final class TaskListViewController: UITableViewController {
    
    private let storageManager = StorageManager.shared
    private let viewContext = StorageManager.shared.persistentContainer.viewContext
    
    private let cellID = "task"
    private var taskList: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavigationBar()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        taskList = storageManager.fetchData()
    }
    
    @objc private func addNewTask() {
        showAlert(withTitle: "New Task", andMessage: "What would you like to do?")
    }
    
    private func save(_ taskName: String) {
        let task = Task(context: viewContext)
        task.title = taskName
        
        taskList.append(task)
        
        tableView.insertRows(
            at: [IndexPath(row: taskList.count - 1, section: 0)],
            with: .automatic
        )
        
        storageManager.saveContext()
    
        dismiss(animated: true)
    }
    
    private func update(_ taskName: String, at index: Int) {
        taskList[index].title = taskName
        
        tableView.reloadData()
        
        storageManager.saveContext()
        
        dismiss(animated: true)
    }
    
    private func move(at sourceIndex: Int, to destinationIndex: Int) {
        let tempTaskTitle = taskList[sourceIndex].title
        taskList[sourceIndex].title = taskList[destinationIndex].title
        taskList[destinationIndex].title = tempTaskTitle
        
        storageManager.saveContext()
    }
    
    private func showAlert(withTitle title: String, andMessage message: String, forSelectedTaskAt index: Int? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        var saveAction: UIAlertAction!
        
        if let index {
            saveAction = UIAlertAction(title: "Save Changes", style: .default) { [unowned self] _ in
                guard let taskName = alert.textFields?.first?.text, !taskName.isEmpty else { return }
                update(taskName, at: index)
            }
        } else {
            saveAction = UIAlertAction(title: "Save Task", style: .default) { [unowned self] _ in
                guard let taskName = alert.textFields?.first?.text, !taskName.isEmpty else { return }
                save(taskName)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        alert.addTextField { textField in
            textField.placeholder = "New Task"
        }
        
        if let index {
            alert.textFields?.first?.text = taskList[index].title
        }
        
        present(alert, animated: true)
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
        showAlert(withTitle: "Update Task", andMessage: "What yo want to do?", forSelectedTaskAt: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deletedTask = taskList.remove(at: indexPath.row)
            viewContext.delete(deletedTask)
            storageManager.saveContext()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        move(at: sourceIndexPath.row, to: destinationIndexPath.row)
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

