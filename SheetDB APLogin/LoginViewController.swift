//
//  LoginViewController.swift
//  SheetDB APLogin
//
//  Created by tantsunsin on 2020/8/21.
//

import UIKit

protocol LoginDelegate{
    func update(Info : AccountPassword?)
}

class LoginViewController: UIViewController {
    
    static let shared = LoginViewController()
    
    var delegate : LoginDelegate?
    var isForLogin : Bool!  //true -> 代表要登入；false -> 代表要註冊
    var APInput = AccountPassword(Name: "", Account: "", Password: "", Login_Status: "FALSE")  //使用者輸入
//    var APCheck : AccountPassword!  //GET來對比的
    
    @IBOutlet weak var AcTextField: UITextField!
    @IBOutlet weak var PaTextField: UITextField!
    @IBOutlet weak var RePaTextField: UITextField!
    @IBOutlet weak var NewNameTextField: UITextField!
    @IBOutlet weak var DoneOutlet: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setOutlet()
        // Do any additional setup after loading the view.
    }
    
    func setOutlet(){
        AcTextField.placeholder = isForLogin ? "帳號" : "新帳號"
        PaTextField.placeholder = isForLogin ? "密碼" : "新密碼"
        RePaTextField.isHidden = isForLogin ? true : false
        NewNameTextField.isHidden = isForLogin ? true : false
        PaTextField.isSecureTextEntry = true
        RePaTextField.isSecureTextEntry = true
    }
    
    @IBAction func accountTyped(_ sender: UITextField) {
        APInput.Account = sender.text
    }
    @IBAction func AcDismissKeyboard(_ sender: Any) {
    }
    
    
    @IBAction func passwordTyped(_ sender: UITextField) {
        APInput.Password = sender.text
    }
    @IBAction func PaDismissKeyboard(_ sender: Any) {
    }
    
    
    @IBAction func RePaDismissKeyboard(_ sender: Any) {
    }
    
    
    @IBAction func newNameTyped(_ sender: UITextField) {
        APInput.Name = sender.text
    }
    @IBAction func NewNameDismissKeyboard(_ sender: Any) {
    }
    
    
    
    @IBAction func rePasswordTyped(_ sender: UITextField) {
        if sender.text == APInput.Password{
            return
        }else{
            let controller = UIAlertController(title: "密碼不一致", message: "請重新輸入", preferredStyle: .alert)
            let action = UIAlertAction(title: "確定", style: .default) { (UIAlertAction) in
                sender.text = ""
            }
            controller.addAction(action)
            present(controller, animated: true, completion: nil)
            APInput.Password = nil
        }
    }
    
    @IBAction func doneButton(_ sender: UIButton) {
        if isForLogin{  // 登入
                var URLStr = APIUrlStr + "/search?Account=\(AcTextField.text!)"
                var request = URLRequest(url: URL(string: URLStr)!)
                let decoder = JSONDecoder()
            
                // 下載同帳號的帳密資料來比對
                let task = URLSession.shared.dataTask(with: request) { (Data, URLResponse, Error) in
                    if let data = Data, let APGet = try? decoder.decode([AccountPassword].self, from: data){
                        
                        print(APGet)
                        print("PASSWORD: \(APGet[0].Password!) , \(self.APInput.Password)")
                        
                        DispatchQueue.main.async {
                            if APGet == []{
                                self.createAlert(title: "帳號錯誤", message: "請重新輸入", actiontitle: "確定") { (UIAlertAction) in
                                    self.APInput.Account = ""
                                }
                            }else if APGet[0].Password! != self.APInput.Password{
                                self.createAlert(title: "密碼錯誤", message: "請重新輸入", actiontitle: "確定") { (UIAlertAction) in
                                    self.APInput.Password = ""
                                }
                            }else if APGet[0].Account! == self.APInput.Account, APGet[0].Password! == self.APInput.Password{
                                self.createAlert(title: "登入成功！", message: "歡迎！", actiontitle: "確定") { (UIAlertAction) in //因為登入狀態改變而上傳
                                    self.APInput.Login_Status = "TRUE"
                                    self.APInput.Name = APGet[0].Name
                                    
                                    let APUpload = AccPasUpload(data: [self.APInput])
                                    
                                   
                                    URLStr = APIUrlStr + "/Account/\(self.APInput.Account!)"
                                    var UploadRequest = URLRequest(url: URL(string: URLStr)!)
                                    UploadRequest.httpMethod = "PUT"
                                    UploadRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                                    
                                    if let data = try? JSONEncoder().encode(APUpload){
                                        let task = URLSession.shared.uploadTask(with: UploadRequest, from: data) { (returndata, response, error) in
                                            if let returndata = returndata, let ResponseData = try? decoder.decode([String:Int].self, from: returndata){
                                                if ResponseData["updated"] != nil{
                                                    print("OK!")
                                                }else{
                                                    print("error!")
                                                }
                                            }
                                        }
                                        task.resume()
                                    }
                                    // 退回前一頁
                                    self.delegate?.update(Info: self.APInput)
                                    self.navigationController?.popViewController(animated: true)

                                }
                            }
                        }
                        
                    }
                }
                task.resume()
            
            
        }else{  // 註冊
            createAlert(title: "註冊成功！", message: "歡迎！", actiontitle: "OK!") { [self] (UIAlertAction) in
                let url = URL(string: APIUrlStr)
                var request = URLRequest(url: url!)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                self.APInput.Login_Status = "TRUE"
                let UploadData = AccPasUpload(data: [self.APInput])
                if let PostData = try? JSONEncoder().encode(UploadData){
                    let task = URLSession.shared.uploadTask(with: request, from: PostData) { (returndata, response, error) in
                        if let returndata = returndata, let decodedreturn = try?  JSONDecoder().decode([String:Int].self, from: returndata){
                            if decodedreturn["created"] != nil{
                                print ("Successful!")
                            }else{
                                print ("POSTFAILED!")
                            }
                        }
                    }
                    task.resume()
                }
                self.delegate?.update(Info: self.APInput)
                self.navigationController?.popViewController(animated: true)
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
