//
//  ViewController.swift
//  taskapp
//
//  Created by Chihiro Endo on 2017/11/25.
//  Copyright © 2017年 Chihiro Endo. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

// メモ: UISearchBarDelegateを追加する
// - UISarchBarの変更を受け取るメソッドを実装するには、このクラスをUISearchBarDelegateに対応させる必要があります
// - 対応させるには、UITableViewDataSourceなどと同様、クラスの定義部分にUISearchBarDelegateの記述を追加します

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate
{
    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // メモ: このViewControllerの実装のポイント
    // - 配列の検索結果は、直接 taskArray に上書きしてOKです
    // - taskArrayをフィルタした配列で上書きした後に、tableView.reloadData()することで、表示内容を更新します
    
    let realm = try! Realm()
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
    
    
    // メモ: １つのクラスに同じ名前のメソッドは１つだけ
    // - viewDidLoadやtableView:numberOfRowsInSection: が２つ定義されていたため、エラーが出ていました
    // - 同じ名前のメソッドはコードを入力しているときに、補完で名前が出ないので、最初はこれを目安にしましょう
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //デリゲート先を自分に設定する。
        SearchBar.delegate = self
        
        //何も入力されていなくてもReturnキーを押せるようにする。
        SearchBar.enablesReturnKeyAutomatically = false
    }
    
    // メモ: prepare と viewWillAppear を復帰しました
    // - prepare()では、次の画面に遷移する時にデータを渡しています
    // - viewWillAppearでは、次の画面から帰ってきた時にtableViewを更新しています
    // - それぞれ重要な処理をしているので、消さないようにしておきましょう
    // https://techacademy.jp/my/iphone/taskapp#chapter-6-8

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        // セルがクリックされたとき
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        }
        // 「 + 」ボタンがクリックされたとき
        else {
            let task = Task()
            task.date = NSDate()
            
            if taskArray.count != 0 {
                task.id = taskArray.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDataSourceプロトコルのメソッド
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date as Date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil)
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            // 削除されたタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
            }
            
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }
    
    // MARK: UISearchBarDelegateプロトコルのメソッド
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("searchText: \(searchText)")
        
        // メモ: 
        // 「searchTextに文字が入っているとき」は検索をして
        // 「searchTextが空になっているとき」は検索をやめて、全件表示するようにしてみましょう
        
        if !searchText.isEmpty {
             _ = NSPredicate(format: "category = %@", searchText);
            // searchTextに文字が入っているとき
            
            // ヒント:
            // NSPredicateを使った検索のコードを途中まで書いています。
            // 以下のコメントアウトされた４行を復帰してそのままだと、エラーがでるので、
            // predicateのformatの中に何を入れれば検索が実装できるかを考えてみましょう！
            

            let predicate = NSPredicate(format: "", searchText)
            taskArray = realm.objects(Task.self)
               .filter(predicate)
                .sorted(byKeyPath: "date", ascending: false)
        }
        else {
            _ = try! Realm()
            _ = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
            
            // searchTextが空になっているとき
            
            // ヒント:
            // elseに来た時には、検索されていない配列をtaskArrayに代入します
        }
        
        tableView.reloadData()
    }
    
}

