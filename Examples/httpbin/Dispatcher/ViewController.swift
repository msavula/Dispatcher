//
//  ViewController.swift
//  Dispatcher
//
//  Created by Nick Savula on 11/15/16.
//  Copyright © 2016 Nick Savula. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let request = HTTPBinGetRequest(owner: ObjectIdentifier(self))
        request.completion = {
            reqeust, error in
            if let response = request.response as? HTTPBinGetRequest.HTTPBinGetResponse {
                print("origin: \(String(describing: response.origin)) url: \(String(describing: response.url))")
            }
        }
        Dispatcher.shared.processRequest(request: request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

