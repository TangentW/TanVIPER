//
//  OnePresenter.swift
//  TanVIPER
//
//  Created by Tan on 2016/12/6.
//  Copyright © 2016年 Tangent. All rights reserved.
//

import UIKit
import Argo

class OnePresenter: Presenter {
    override func present(response: Response) {
        let response = response as! OneResponse
        switch response {
        case let .jumpResponse(viper):
            self.router?.route(type: .modal(identifier: viper.identifier), userInfo: "From One To Two | One --> Two")
        case let .loginResponse(json):
            var alertMessage = ""
            if let json = json {
                let networkResponse: NetworkResponse = decode(json)!
                switch networkResponse {
                case let .faild(message):
                    alertMessage = "登录失败,\(message)"
                case let .success(user):
                    alertMessage = "登录成功,\(user)"
                }
            } else {
                alertMessage = "网络请求或数据解析错误"
            }
            self.view?.display(viewModel: OneViewModel(alertMessage: alertMessage))
        }
    }
}
