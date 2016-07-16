
//
//  AppDelegate.swift
//  DraftMetrics2
//
//  Created by Jack Cable on 6/1/16.
//  Copyright © 2016 Jack Cable. All rights reserved.
//

import UIKit
import Fabric
import Onboard
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
//    let kUserHasOnboardedKey = "user_has_onboarded"


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        UITabBar.appearance().tintColor = UIColor.whiteColor()
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        Fabric.sharedSDK().debug = true
        Fabric.with([Crashlytics.self])
        
//        
//        let userHasOnboarded = false//NSUserDefaults.standardUserDefaults().boolForKey(kUserHasOnboardedKey)
//        
//        if userHasOnboarded {
//            return true
//        } else {
//            self.window?.rootViewController = generateStandardOnboardingVC()
//        }
//        
//        self.window?.makeKeyAndVisible()

        return true
    }
//    
//    func setUpNormalViewController() {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewControllerWithIdentifier("IntroPage") as! IntroPageViewController
//        self.window?.rootViewController!.presentViewController(vc, animated: true, completion: nil)
//        
//        NSUserDefaults.standardUserDefaults().setObject(true, forKey: kUserHasOnboardedKey)
//    }
//    
//    func generateStandardOnboardingVC() -> OnboardingViewController {
//        let firstPage = OnboardingContentViewController(title: "Welcome to DraftMetrics.", body: "Say goodbye to cheatsheets. Simply input your draft and DraftMetrics will take care of the rest, calculating your optimal picks and previewing rounds ahead.", image: UIImage(named: "icon_main50"), buttonText: "Get Started") {
//        }
//        firstPage.movesToNextViewController = true
//        let secondPage = OnboardingContentViewController(title: "Configure your draft in the Settings tab.", body: "Customize league size, your pick number, scoring and rosters.", image: UIImage(named: "icon_main50"), buttonText: "Continue") {
//            self.setUpNormalViewController()
//        }
//        let onboardingViewController = OnboardingViewController(backgroundImage: UIImage(named: "Football Image"), contents: [firstPage, secondPage])
//        onboardingViewController.shouldBlurBackground = true;
//        onboardingViewController.shouldMaskBackground = true;
//        onboardingViewController.pageControl.hidden = false;
//        return onboardingViewController
//    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

