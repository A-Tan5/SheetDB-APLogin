//
//  InformationViewController.swift
//  SheetDB APLogin
//
//  Created by tantsunsin on 2020/8/21.
//

import UIKit

class InformationViewController: UIViewController, LoginDelegate {
    
    func update(Info: AccountPassword?) {
        LoginStatus = Info?.Login_Status?.bool ?? false
        userAP = Info!
        setOutlet()
        print("ＵＳＥＲＡＰ＝\(userAP)")
        
    }
    
    var LoginStatus = false
    var segueIsForLogin = false
    var userAP : AccountPassword?
    
    @IBOutlet weak var GreetingLabel: UILabel!
    @IBOutlet weak var LogInOutOutlet: UIButton!
    @IBOutlet weak var NewAcSetOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setOutlet()
        
    }
    
    
    func setOutlet() {
        LogInOutOutlet.setTitle(LoginStatus ? "登出" : "登入", for: .normal)
        NewAcSetOutlet.setTitle(LoginStatus ? "帳號設定" : "註冊新帳號", for: .normal)
        if LoginStatus {
            GreetingLabel.isHidden = false
            if let name = userAP?.Name{
                GreetingLabel.text = "你好！\(name)"
            }
        }else{
            GreetingLabel.isHidden = true
        }
    }
    

    @IBAction func LogInOutButton(_ sender: UIButton) {
        if LoginStatus{  // 登出
            let controller = UIAlertController(title: "登出", message: "確定要登出？", preferredStyle: .alert)
            let action = UIAlertAction(title: "確定登出", style: .destructive) { (UIAlertAction) in
                self.LoginStatus = false
                self.userAP?.Login_Status = "FALSE"
                let uploadAP = self.userAP!
                print("UPLOADAP = \(uploadAP)")
                let urlstr = APIUrlStr + "/Account/\(uploadAP.Account!)"
                print("URLSTRING = \(urlstr)")
                var request = URLRequest(url: URL(string: urlstr)!)
                request.httpMethod = "PUT"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let uploadData = AccPasUpload(data: [uploadAP])
                
                if let UploadData = try? JSONEncoder().encode(uploadData){
                
                    let task = URLSession.shared.uploadTask(with: request, from: UploadData) { (ReturnData, response, error) in
                        if let data = ReturnData, let responseData = try? JSONDecoder().decode([String:Int].self, from: data) {
                            if responseData["updated"] != nil{
                                print ("Cool")
                            }else{
                                print("ERROR!!")
                            }
                        }
                    }
                    task.resume()
                    print(uploadAP.Login_Status)
                }
                self.setOutlet()

            }
            let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            controller.addAction(action)
            controller.addAction(cancel)
            present(controller, animated: true, completion: nil)
        }else{  // 登入
            segueIsForLogin = true
            performSegue(withIdentifier: "LoginSegue", sender: self)
        }
    }
    
    
    @IBAction func NewAcSetButton(_ sender: Any) {
        if LoginStatus{  // 帳號設定
            performSegue(withIdentifier: "SettingSegue", sender: self)

        }else{ // 註冊新帳號
            segueIsForLogin = false
            performSegue(withIdentifier: "LoginSegue", sender: self)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as? LoginViewController
        
        controller?.delegate = self
        controller?.isForLogin = segueIsForLogin
        
        let SettingController = segue.destination as? AccountSettingViewController
        SettingController?.userAP = self.userAP
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
