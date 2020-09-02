//
//  AccountSettingViewController.swift
//  SheetDB APLogin
//
//  Created by tantsunsin on 2020/8/21.
//

import UIKit

class AccountSettingViewController: UIViewController {
    var userAP : AccountPassword!
    var segueIsForAccount = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let userAP = userAP{
            print("傳送的：\(userAP)")
        }else{
            print("nothing...")
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func accountChange(_ sender: Any) {
        segueIsForAccount = true
    }
    @IBAction func passwordChange(_ sender: Any) {
        segueIsForAccount = false
    }
    @IBAction func accountDelete(_ sender: Any) { //刪除帳號
        let alert = UIAlertController(title: "刪除帳號？", message: "確定刪除？", preferredStyle: .alert)
        let action = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let sureAction = UIAlertAction(title: "確定", style: .destructive) { (UIAlertAction) in
            let urlstr = APIUrlStr + "/Account/\(self.userAP.Account!)"
            var request = URLRequest(url: URL(string: urlstr)!)
            request.httpMethod = "DELETE"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let PrepareForUpload = AccPasUpload(data: [self.userAP])
            if let UploadData = try? JSONEncoder().encode(PrepareForUpload){
                let task = URLSession.shared.uploadTask(with: request, from: UploadData) { (returnData, response, error) in
                    if let returndata = returnData, let data = try? JSONDecoder().decode([String:Int].self, from: returndata){
                        if data["deleted"] != nil{
                            print("DELETE SUCCESS!")
                        }else{
                            print("DELETE FAILED!")
                        }
                    }
                }
                task.resume()
                }
            // 返回、傳值
            let count = self.navigationController?.viewControllers.count
            let controller = self.navigationController?.viewControllers[count!-2] as? InformationViewController
            if let controller = controller{
                controller.userAP = nil
                controller.segueIsForLogin = false
                controller.LoginStatus = false
                controller.setOutlet()
                self.navigationController?.popToViewController(controller, animated: true)
            }
        }
        alert.addAction(action)
        alert.addAction(sureAction)
        present(alert, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as? ChangeAPViewController
        controller?.userAP = self.userAP
        controller?.IsForAccount = segueIsForAccount
    }


}
