//
//  ChangeAPViewController.swift
//  SheetDB APLogin
//
//  Created by tantsunsin on 2020/8/22.
//

import UIKit

class ChangeAPViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Configure()

        // Do any additional setup after loading the view.
    }
    var userAP : AccountPassword!
    var IsForAccount = true //改帳號或改密碼


    
    @IBOutlet weak var OldInfoOutlet: UITextField!
    @IBOutlet weak var NewInfoOutlet: UITextField!
    @IBOutlet weak var ReNewInfoOutlet: UITextField!
    
    @IBAction func OldInfoDismissKeyboard(_ sender: UITextField) {
    }
    @IBAction func NewInfoDismissKeyboard(_ sender: UITextField) {
    }
    @IBAction func ReNewInfoDismissKeyboard(_ sender: UITextField) {
    }
    
    
    func Configure(){
        OldInfoOutlet.placeholder = IsForAccount ? "舊帳號" : "舊密碼"
        NewInfoOutlet.placeholder = IsForAccount ? "新帳號" : "新密碼"
        ReNewInfoOutlet.isHidden = IsForAccount
    }
    
    @IBAction func donePressed(_ sender: UIButton) {
        if IsForAccount {
            //改帳號
            if NewInfoOutlet.text == OldInfoOutlet.text{
                createAlert(title: "帳號重複", message: "請重新輸入", actiontitle: "OK") { (UIAlertAction) in
                    self.OldInfoOutlet.text = ""
                    self.NewInfoOutlet.text = ""
                    self.ReNewInfoOutlet.text = ""
                }
            }else if OldInfoOutlet.text != userAP.Account{
                createAlert(title: "舊帳號輸入錯誤", message: "請重新輸入", actiontitle: "OK") { (UIAlertAction) in
                    self.OldInfoOutlet.text = ""
                    self.NewInfoOutlet.text = ""
                    self.ReNewInfoOutlet.text = ""
                }
            }else{
                createAlert(title: "更改成功！", message: "帳號已更改", actiontitle: "OK!") { (UIAlertAction) in
                    let urlstr = APIUrlStr + "/Account/\(self.userAP.Account!)"
                    var request = URLRequest(url: URL(string: urlstr)!)
                    request.httpMethod = "PUT"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    
                    self.userAP.Account = self.NewInfoOutlet.text
                    let uploadAP = AccPasUpload(data: [self.userAP])
                    
                    if let uploadData = try? JSONEncoder().encode(uploadAP){
                    
                        let task = URLSession.shared.uploadTask(with: request, from: uploadData) { (returndata, response, error) in
                            if let responsedata = returndata, let returndata = try? JSONDecoder().decode([String:Int].self, from: responsedata){
                                if returndata["updated"] != nil{
                                    print("upload seccessful!")
                                }else{
                                    print("ERROR!")
                                }
                            }
                        }
                        task.resume()
                    }
                    
                    //返回、傳值
                    let count = self.navigationController?.viewControllers.count
                    let controller = self.navigationController?.viewControllers[count! - 3] as? InformationViewController
                    controller?.userAP = self.userAP
                    if let controller = controller{
                        self.navigationController?.popToViewController(controller, animated: true)
                    }
                }
            }
        }else{
            //改密碼
            if NewInfoOutlet.text == OldInfoOutlet.text{
                createAlert(title: "密碼重複", message: "請重新輸入", actiontitle: "OK") { (UIAlertAction) in
                    self.OldInfoOutlet.text = ""
                    self.NewInfoOutlet.text = ""
                    self.ReNewInfoOutlet.text = ""
                }
            }else if OldInfoOutlet.text != userAP.Password{
                createAlert(title: "舊密碼輸入錯誤", message: "請重新輸入", actiontitle: "OK") { (UIAlertAction) in
                    self.OldInfoOutlet.text = ""
                    self.NewInfoOutlet.text = ""
                    self.ReNewInfoOutlet.text = ""
                }
            }else if NewInfoOutlet.text != ReNewInfoOutlet.text{
                createAlert(title: "新密碼輸入錯誤", message: "請重新輸入", actiontitle: "OK") { (UIAlertAction) in
                    self.OldInfoOutlet.text = ""
                    self.NewInfoOutlet.text = ""
                    self.ReNewInfoOutlet.text = ""
                }
            }else{
                createAlert(title: "更改成功！", message: "密碼已更改", actiontitle: "OK!") { (UIAlertAction) in
                    let urlstr = APIUrlStr + "/Account/\(self.userAP.Account!)"
                    var request = URLRequest(url: URL(string: urlstr)!)
                    request.httpMethod = "PUT"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    
                    self.userAP.Password = self.NewInfoOutlet.text
                    let uploadAP = AccPasUpload(data: [self.userAP])
                    
                    if let uploadData = try? JSONEncoder().encode(uploadAP){
                    
                        let task = URLSession.shared.uploadTask(with: request, from: uploadData) { (returndata, response, error) in
                            if let responsedata = returndata, let returndata = try? JSONDecoder().decode([String:Int].self, from: responsedata){
                                if returndata["updated"] != nil{
                                    print("upload seccessful!")
                                }else{
                                    print("ERROR!")
                                }
                            }
                        }
                        task.resume()
                    }
                    
                    //返回、傳值
                    let count = self.navigationController?.viewControllers.count
                    let controller = self.navigationController?.viewControllers[count! - 3] as? InformationViewController
                    controller?.userAP = self.userAP
                    if let controller = controller{
                        self.navigationController?.popToViewController(controller, animated: true)
                    }
                }
            }
        }
    }
    
    
    func createAlert(title: String, message: String, actiontitle: String, action: @escaping ((UIAlertAction) -> Void) ){
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: actiontitle, style: .default, handler: action)
        controller.addAction(action)
        present(controller, animated: true, completion: nil)
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
