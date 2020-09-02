//
//  AccountPassword.swift
//  SheetDB APLogin
//
//  Created by tantsunsin on 2020/8/21.
//

import Foundation

struct AccPasUpload : Codable, Equatable{
    var data: [AccountPassword]
}

struct AccountPassword : Codable, Equatable{
    var Name : String?
    var Account : String?
    var Password : String?
//    var Login : String?
    var Login_Status : String?
    
//    enum CodingKeys : String, CodingKey{
//        case Name
//        case Account
//        case Password
//        case Login = "Login_Status"
//    }
}

extension String{
    var bool : Bool? {
        if self == "TRUE"{
            return true
        }else if self == "FALSE"{
            return false
        }else {
            return nil
        }
    }
}

let APIUrlStr = "https://sheetdb.io/api/v1/gwt04t0nz1ksr"
