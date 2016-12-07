//
//  TwoView.swift
//  TanVIPER
//
//  Created by Tan on 2016/12/6.
//  Copyright © 2016年 Tangent. All rights reserved.
//

import UIKit
import SnapKit

class TwoView: View {
    
    var showMessage: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.orange
        self.view.addSubview(self.showView)
        self.showView.snp.makeConstraints { [unowned self] maker in
            maker.center.equalTo(self.view)
        }
        self.showView.text = self.showMessage
    }
    
    override func show(router: Router, userInfo: Any?) {
        self.showMessage = userInfo as? String
    }
    
    //  MARK: - Lazy
    private lazy var showView: UILabel = {
        $0.textColor = UIColor.white
        $0.font = UIFont.systemFont(ofSize: 23)
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.interator.refresh(request: TwoRequest.back)
    }
    
    //  Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
