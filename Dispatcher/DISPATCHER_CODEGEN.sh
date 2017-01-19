#!/bin/bash
# Generates teplete reqeust/response classes for Dispatcher
#
# how to use:
# 1. copy script to some temp folder
# 2. cd to that folder
# 3. give script rights to write files: chmod 755 DISPATCHER_CODEGEN.sh
# 4. run: ./DISPATCHER_CODEGEN.sh RequestName (think GetArticleList)

reqeust_name=$1

if [ "$reqeust_name" != "" ]; then
	echo "Creating phisical files"
	echo "..."
	author=$(cat ~/.gitconfig | grep "name =" | cut -d'=' -f 2)
    date=$(date +%F)
    request=$(echo "Request")
    file=$(echo "$reqeust_name$request")
    response=$(echo "Response")

    touch "$file.swift"
    echo "//
//  $file.swift
//
//  Created by $author on $date.
//

import Foundation

class $reqeust_name$request: Request {
    
    class $reqeust_name$response: Response {
        
        override func parseResponse(response: URLResponse?, data: Data?) throws {
            try super.parseResponse(response: response, data: data)
            
            //FIXME: Do object/core data model filling from variable json
        }
    }
    
    private lazy var actualResponse = $reqeust_name$response()
    override private(set) var response: Response {
        get {
            return actualResponse
        }
        set {
            if newValue is $reqeust_name$response {
                actualResponse = newValue as! $reqeust_name$response
            } else {
                print(\"incorrect type of response\")
            }
        }
    }
    
    override func serviceURLRequest() -> URLRequest {
        var request = super.serviceURLRequest()
        
        //FIXME: Do any request configuration
        
        return request
    }
}

    " > $file.swift
    echo "$file.swift has been created"

    else
    echo "[ERROR!] Provide Request name"
    echo "Call this script with at least 1 parameter"
    echo "sh DISPATCHER_CODEGEN NewModuleName"
    exit 0
fi
