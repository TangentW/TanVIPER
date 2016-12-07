//
//  TwoPresenter.swift
//  TanVIPER
//
//  Created by Tan on 2016/12/6.
//  Copyright © 2016年 Tangent. All rights reserved.
//

import UIKit

class TwoPresenter: Presenter {
    override func present(response: Response) {
        switch response as! TwoResponse {
        case .back:
            self.router?.route(type: .back, userInfo: nil)
        }
    }
}
