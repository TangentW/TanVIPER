//
//  TwoInteractor.swift
//  TanVIPER
//
//  Created by Tan on 2016/12/6.
//  Copyright © 2016年 Tangent. All rights reserved.
//

import UIKit

class TwoInteractor: Interactor {
    override func refresh(request: Request) {
        self.presenter.present(response: TwoResponse.back)
    }
}
