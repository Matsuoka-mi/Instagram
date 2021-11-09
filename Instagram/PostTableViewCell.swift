//
//  PostTableViewCell.swift
//  Instagram
//
//  Created by book mac on 2021/11/07.
//

import UIKit

//FirebaseUIのStorage用ライブラリをインポート　UIImageViewクラスのプロパティ、メソッドが使える
import FirebaseStorageUI
import Firebase
import SVProgressHUD



class PostTableViewCell: UITableViewCell {
    
   
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    
//--------------------------------------
    //課題　コメント
    @IBOutlet weak var komentLabel: UILabel!
    
    @IBOutlet weak var komenttextField: UITextField!
    
    
    @IBAction func toukou(_ sender: Any) {
        //投稿処理は３ステップ
                //  lesson8 chapter8.3投稿は１:画像をファイルとして保存するためにJPEG形式データに変換
                //  JPEG形式のデータを画像ファイルとしてCloud Storageにアップロードする
        //  投稿データ（投稿者名、キャプション、投稿日時等）をCloud Firestoreに保存する
          
          //画像をJPEG形式に変換する
          //数字は圧縮率。数字が小さいほど圧縮率は高く、荒くデータサイズは小さくなる。
       //   let imageData = image.jpegData(compressionQuality: 0.75)
          
          //画像と投稿データの保存場所を定義
          //postRefでFirestoreに保存する投稿データの保存場所を定義
          //Const.swift で定義したPostPathをcollection(_:)メソッドの引数に指定することでFireStoreのpostsフォルダに新しい投稿データを保存するよう指定
          let postRef = Firestore.firestore().collection(Const.PostPath).document()
          
          //imageRecはStorageに保存する画像の保存場所の定義
          //Const.swiftで定義したImagePathをchild(_:)メソッドの引数に指定し、さらにどの投稿に対応する画像か紐づけるために、.child(postRef.documentID + ".jpg")を指定することで投稿データのdocumentIDを画像のファイル名に利用
       //   let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postRef.documentID + ".jpg")
          
          //HUDで投稿処理中の表示を開始
          SVProgressHUD.show()
          
          //Storageに画像をアップロードする
     //    let metadata = StorageMetadata()
          
          //metadataは画像を保存する際のファイル形式を表す。image/jpegでJPEG画像で保存
     //     metadata.contentType = "image/jpeg"
          
          //putData(_:metadata:completion:)メソッドで画像をStorageにアップロード
          //putData(_:metadata:completion:)メソッドは画像のアップロードが完了すると呼び出してもらえるクロージャを最終引数に指定している。
          
       //  imageRef.putData(imageData!, metadata: metadata) { (metadata, error) in
              
              //error にはアップロードが成功したか否かの情報が入っている
              //成功した場合、nil. 失敗したらエラー情報が引数に入る
        //      if error != nil {
                  //画像のアップロード失敗
        //          print(error!)
        //          SVProgressHUD.showError(withStatus: "画像のアップロードが失敗しました")
                  //投稿処理をキャンセルし、先頭画面に戻る
                  //PostViewControllerから先頭画面へは複数画面を一度に戻る必要がある。下記コードで一度に戻れる
         //         UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
         //         return
                  
         //     }
              
              //FireStoreに投稿データを保存
              //保存するデータを辞書の形にまとめて、setData(_:)メソッドを実行することでFireStoreにデータを保存
              let komentname = Auth.auth().currentUser?.displayName
              let postDic = [
                  "komentname": komentname!,
                  "koment": self.komenttextField.text!,
               
                  //保存日時はFieldValue.serverTimestamp()で指定。
               //   "date": FieldValue.serverTimestamp(),
                 ] as [String : Any]
              postRef.setData(postDic)
              
              //HUDで投稿完了を表示
              SVProgressHUD.showSuccess(withStatus: "投稿しました")
              
              //投稿処理が完了したので先頭画面に戻る
              UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
        
        
              
          }
          
      
        
   
    
    //-----------------------------------------
    
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //postDataの内容をセルに表示
    func setPostData(_ postData: PostData) {
        //画像の表示
        //sd_imageIndicatorプロパティはCloud Storageから画像をダウンロードしている間、ダウンロード虫であることを示すインジケーターを表示する指定。グレーのクルクル回るアイコンを指定している。
        
        postImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        
        //sd_setImage(with:)メソッドの引数にCloud Strageの画像保存場所を指定するだけで画像をダウンロードし、UIImageViewに表示してくれる
        postImageView.sd_setImage(with: imageRef)
        
        //キャプションの表示　「投稿者名：キャプション情報」一つの文字列にして表示
        self.captionLabel.text = "\(postData.name!) : \(postData.caption!)"
        
        //課題---------------------------
        self.komentLabel.text = "\(postData.komentname!) : \(postData.koment!)"
        //課題---------------------------
        
        
        
        
        //日時の表示　Dateクラスに入っている日時情報をDateFormatterで文字列に変換する必要。
        //dateFormatプロパティに"yyyy-MM-dd HH:mm"　で　2019-09-12 09:41 と文字列へ変換
        self.dateLabel.text = ""
                if let date = postData.date {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
                    let dateString = formatter.string(from: date)
                    self.dateLabel.text = dateString
                }
        
        //いいね数の表示　postData.likes にはいいねを押した人のuidの一覧が配列で格納されている。
        //countプロパティで取得した配列要素数がいいねを押した人の数。
        let likeNumber = postData.likes.count
        likeLabel.text = "\(likeNumber)"
        
        //いいねボタンの表示　UIButtonクラスのsetImage(_:for:)メソッドでボタンの画像を変更。
        //自分がいいね押している：赤いハート（like_exist)　それ以外は白抜き（like_none)
        if postData.isLiked {
                    let buttonImage = UIImage(named: "like_exist")
                    self.likeButton.setImage(buttonImage, for: .normal)
                } else {
                    let buttonImage = UIImage(named: "like_none")
                    self.likeButton.setImage(buttonImage, for: .normal)
                }
            }
        }
