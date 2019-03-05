//
//  DataCenter.swift
//  SimpleBulletinBoard
//
//  Created by Susan Kim on 04/03/2019.
//  Copyright © 2019 Susan Kim. All rights reserved.
//

import Foundation
import Alamofire

let dataCenter = DataCenter()

class DataCenter {
    let baseURL = "http://hulk.zeyo.co.kr:5002/api/documents"
    var posts:[Post]
    
    init() {
        posts = []
    }
    
    func uploadPost(title: String, content: String, completionHandler: @escaping () -> Void) {
        Alamofire.request(
            "\(baseURL)",
            method: .post,
            parameters: ["title" : title, "content" : content],
            encoding: URLEncoding.httpBody,
            headers:nil
        )
            .validate()
            .responseJSON { response in
                guard response.result.isSuccess else {
                    print("Post unsuccessful.")
                    return
                }
                completionHandler()
        }
        
    }
    
    func loadPosts(completionHandler: @escaping () -> Void) {
        Alamofire.request(
            baseURL,
            method: .get,
            parameters: [:],
            encoding: URLEncoding.default,
            headers: ["Content-Type" : "application/json", "charset" : "UTF-8"]
            )
            .validate(statusCode: 200..<300)
            .responseJSON {
                response in
                guard response.result.isSuccess else {
                    print("Load unsuccessful.")
                    return
                }
                
                if let result = response.result.value {
                    var postCount: Int = 0
                    let JSON = result as! NSArray
                    dataCenter.posts = []
                    for postJSON in JSON {
                        guard let jsonData = postJSON as? Dictionary<String, Any> else {
                            continue
                        }
                        let title = jsonData["title"] as? String
                        let content = jsonData["content"] as? String
                        
                        guard let t = title, let c = content else {
                            continue
                        }
                        postCount = postCount + 1
                        dataCenter.posts.append(Post("\(postCount)", t, c))
                    }
                    
                }
                completionHandler()
        }
    }
    
    func deletePost(id:String, completionHandler: @escaping () -> Void ) {
        Alamofire.request(
            "\(baseURL)/\(id)",
            method: .delete,
            parameters: [:],
            encoding: URLEncoding.httpBody,
            headers:nil
            )
            .validate()
            .responseJSON { response in
                guard response.result.isSuccess else {
                    print("Post unsuccessful.")
                    return
                }
                completionHandler()
        }
    }

}
