//
//  OneInteractor.swift
//  TanVIPER
//
//  Created by Tan on 2016/12/6.
//  Copyright © 2016年 Tangent. All rights reserved.
//

import UIKit
import Moya

class OneInteractor: Interactor {
    
    let provider: MoyaProvider<NetworkRequest> = MoyaProvider<NetworkRequest>()
    
    override func refresh(request: Request) {
        let request = request as! OneRequest
        switch request {
        case .jump:
            self.presenter.present(response: OneResponse.jumpResponse(viper: .two))
        case let .login(userName, password):
            self.provider.request(.login(userName: userName, password: password), completion: { result in
                var json: Any? = nil
                switch result {
                case .failure: ()
                case let .success(response):
                    json = try? response.mapJSON()
                }
                self.presenter.present(response: OneResponse.loginResponse(json: json))
            })
        }
    }
}
