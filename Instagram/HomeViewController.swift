//
//  HomeViewController.swift
//  Instagram
//
//  Created by book mac on 2021/11/03.
//

import UIKit
import Firebase
//import Firebase
import SVProgressHUD

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    //投稿データを格納する配列
    var postArray: [PostData] = []
    
    //課題------
    var postKomentArray: [PostData] = []
    
    
    //Firestoreのリスナー Firestoreのデータ更新の監視を行うためのリスナー
    var listener: ListenerRegistration?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
    
    tableView.delegate = self
    tableView.dataSource = self
    
    //カスタムセルを登録する カスタムセルをCell等Identifierで登録
    //カスタムセルの登録はUINib(nibName:bundle)を使いxibファイルを読み込み、register(_:forCellReuseIdentifier:)メソッドで登録
    let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: "Cell")
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
        //ログイン済みか確認　ログイン済みの時のみ投稿データの読み込み（監視）を開始
        if Auth.auth().currentUser != nil {
            //listenerを登録して投稿データの更新を監視する
            //投稿データ読み込みのためにデータベースの参照場所と取得順序を指定したクエリを作成。
            //↓これでFirestoreのpostsフォルダに格納されているデータを投稿日時の新しい順に取得するクエリを作成。
            let postsRef = Firestore.firestore().collection(Const.PostPath).order(by: "date" , descending: true)
            
            //このpostRefで取得する投稿データをaddSnapshotListenerメソッドで監視
            //addSnapshotListenerメソッドに指定したクロージャは投稿データの追加更新のたびに呼び出される。
            listener = postsRef.addSnapshotListener() { (querySnapshot, error) in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                    return
                }
                //取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                //クロージャの引数のquerySnapshotに最新のデータが入っている。そのdocumentsプロパティにドキュメント（QueryDocumentsSnapshot）の一覧が配列の形で入っている。
                //この配列をPostData（投稿データ）の配列に変換しpostArrayに格納。
                
                //mapメソッドは配列の要素を変換して新しい配列を作成するメソッド。
                //mapメソッドのクロージャの引数（document)で変換元の配列要素を受け取り、変換した要素をクロージャの戻り値（return postData)で返却することで配列を変換できる。
                
                self.postArray = querySnapshot!.documents.map { document in
                    print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let postData = PostData(document: document)
                    return postData
                    
                }
                
                //課題----------
                 self.postKomentArray = querySnapshot!.documents.map { document in
                      print("DEBUG_PRINT: koment取得 \(document.documentID)")
                    let postDatakoment = PostData(document: document)
                    return postDatakoment
            }
                
                //最新のデータを元にしたpostArrayが作成できたらtableViewをreloadData()
                //TableViewの表示を更新する
                self.tableView.reloadData()
                
            }
        }
        
    }
    
    
    //viewWillDisappear(_:)メソッドはホーム画面が閉じられるときに呼ばれる。リスナーに対しremove()メソッドを実行することで監視を停止。
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillDisappear")
        //listenerを削除して監視を停止する
        listener?.remove()
    }
    
    //テーブル表示のための必須delegateメソッド
    //tableView(_:numberOfRpwsInSection:) とtableView(_:cellForRowAt)を実装
    //tableView(_:numberOfRpwsInSection:)はpostArrayの配列の要素数を返す
    //tableView(_:cellForRowAt)はdequeueReusableCell(withIdentifier:for:)メソッドを使ってセルを取得し、setPostDataメソッドを呼び出してindexPathに対応するPostDataをセルへ表示する
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
        return postKomentArray.count
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postArray[indexPath.row])
        
        //セル内のボタンのアクションをソースコードで設定する
        //addTarget(_:action:for:)メソッドが青い線でActionを設定する代わりになる
        //第一引数self でHomeViewControllerを呼び出し対象。第二引数action　の#selectorで指定したメソッドが呼び出すメソッドになる
        
        //handleButtonがメソッド名。第一引数は略（タップされたUIButtonのインスタンスが格納）、第二引数の外部引数名はforEvent(UIEvent型のタップイベントが格納）
        //タップイベントの中にはボタンタップ時の画面上の座標位置などが格納されている。
        cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
        
        cell.komentButton.addTarget(self, action:#selector(komenttoukouButton(_:forEvent:)), for: .touchUpInside)
        
        return cell
    }
    
    
 
    
//セル内のボタンがタップされた時に呼ばれるメソッド
    //第二引数のUIEvent型のevent引数からUITouch型のタッチ情報を取り出す
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")
        
        //タップされたセルのインデックスを求める
        //location(in:)メソッドでタッチした座標を割り出す
        //indexPathForRow(at:)メソッドでタッチした座標がtableView内のどのindexPath位置になるのか取得。
        
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        //配列からタップされたインデックスのデータを取り出す
        //取得したindexPathを使って、postArray[indexPath!.row]でタップしたセルの投稿データ(postData)を取得できる
        let postData = postArray[indexPath!.row]
        
        //Firestoreに格納されているlikesの配列データを更新する
        if let myid = Auth.auth().currentUser?.uid {
            //更新データを作成する
            
            //postData.isLikedがtrueならすでにいいねボタンを押している。
            var updateValue: FieldValue
            if postData.isLiked {
                //すでにいいねしてる場合は、いいね解除のためmyidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([myid])
                
            } else {
                //今回新たにいいねを押した場合は、myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([myid])
            }
            
            //likesに更新データを書き込む
            //document(postData.id)でFirestoreの書き込み場所(postRef)を対象の投稿に設定し、updateData(_:)メソッドでlikes配列を更新する
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
            postRef.updateData(["likes": updateValue])
            
            //Firestoreのlikes配列を更新するとaddSnapshotListenerで監視しているリスナーが投稿データの更新を検出してクロージャを呼び出すため、テーブル表示は自動的に最新になる
        }
        
      
        
    }
    
   


    //課題-----------------------------------------------
    
    //セル内のボタンがタップされた時に呼ばれるメソッド
        //第二引数のUIEvent型のevent引数からUITouch型のタッチ情報を取り出す
    @objc func komenttoukouButton(_ sender: UIButton, forEvent event: UIEvent) {
        
              let postRef = Firestore.firestore().collection(Const.PostPath).document()
                 
                 //HUDで投稿処理中の表示を開始
                 SVProgressHUD.show()
                 
             
                    
                     let komentname = Auth.auth().currentUser?.displayName
                  
        
                     let postDic = [
                         "komentname": komentname!,
                    
                      
                        
                        ] as [String : Any]
                     postRef.setData(postDic)
                     
                     //HUDで投稿完了を表示
                     SVProgressHUD.showSuccess(withStatus: "投稿しました")
                     
                     //投稿処理が完了したので先頭画面に戻る
                     UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
               

        
    }
}
