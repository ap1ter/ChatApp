//
//  PostManager.swift
//  ChatApp
//
//  Created by Andrew Piterov on 23/09/2017.
//  Copyright © 2017 Andrew Pierov. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth


class PostManager: NSObject {
    static let databaseRef = Database.database().reference()
    static var posts = [Post]()
    
    static func sendPost(username: String, text: String, toId: String, fromId: String){
        if text != "" {
            let uid = Auth.auth().currentUser?.uid
            let post = ["uid": uid!,
                        "username": username,
                        "text": text,
                        "toId": toId]
            databaseRef.child("posts").childByAutoId().setValue(post)
        }
    }
    
    static func fillPosts(uid: String, toId: String, completion: @escaping (_ result: String) -> Void){
        posts = []
        let allPost = databaseRef.child("posts")
        print(allPost)
        let post = databaseRef.child("posts").queryOrdered(byChild: "uid").queryEqual(toValue: FirebaseManager.currentUser?.uid).observe(.childAdded, with: {
                (snapshot) in
                print(snapshot)
            })
        
        databaseRef.child("posts").queryOrdered(byChild: "uid").queryEqual(toValue: FirebaseManager.currentUser?.uid).observe(.childAdded, with: {
            snapshot in
            print(snapshot)
            if let result = snapshot.value as? [String:Any]{
                let toIdCloud = result["toId"]! as! String
                if toIdCloud == toId {
                    let p = Post(username: result["username"]! as! String, text: result["text"]! as! String, toId: result["toId"]! as! String)
                    PostManager.posts.append(p)
                }
            }
            completion("")
        })
    }
}

class Post{
    var username: String = ""
    var text: String = ""
    var toId: String = ""
    
    init(username: String, text: String, toId: String){
        self.username = username
        self.text = text
        self.toId = toId
    }
}
