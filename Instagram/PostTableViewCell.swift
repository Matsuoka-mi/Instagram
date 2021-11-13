
//
//  PostTableViewCell.swift
//  Instagram
//
//  Created by book mac on 2021/11/07.
//

import UIKit
import SVProgressHUD

//FirebaseUIのStorage用ライブラリをインポート　UIImageViewクラスのプロパティ、メソッドが使える
import FirebaseStorageUI
//import Firebase
//import SVProgressHUD



class PostTableViewCell: UITableViewCell {
    
   
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    
 //課題-----------------------------------------------
    @IBOutlet weak var komentButton: UIButton!
    
    @IBOutlet weak var koment: UITextField!
    
    
    @IBOutlet weak var komentLabel: UILabel!
    
    
//課題-----------------------------------------------
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
        
       //課題-------------------------------
       
        
        var comments = ""
        for comment in postData.koment {
            comments += "\(comment)\n"
        }
        
        self.komentLabel.text = comments
        
        
       //課題-------------------------------
        
        
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
        
       
        //課題---------------------------
        

     
        
       
        
        
  //      let komentnaiyou = postData.koment
 //      komentLabel.text = "\(String(describing: postData.komentname)) : \(postData.koment)"
  //      komentLabel.text = "\(komentnaiyou)"
         //課題---------------------------
      
        
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
