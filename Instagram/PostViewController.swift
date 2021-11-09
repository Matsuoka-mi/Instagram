//
//  PostViewController.swift
//  Instagram
//
//  Created by book mac on 2021/11/03.
//

import UIKit
import Firebase
import SVProgressHUD

class PostViewController: UIViewController {
    var image:UIImage!
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    //投稿ボタンをタップした時に呼ばれるメソッド
    @IBAction func handlePostButton(_ sender: Any) {
      //投稿処理は３ステップ
      //  lesson8 chapter8.3投稿は１:画像をファイルとして保存するためにJPEG形式データに変換
      //  JPEG形式のデータを画像ファイルとしてCloud Storageにアップロードする
      //  投稿データ（投稿者名、キャプション、投稿日時等）をCloud Firestoreに保存する
        
        //画像をJPEG形式に変換する
        //数字は圧縮率。数字が小さいほど圧縮率は高く、荒くデータサイズは小さくなる。
        let imageData = image.jpegData(compressionQuality: 0.75)
        
        //画像と投稿データの保存場所を定義
        //postRefでFirestoreに保存する投稿データの保存場所を定義
        //Const.swift で定義したPostPathをcollection(_:)メソッドの引数に指定することでFireStoreのpostsフォルダに新しい投稿データを保存するよう指定
        let postRef = Firestore.firestore().collection(Const.PostPath).document()
        
        //imageRecはStorageに保存する画像の保存場所の定義
        //Const.swiftで定義したImagePathをchild(_:)メソッドの引数に指定し、さらにどの投稿に対応する画像か紐づけるために、.child(postRef.documentID + ".jpg")を指定することで投稿データのdocumentIDを画像のファイル名に利用
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postRef.documentID + ".jpg")
        
        //HUDで投稿処理中の表示を開始
        SVProgressHUD.show()
        
        //Storageに画像をアップロードする
        let metadata = StorageMetadata()
        
        //metadataは画像を保存する際のファイル形式を表す。image/jpegでJPEG画像で保存
        metadata.contentType = "image/jpeg"
        
        //putData(_:metadata:completion:)メソッドで画像をStorageにアップロード
        //putData(_:metadata:completion:)メソッドは画像のアップロードが完了すると呼び出してもらえるクロージャを最終引数に指定している。
        
        imageRef.putData(imageData!, metadata: metadata) { (metadata, error) in
            
            //error にはアップロードが成功したか否かの情報が入っている
            //成功した場合、nil. 失敗したらエラー情報が引数に入る
            if error != nil {
                //画像のアップロード失敗
                print(error!)
                SVProgressHUD.showError(withStatus: "画像のアップロードが失敗しました")
                //投稿処理をキャンセルし、先頭画面に戻る
                //PostViewControllerから先頭画面へは複数画面を一度に戻る必要がある。下記コードで一度に戻れる
                UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
                return
                
            }
            
            //FireStoreに投稿データを保存
            //保存するデータを辞書の形にまとめて、setData(_:)メソッドを実行することでFireStoreにデータを保存
            let name = Auth.auth().currentUser?.displayName
            let postDic = [
                "name": name!,
                "caption": self.textField.text!,
              
                //保存日時はFieldValue.serverTimestamp()で指定。
                "date": FieldValue.serverTimestamp(),
                ] as [String : Any]
            postRef.setData(postDic)
            
            //HUDで投稿完了を表示
            SVProgressHUD.showSuccess(withStatus: "投稿しました")
            
            //投稿処理が完了したので先頭画面に戻る
            UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
            
        }
        
    }
    
    //キャンセルボタンをタップした時に呼ばれるメソッド
    @IBAction func handleCancelButton(_ sender: Any) {
        
        //加工画面に戻る
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 受け取った画像をImageViewに設定する
        imageView.image = image
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
