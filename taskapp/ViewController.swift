//
//  ViewController.swift
//  taskapp
//
//  Created by 楡井謙一 on 2018/04/29.
//  Copyright © 2018年 knirei. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBarField: UISearchBar!
    
    let realm = try! Realm()
    
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBarField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }

    // 各セルの内容を返すメソッド
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
    
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
    
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
    
        return cell
    }
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let task = self.taskArray[indexPath.row]
            
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/----")
                    print(request)
                    print("----/")
                }
            }
        }
    }
    
    // サーチバーで検索された時の処理
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        
        taskArray = realm.objects(Task.self).filter("category == %@", searchBarField.text!)
        tableView.reloadData()
    }

    // サーチバーのキャンセルボタンが押された時の処理
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBarField.text! = ""
        view.endEditing(true)

        taskArray = realm.objects(Task.self)
        tableView.reloadData()
    }
    
    // segueで画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            task.date = Date()
            
            let taskArrayLocal = realm.objects(Task.self)
            if taskArrayLocal.count != 0 {
                task.id = taskArrayLocal.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
    }

    // 入力画面から戻ってきた時にTableViewを更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        taskArray = realm.objects(Task.self)
        tableView.reloadData()
    }
}

