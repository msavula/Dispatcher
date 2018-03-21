//
//  ViewController.swift
//  Dispatcher-Core-Data
//
//  Created by Nick Savula on 12/15/16.
//  Copyright © 2016 Nick Savula. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let request = HTTPBinPostRequest(owner: ObjectIdentifier(self))
        request.cacheCompletion = { users in
            if users.count > 0, let user = users[0] as? User {
                print("userId: \(user.userId) name: \(String(describing: user.name)) birthdate: \(String(describing: user.birthdate)) bio: \(String(describing: user.bio)) avatar: \(String(describing: user.avatar))")
            }
        }
        request.completion = {
            request, error in
            if let response = request.response as? HTTPBinPostRequest.HTTPBinPostResponse {
                if let user = response.user {
                    print("userId: \(user.userId) name: \(String(describing: user.name)) birthdate: \(String(describing: user.birthdate)) bio: \(String(describing: user.bio)) avatar: \(String(describing: user.avatar))")
                    DataModel.shared.saveContext()
                }
            }
        }
        Dispatcher.shared.processRequest(request: request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

