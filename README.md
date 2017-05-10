# Dispatcher
Swift brother of https://github.com/maliwanLLC/MTDispatcher
networking engine based on chain of responsibility pattern

## Table of Contents
* [Installation](#installation)
* [Usage](#usage)
* [Configurability](#configurability)
* [Code Generation](#code-generation)

## Installation
drag and drop contents of Dispatcher folder to your project's vendor folder

## Usage

for each request you'll need to create Request subclass and Response subclass. Request subclass has to override response var with your custom response subclass

```swift
override func serviceURLRequest() -> URLRequest {
    var request = super.serviceURLRequest()
        
    // request configuration code
        
    return request
}

private lazy var actualResponse = HTTPBinUtf8Response()
override private(set) var response: Response {
    get {
        return actualResponse
    }
    set {
        if newValue is HTTPBinUtf8Response {
            actualResponse = newValue as! HTTPBinUtf8Response
        } else {
            print("incorrect type of response")
        }
    }
}
```

in Response subclass you should override parseResponse method, to process feedback from server

```swift
func parseResponse(response: URLResponse?, data: Data?) throws
```

super call is required to fill json dictionary/array

```swift
override func parseResponse(response: URLResponse?, data: Data?) throws {
    try super.parseResponse(response: response, data: data)
            
    if let jsonDictionary = json as? Dictionary<String, Any> {
        origin = jsonDictionary["origin"] as? String
        url = jsonDictionary["url"] as? String
    }
}
```

after request/response is configured, a wannabe caller would need to make an actual call

```swift
let request = HTTPBinGetRequest(owner: ObjectIdentifier(self))
request.completion = {
    reqeust, error in
    if let response = request.response as? HTTPBinGetRequest.HTTPBinGetResponse {
        print("origin: \(response.origin) url: \(response.url)")
    }
}
Dispatcher.shared.processRequest(request: request)
```

## Configurability
Library is to certain extent configurable through Dispatcher-info.plist file

```xml
<dict>
    <key>LOG_NETWORK</key>
    <false/>
    <key>PLIST_VERSION</key>
    <integer>1</integer>
    <key>TIMEOUT_INTERVAL</key>
    <integer>30</integer>
    <key>SUCESS_STATUS_CODES</key>
    <array>
        <string>200-299</string>
    </array>
    <key>HTTP_HEADERS</key>
    <dict>
        <key>Accept</key>
        <string>application/json</string>
        <key>Content-Type</key>
        <string>application/x-www-form-urlencoded</string>
    </dict>
    <key>DEFAULT_METHOD</key>
    <string>GET</string>
    <key>LOG_DEPOT_OPERATIONS</key>
    <false/>
</dict>
```

here you can configure logging options, timeout interval, accept status codes, default http headers and default request methods

## Code Generation
Dispatcher contains code generation script to create your request subclasses

###xCode Template
unzip Dispatchder Request.xctemplate.zip and install template
how-to template installation: https://discussions.apple.com/thread/2802293?start=0&tstart=0

###DISPATCHER_CODEGEN.sh

 how to use:
 1. copy script to some temp folder
 2. cd to that folder
 3. give script rights to write files: "chmod 755 DISPATCHER_CODEGEN.sh"
 4. run: "./DISPATCHER_CODEGEN.sh RequestName" (think GetArticleList)
 
 you'll see request/response templates created, just drag and drop them to your Requests folder and implement request building, response parsing

