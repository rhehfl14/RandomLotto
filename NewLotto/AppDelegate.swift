//
//  AppDelegate.swift
//  NewLotto
//
//  Created by kbcard on 2021/07/19.
//

import UIKit
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window : UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        Realm.Configuration.defaultConfiguration = Realm.Configuration (
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                
            })
        return true
    }

}

