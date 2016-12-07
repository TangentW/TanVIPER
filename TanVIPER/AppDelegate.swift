//
//  AppDelegate.swift
//  TanVIPER
//
//  Created by Tan on 2016/12/6.
//  Copyright © 2016年 Tangent. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //  Init Window
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = UIColor.white
        window.makeKeyAndVisible()
        self.window = window
        //  Init Binder
        BinderHelper.initBinder()
        //  Router
        Router().route(type: .root(identifier: VIPERs.one.identifier), userInfo: nil)
        return true
    }

}

