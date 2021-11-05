//
//  TabBarController.swift
//  Instagram
//
//  Created by book mac on 2021/11/04.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // タブアイコンの色
        
        self.tabBar.tintColor = UIColor(red: 1.0, green: 0.44, blue: 0.11, alpha: 1)
        
        //タブバーの背景
        
        self.tabBar.barTintColor = UIColor(red: 0.96, green: 0.91, blue: 0.87, alpha: 1)
        
        //UITabBarControllerDelegateプロトコルのメソッドをこのクラスで処理する
        
        self.delegate = self
    }
    
    //タブバーのアイコンがタップされた時に呼ばれるdelegateメソッドを処理する
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        //切り替え先の画面がImageSelectViewControllerクラスかどうか判断することでカメラボタンが押されたかどうかを判定する
        if viewController is ImageSelectViewController{
            //ImageSelectViewControllerはタブ切り替えではなくモーダル画面遷移
            let imageSelectViewController = storyboard!.instantiateViewController(withIdentifier: "ImageSelect")
                present(imageSelectViewController, animated: true)
                return false //falseはタブ切り替えしない
        }else{
            //その他のViewControllerは通常のタブ切り替えを実施
            return true //trueはタブ切り替えを実施
        }
    }
}

    