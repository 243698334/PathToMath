//
//  PMLoginViewController.swift
//  PathToMath
//
//  Created by Kevin Yufei Chen on 9/15/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

import UIKit
import MessageUI

class PMStartupViewController: UIViewController, PMLoginViewDataSource, PMLoginViewDelegate, PMStartGameViewDelegate, MFMailComposeViewControllerDelegate {
    
    private var backgroundImageView: UIImageView!
    private var logoImage: UIImage!
    private var logoImageView: UIImageView!
    private var termsAndAcknowledgementButton: UIButton!
    private var copyrightLabel: UILabel!
    private var loginView: PMLoginView!
    private var startGameView: PMStartGameView!
    private var loadingView: PMLoadingView!
    
    private var subviewsMovedUpForKeyboardShow : Bool!
    private var subviewsLoaded: Bool!
    
    private weak var gameViewController: PMGameViewController?
    
    private var internetReachability: Reachability!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImageView = UIImageView(image: UIImage(named: "StartupViewBackground"))
        self.backgroundImageView.frame = self.view.bounds
        self.view.addSubview(self.backgroundImageView);
        
        self.logoImage = UIImage(named: "StartupViewLogo")
        self.logoImageView = UIImageView(image: self.logoImage)
        self.logoImageView.contentMode = .ScaleAspectFill
        self.logoImageView.frame = CGRectMake(0, 0, self.view.bounds.width * 0.618, (self.view.bounds.width * 0.618) * (self.logoImage.size.height / self.logoImage.size.width))
        self.logoImageView.center = self.view.center
        self.view.addSubview(self.logoImageView)
        
        self.termsAndAcknowledgementButton = UIButton(frame: CGRect(x: 0, y: CGRectGetMaxY(self.view.frame) - 50, width: 180, height: 20))
        self.termsAndAcknowledgementButton.center = CGPoint(x: self.view.bounds.width / 2.0, y: self.termsAndAcknowledgementButton.center.y)
        self.termsAndAcknowledgementButton.titleLabel?.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        self.termsAndAcknowledgementButton.setAttributedTitle(NSAttributedString(string: "Terms and Acknowledgement", attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]), forState: .Normal)
        self.termsAndAcknowledgementButton.addTarget(self, action: "didTapTermsAndAcknowledgementButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(self.termsAndAcknowledgementButton)
        
        self.copyrightLabel = UILabel(frame: CGRect(x: 0, y: CGRectGetMaxY(self.view.frame) - 30, width: self.view.bounds.width, height: 30))
        self.copyrightLabel.textColor = UIColor.whiteColor()
        self.copyrightLabel.textAlignment = .Center
        self.copyrightLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        self.copyrightLabel.text = "Copyright © 2015 Department of Psychology, University of Illinois at Urbana-Champaign"
        self.view.addSubview(self.copyrightLabel)
        
        self.loginView = PMLoginView(frame: .zero)
        self.loginView.dataSource = self
        self.loginView.delegate = self
        
        self.startGameView = PMStartGameView(frame: .zero)
        self.startGameView.delegate = self
        
        self.loadingView = PMLoadingView(frame: self.view.bounds)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        self.subviewsMovedUpForKeyboardShow = false
        self.subviewsLoaded = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityDidChange:", name: kReachabilityChangedNotification, object: nil)
        self.internetReachability = Reachability.reachabilityForInternetConnection()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.hideLoadingViewAnimated(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (self.subviewsLoaded == true && PMUser.currentUser() != nil) {
            self.updateTimePlayedToday()
            self.checkForUpdatesInBackground()
            return
        }
        
        self.showGameLogo({ () -> Void in
            if (PMUser.currentUser() == nil) {
                self.showLoginView(nil)
            } else {
                self.showStartGameView({ () -> Void in
                    self.updateTimePlayedToday()
                    self.checkForUpdatesInBackground()
                })
            }
        })
        
        self.subviewsLoaded = true
    }
    
    private func showGameLogo(completion: ((Void) -> Void)?) {
        UIView.animateWithDuration(1.5, delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.logoImageView.center = CGPointMake(self.logoImageView.center.x, self.view.bounds.height * 0.25)
        }, completion: { finished in
            if (finished) {
                completion?()
            }
        })
    }
    
    private func showLoginView(completion: ((Void) -> Void)?) {
        self.loginView.alpha = 0.0
        self.loginView.frame = CGRect(x: self.view.bounds.width / 3, y: 350, width: self.view.bounds.width / 3, height: 260)
        self.view.addSubview(self.loginView)

        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.loginView.alpha = 1.0
        }) { (finished) -> Void in
            if (finished) {
                completion?()
            }
        }
    }
    
    private func showStartGameView(completion: ((Void) -> Void)?) {
        self.startGameView.alpha = 0.0
        self.startGameView.frame = CGRect(x: self.view.bounds.width / 3, y: 350, width: self.view.bounds.width / 3, height: 220)
        self.view.addSubview(self.startGameView)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.startGameView.alpha = 1.0
        }) { (finished) -> Void in
            if (finished) {
                completion?()
            }
        }
    }
    
    private func transitFromLoginViewToStartGameView(completion: ((Void) -> Void)?) {
        let loginViewFrame = self.loginView.frame
        self.startGameView.frame = CGRectMake(self.view.bounds.width, loginViewFrame.origin.y, loginViewFrame.width, loginViewFrame.height)
        self.view.addSubview(self.startGameView)
        self.view.bringSubviewToFront(self.startGameView)
        
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.loginView.center = CGPointMake(-self.loginView.frame.width / 2, self.loginView.center.y)
            self.startGameView.frame = loginViewFrame
        }, completion: { finished in
            if (finished) {
                completion?()
                self.loginView.removeFromSuperview()
            }
        })
    }
    
    private func transitFromStartGameViewToLoginView(completion: ((Void) -> Void)?) {
        let startGameViewFrame = self.startGameView.frame
        self.loginView.frame = CGRect(x: -startGameViewFrame.width, y: startGameViewFrame.origin.y, width: startGameViewFrame.width, height: startGameViewFrame.height)
        self.view.addSubview(self.loginView)
        self.view.bringSubviewToFront(self.loginView)
        
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.startGameView.center = CGPointMake(self.view.bounds.width + self.startGameView.frame.width / 2, self.startGameView.center.y)
            self.loginView.frame = startGameViewFrame
        }, completion: { finished in
            if (finished) {
                completion?()
                self.startGameView.removeFromSuperview()
            }
        })
    }
    
    private func loginInBackgroundWithUsername(username: String, password: String) {
        self.loginView.startLoginActivityIndicatorAnimation()
        PMUser.logInWithUsernameInBackground(username, password: password) { (user: PFUser?, error: NSError?) -> Void in
            self.loginView.stopLoginActivityIndicatorAnimation()
            if (user != nil) {
                NSUserDefaults.standardUserDefaults().setObject(user?.username, forKey: kPMUserDefaultsLastUsernameKey)
                PMAppSession.userDidLogin()
                self.transitFromLoginViewToStartGameView({ () -> Void in
                    self.updateTimePlayedToday()
                    self.checkForUpdatesInBackground()
                })
            } else {
                let loginFailedAlertController = UIAlertController(title: "Login Failed", message: "Oops. Maybe you didn't enter your username and password right.", preferredStyle: .Alert)
                let dismissAction = UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil)
                loginFailedAlertController.addAction(dismissAction)
                self.presentViewController(loginFailedAlertController, animated: true, completion: nil)
            }
        }
    }
    
    private func logoutInBackground() {
        self.startGameView.startLogoutActivityIndicatorAnimation()
        PMUser.logOutInBackgroundWithBlock { (error) -> Void in
            if (error == nil) {
                PMAppSession.userDidLogout()
                self.startGameView.stopLogoutActivityIndicatorAnimation()
                self.transitFromStartGameViewToLoginView(nil)
            }
        }
    }
    
    private func updateTimePlayedToday() {
        PMAppSession.loadTimePlayedTodayInBackground { (timePlayedToday: NSTimeInterval) -> Void in
            let hoursPlayed = Int(timePlayedToday / 3600.0)
            let minutesPlayed = Int((timePlayedToday - Double(hoursPlayed * 3600)) / 60.0)
            self.startGameView.updateSummaryLabelWithHoursPlayed(hoursPlayed, minutesPlayed: minutesPlayed)
        }
    }
    
    private func checkForUpdatesInBackground() {
        if (self.internetReachability.currentReachabilityStatus() == NotReachable) {
            let networkAlertBannerView = PMAlertBannerView(style: .Warning)
            networkAlertBannerView.titleLabel.text = "No Internet connection, but no worries"
            networkAlertBannerView.detailTextLabel.text = "We suggest you to go online so we can download the latest problems and upload your progress and performance.\nBut for now, everything will be saved on this device."
            self.showAlertBannerView(networkAlertBannerView, duration: 8.0, animated: true)
        } else {
            let sharedDataLocalQuery = PMSharedData.query()
            sharedDataLocalQuery?.fromPinWithName(kPMLocalDatastoreSharedDataPinName)
            sharedDataLocalQuery?.whereKey(kPMSharedDataKeyKey, equalTo: kPMSharedDataProblemSetVersionKeyKey)
            sharedDataLocalQuery?.getFirstObjectInBackgroundWithBlock({ (localSharedData: PFObject?, sharedDataLocalError: NSError?) -> Void in
                var localProblemSetVersion: String? = nil
                if (localSharedData != nil) {
                    let localSharedData = localSharedData as? PMSharedData
                    localProblemSetVersion = localSharedData?.sharedDataValue
                }
                
                let sharedDataRemoteQuery = PMSharedData.query()
                sharedDataRemoteQuery?.whereKey(kPMSharedDataKeyKey, equalTo: kPMSharedDataProblemSetVersionKeyKey)
                sharedDataRemoteQuery?.getFirstObjectInBackgroundWithBlock({ (remoteSharedData: PFObject?, sharedDataRemoteError: NSError?) -> Void in
                    if (remoteSharedData != nil && sharedDataRemoteError == nil) {
                        let remoteSharedData = remoteSharedData as? PMSharedData
                        if (localProblemSetVersion == nil) {
                            remoteSharedData?.pinInBackgroundWithName(kPMLocalDatastoreSharedDataPinName)
                        }
                        let remoteProblemSetVersion = remoteSharedData?.sharedDataValue
                        if (localProblemSetVersion != remoteProblemSetVersion) {
                            self.showActivityIndicatorViewForUpdatingProblemSet()
                            let problemQuery = PMProblem.query()
                            localSharedData?.fetchInBackground()
                            problemQuery?.findObjectsInBackgroundWithBlock({ (problems: [PFObject]?, error: NSError?) -> Void in
                                if (problems != nil && error == nil) {
                                    let problems = problems as? [PMProblem]
                                    PMProblem.unpinAllObjectsInBackgroundWithName(kPMLocalDatastoreProblemPinName, block: { (unpinSuccess: Bool, unpinError: NSError?) -> Void in
                                        PMProblem.pinAllInBackground(problems, block: { (unpinSuccess: Bool, unpinError: NSError?) -> Void in
                                            self.dismissViewControllerAnimated(true, completion: nil)
                                        })
                                    })
                                }
                            })
                        }
                    }
                })
            })
        }
    }
    
    private func loadGameProgressInBackground(completion: ((success: Bool, gameProgress: PMGameProgress?) -> Void)?) {
        self.internetReachability.startNotifier()
        if (internetReachability.currentReachabilityStatus() == NotReachable) {
            let localGameProgressQuery = PMGameProgress.query()
            localGameProgressQuery?.fromPinWithName(kPMLocalDatastoreGameProgressPinName)
            localGameProgressQuery?.whereKey(kPMGameProgressUserKey, equalTo: PMUser.currentUser()!)
            localGameProgressQuery?.getFirstObjectInBackgroundWithBlock({ (localGameProgress: PFObject?, localGameProgressQueryError: NSError?) -> Void in
                if (localGameProgressQueryError == nil && localGameProgress != nil) {
                    let warningAlertBannerView = PMAlertBannerView(style: .Warning)
                    warningAlertBannerView.titleLabel.text = "Your game progress might be outdated"
                    warningAlertBannerView.detailTextLabel.text = "Path To Math is loading your local game progress because our server can't be reached.\nIf you have played on another device or the game mode is wrong, go online and try again."
                    self.showAlertBannerView(warningAlertBannerView, duration: 10.0, animated: true)
                    completion?(success: true, gameProgress: localGameProgress as? PMGameProgress)
                } else {
                    let errorAlertBannerView = PMAlertBannerView(style: .Error)
                    errorAlertBannerView.titleLabel.text = "No Internet connection"
                    errorAlertBannerView.detailTextLabel.text = "Path To Math needs to go online to download the problems and save your progress and performance.\nPlease check your Wi-Fi or celluar data and try again."
                    self.showAlertBannerView(errorAlertBannerView, duration: 10.0, animated: true)
                    completion?(success: false, gameProgress: nil)
                }
            })
        } else {
            let remoteGameProcessQuery = PMGameProgress.query()
            remoteGameProcessQuery?.whereKey(kPMGameProgressUserKey, equalTo: PMUser.currentUser()!)
            remoteGameProcessQuery?.getFirstObjectInBackgroundWithBlock({ (remoteGameProgress: PFObject?, remoteGameProgressQueryError: NSError?) -> Void in
                if (remoteGameProgressQueryError == nil && remoteGameProgress != nil) {
                    let remoteGameProgress = remoteGameProgress as! PMGameProgress
                    let localGameProgressQuery = PMGameProgress.query()
                    localGameProgressQuery?.fromPinWithName(kPMLocalDatastoreGameProgressPinName)
                    localGameProgressQuery?.whereKey(kPMGameProgressUserKey, equalTo: PMUser.currentUser()!)
                    localGameProgressQuery?.getFirstObjectInBackgroundWithBlock({ (localGameProgress: PFObject?, localGameProgressQueryError: NSError?) -> Void in
                        if (localGameProgress != nil) {
                            let localGameProgress = localGameProgress as! PMGameProgress
                            if (localGameProgress.mode != remoteGameProgress.mode) {
                                NSUserDefaults.standardUserDefaults().setBool(false, forKey: kPMUserDefaultsHasShownInteractionHintForCurrentGameMode)
                            }
                        } else {
                            NSUserDefaults.standardUserDefaults().setBool(false, forKey: kPMUserDefaultsHasShownInteractionHintForCurrentGameMode)
                        }
                        PMGameProgress.unpinAllObjectsInBackgroundWithName(kPMLocalDatastoreGameProgressPinName, block: { (success: Bool, error: NSError?) -> Void in
                            remoteGameProgress.pinInBackgroundWithName(kPMLocalDatastoreGameProgressPinName)
                        })
                    })
                    completion?(success: true, gameProgress: remoteGameProgress)
                } else {
                    completion?(success: false, gameProgress: nil)
                }
            })
        }
    }
    
    private func loadProblemsInBackgroundWithGameProgress(gameProgress: PMGameProgress, completion: ((success: Bool, problems: [PMProblem]?) -> Void)?) {
        let localProblemsQuery = PMProblem.query()
        localProblemsQuery?.limit = 15
        localProblemsQuery?.fromPinWithName(kPMLocalDatastoreProblemPinName)
        localProblemsQuery?.whereKey(kPMProblemLevelKey, equalTo: gameProgress.level)
        localProblemsQuery?.findObjectsInBackgroundWithBlock({ (localProblems: [PFObject]?, localError: NSError?) -> Void in
            if (localError == nil && localProblems?.count != 0) {
                completion?(success: true, problems: localProblems as? [PMProblem])
            } else {
                let remoteProblemsQuery = PMProblem.query()
                remoteProblemsQuery?.limit = 15
                remoteProblemsQuery?.whereKey(kPMProblemLevelKey, equalTo: gameProgress.level)
                remoteProblemsQuery?.findObjectsInBackgroundWithBlock({ (remoteProblems: [PFObject]?, remoteError: NSError?) -> Void in
                    if (remoteError == nil && remoteProblems?.count != 0) {
                        completion?(success: true, problems: remoteProblems as? [PMProblem])
                    } else {
                        completion?(success: false, problems: nil)
                    }
                })
            }
        })
    }
    
    private func showActivityIndicatorViewForUpdatingProblemSet() {
        let updateProblemSetAlertController = UIAlertController(title: "Updating Problem Set", message: "This will only take few seconds.\n\n", preferredStyle: .Alert)
        let updateProblemSetActivityIndicatorView = UIActivityIndicatorView(frame: updateProblemSetAlertController.view.bounds)
        updateProblemSetActivityIndicatorView.center = CGPoint(x: updateProblemSetAlertController.view.center.x, y: updateProblemSetAlertController.view.center.y + 30)
        updateProblemSetActivityIndicatorView.activityIndicatorViewStyle = .Gray
        updateProblemSetActivityIndicatorView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        updateProblemSetAlertController.view.addSubview(updateProblemSetActivityIndicatorView)
        updateProblemSetActivityIndicatorView.startAnimating()
        self.presentViewController(updateProblemSetAlertController, animated: true, completion: nil)
    }
    
    private func showErrorMessageAlertViewForUpdatingProblemSet() {
        self.dismissViewControllerAnimated(true) { () -> Void in
            let errorMessageAlertController = UIAlertController(title: "Failed to fetch problem set", message: "Sorry but you need the problem set to start the game. Please retry or contact support.", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            errorMessageAlertController.addAction(cancelAction)
            let retryAction = UIAlertAction(title: "Retry", style: .Default, handler: { (retryAction) -> Void in
                self.checkForUpdatesInBackground()
            })
            errorMessageAlertController.addAction(retryAction)
            self.presentViewController(errorMessageAlertController, animated: true, completion: nil)
        }
    }
    
    private func presentLegalInfoViewController() {
        let legalInfoViewController = PMLegalInfoViewController()
        legalInfoViewController.modalPresentationStyle = .FormSheet
        self.presentViewController(legalInfoViewController, animated: true, completion: nil)
        
        let sharedDataQuery = PMSharedData.query()
        if (self.internetReachability.currentReachabilityStatus() == NotReachable) {
            sharedDataQuery?.fromPinWithName(kPMLocalDatastoreSharedDataPinName)
        }
        sharedDataQuery?.whereKey(kPMSharedDataKeyKey, equalTo: kPMSharedDataLegalInfoPageURLKeyKey)
        sharedDataQuery?.getFirstObjectInBackgroundWithBlock({ (sharedData: PFObject?, error: NSError?) -> Void in
            let sharedData = sharedData as! PMSharedData
            let legalInfoPageURLString = sharedData.sharedDataValue
            legalInfoViewController.loadLegalInfoPageWithURLString(legalInfoPageURLString)
        })
    }
    
    private func presentGameViewControllerWithGameProgress(gameProgress: PMGameProgress, problems: [PMProblem]) {
        let gameViewController: PMGameViewController!
        switch gameProgress.mode {
        case kPMGameModeApproximate:
            gameViewController = PMApproximateGameViewController()
            break
        case kPMGameModeExact:
            gameViewController = PMExactGameViewController()
            break
        case kPMGameModeAbacus:
            gameViewController = PMAbacusGameViewController()
            break
        case kPMGameModeNumbers:
            gameViewController = PMNumbersGameViewController()
            break
        case kPMGameModeAPlusB:
            gameViewController = PMAPlusBGameViewController()
            break
        default:
            let sharedDataQuery = PMSharedData.query()
            if (self.internetReachability.currentReachabilityStatus() == NotReachable) {
                sharedDataQuery?.fromPinWithName(kPMLocalDatastoreSharedDataPinName)
            }
            sharedDataQuery?.whereKey(kPMSharedDataKeyKey, containedIn: [kPMSharedDataSupportContactNameKeyKey, kPMSharedDataSupportContactEmailKeyKey])
            sharedDataQuery?.findObjectsInBackgroundWithBlock({ (sharedDatas: [PFObject]?, error: NSError?) -> Void in
                if (sharedDatas != nil && error == nil) {
                    let sharedDatas = sharedDatas as! [PMSharedData]
                    if (self.internetReachability.currentReachabilityStatus() != NotReachable) {
                        PMSharedData.pinAllInBackground(sharedDatas)
                    }
                    var supportContactName: String!, supportContactEmail: String!
                    for currentSharedData in sharedDatas {
                        if (currentSharedData.sharedDataKey == kPMSharedDataSupportContactNameKeyKey) {
                            supportContactName = currentSharedData.sharedDataValue
                        }
                        if (currentSharedData.sharedDataKey == kPMSharedDataSupportContactEmailKeyKey) {
                            supportContactEmail = currentSharedData.sharedDataValue
                        }
                    }
                    let invalidGameModeAlertController = UIAlertController(title: "Invalid Game Mode", message: "Please contact the Department of Psychology or \(supportContactName!) at \(supportContactEmail!) for more information.", preferredStyle: .Alert)
                    invalidGameModeAlertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                    invalidGameModeAlertController.addAction(UIAlertAction(title: "Send Email", style: .Default, handler: { (action: UIAlertAction) -> Void in
                        let mailComposeViewController = MFMailComposeViewController()
                        mailComposeViewController.mailComposeDelegate = self
                        mailComposeViewController.setToRecipients([supportContactEmail])
                        mailComposeViewController.setSubject("PathToMath - Invalid Game Mode")
                        mailComposeViewController.setMessageBody("Username: \(PMUser.currentUser()?.username!)", isHTML: false)
                        if (MFMailComposeViewController.canSendMail()) {
                            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
                        } else {
                            let cannotSendEmailAlertBannerView = PMAlertBannerView(style: .Error)
                            cannotSendEmailAlertBannerView.titleLabel.text = "Could not send email"
                            cannotSendEmailAlertBannerView.detailTextLabel.text = "Please check your email configurations on this device."
                            self.showAlertBannerView(cannotSendEmailAlertBannerView, duration: 5.0, animated: true)
                        }
                    }))
                    self.presentViewController(invalidGameModeAlertController, animated: true, completion: { () -> Void in
                        self.hideLoadingViewAnimated(true)
                    })
                }
            })
            return
        }
        gameViewController.gameProgress = gameProgress
        gameViewController.problems = problems
        self.gameViewController = gameViewController
        self.presentViewController(gameViewController, animated: true, completion: nil)
    }
    
    func showLoadingViewAnimated(animated: Bool) {
        self.loadingView.alpha = 0.0
        self.view.addSubview(self.loadingView)
        if (animated == true) {
            UIView.animateWithDuration(0.25) { () -> Void in
                self.loadingView.alpha = 1.0
            }
        } else {
            self.loadingView.alpha = 1.0
        }
    }
    
    func hideLoadingViewAnimated(animated: Bool) {
        if (animated == true) {
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.loadingView.alpha = 0.0
            }, completion: { (finished: Bool) -> Void in
                if (finished == true) {
                    self.loadingView.removeFromSuperview()
                }
            })
        } else {
            self.loadingView.removeFromSuperview()
        }
    }
    
    private func showAlertBannerView(alertBannerView: PMAlertBannerView, duration: NSTimeInterval, animated: Bool) {
        if (animated == true) {
            alertBannerView.frame = alertBannerView.hideFrame
            UIApplication.sharedApplication().keyWindow?.addSubview(alertBannerView)
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .CurveEaseInOut, animations: { () -> Void in
                alertBannerView.frame = alertBannerView.showFrame
            }, completion: { (finished: Bool) -> Void in
                if (finished == true) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                        self.hideAlertBannerView(alertBannerView, animated: animated)
                    }
                }
            })
        } else {
            UIApplication.sharedApplication().keyWindow?.addSubview(alertBannerView)
        }
    }
    
    private func hideAlertBannerView(alertBannerView: PMAlertBannerView, animated: Bool) {
        if (animated == true) {
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                alertBannerView.frame = alertBannerView.hideFrame
            }, completion: { (finished: Bool) -> Void in
                alertBannerView.removeFromSuperview()
            })
        } else {
            alertBannerView.removeFromSuperview()
        }
    }
    
    
    // MARK: Keyboard Show & Hide
    
    func keyboardWillShow(notification: NSNotification) {
        if (self.subviewsMovedUpForKeyboardShow == true) {
            return;
        }
        
        self.subviewsMovedUpForKeyboardShow = true
        let userInfo : NSDictionary? = notification.userInfo
        let animationDuration : Double? = userInfo?.objectForKey(UIKeyboardAnimationDurationUserInfoKey)?.doubleValue
        
        UIView.animateWithDuration(animationDuration!) { () -> Void in
            self.logoImageView.center = CGPoint(x: self.logoImageView.center.x, y: self.logoImageView.center.y - 100)
            self.loginView.center = CGPoint(x: self.loginView.center.x, y: self.loginView.center.y - 140)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if (self.subviewsMovedUpForKeyboardShow == false) {
            return;
        }
        
        self.subviewsMovedUpForKeyboardShow = false
        let userInfo : NSDictionary? = notification.userInfo
        let animationDuration : Double? = userInfo?.objectForKey(UIKeyboardAnimationDurationUserInfoKey)?.doubleValue
        
        UIView.animateWithDuration(animationDuration!) { () -> Void in
            self.logoImageView.center = CGPoint(x: self.logoImageView.center.x, y: self.logoImageView.center.y + 100)
            self.loginView.center = CGPoint(x: self.loginView.center.x, y: self.loginView.center.y + 140)
        }
    }
    
    
    // MARK: Reachability
    
    
    func reachabilityDidChange(notification: NSNotification) {
        let reachability = notification.object as! Reachability
        if (reachability.currentReachabilityStatus() == NotReachable) {
            let reachabilityAlertBannerView = PMAlertBannerView(style: .Warning)
            reachabilityAlertBannerView.titleLabel.text = "You have been disconnected"
            reachabilityAlertBannerView.detailTextLabel.text = "Your responses and progress will be saved locally until you are connected to the Internet again."
            self.showAlertBannerView(reachabilityAlertBannerView, duration: 5.0, animated: true)
        } else {
            let localGameProgressQuery = PMGameProgress.query()
            localGameProgressQuery?.fromPinWithName(kPMLocalDatastoreGameProgressPinName)
            localGameProgressQuery?.whereKey(kPMGameProgressUserKey, equalTo: PMUser.currentUser()!)
            localGameProgressQuery?.getFirstObjectInBackgroundWithBlock({ (localGameProgress: PFObject?, localError: NSError?) -> Void in
                if (localGameProgress != nil && localError == nil) {
                    let localGameProgress = localGameProgress as! PMGameProgress
                    let localGameMode = String(localGameProgress.mode)
                    let localGameLevel = Int(localGameProgress.level)
                    localGameProgress.fetchInBackgroundWithBlock({ (fetchedGameProgress: PFObject?, fetchError: NSError?) -> Void in
                        if (fetchedGameProgress != nil && fetchError == nil) {
                            let fetchedGameProgress = fetchedGameProgress as! PMGameProgress
                            if (fetchedGameProgress.mode != localGameMode || fetchedGameProgress.level != localGameLevel) {
                                self.dismissViewControllerAnimated(true, completion: nil)
                                let gameProgressOutdatedAlertController = UIAlertController(title: "Oops!", message: "We just heard back from our server and it seems like you are playing with the outdated game mode or game level. Please restart the game. ", preferredStyle: .Alert)
                                gameProgressOutdatedAlertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                                self.presentViewController(gameProgressOutdatedAlertController, animated: true, completion: nil)
                            }
                        }
                    })
                }
            })
        }
    }
    
    func didTapTermsAndAcknowledgementButton(button: UIButton) {
        self.presentLegalInfoViewController()
    }
    
    
    // MARK: LoginViewDataSource
    
    func savedUsernameInLoginView(loginView: PMLoginView) -> String? {
        return NSUserDefaults.standardUserDefaults().stringForKey(kPMUserDefaultsLastUsernameKey)
    }
    
    func savedPasswordInLoginView(loginView: PMLoginView) -> String? {
        return nil
    }
    
    
    // MARK: LoginViewDelegate
    
    func loginView(loginView: PMLoginView, didTapLoginButtonWithUsername username: String, password: String) {
        self.view.endEditing(true)
        if (username.isEmpty || password.isEmpty) {
            let incompleteLoginInfoAlertController = UIAlertController(title: "Uh-uh", message: "Please fill in your username and password.", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            incompleteLoginInfoAlertController.addAction(cancelAction)
            self.presentViewController(incompleteLoginInfoAlertController, animated: true, completion: nil)
        }
        self.loginInBackgroundWithUsername(username, password: password)
    }
    
    func loginView(loginView: PMLoginView, didTapForgotPasswordButtonWithUsername username: String) {
        self.view.endEditing(true)
        
        if (self.internetReachability.currentReachabilityStatus() == NotReachable) {
            let forgotPasswordAlertController = UIAlertController(title: "Need help with password?", message: "Please contact the Department of Psychology for more support.", preferredStyle: .Alert)
            forgotPasswordAlertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            self.presentViewController(forgotPasswordAlertController, animated: true, completion: nil)
        } else {
            let sharedDataQuery = PMSharedData.query()
            if (self.internetReachability.currentReachabilityStatus() == NotReachable) {
                sharedDataQuery?.fromPinWithName(kPMLocalDatastoreSharedDataPinName)
            }
            sharedDataQuery?.whereKey(kPMSharedDataKeyKey, containedIn: [kPMSharedDataSupportContactNameKeyKey, kPMSharedDataSupportContactEmailKeyKey])
            sharedDataQuery?.findObjectsInBackgroundWithBlock({ (sharedDatas: [PFObject]?, error: NSError?) -> Void in
                if (sharedDatas != nil && error == nil) {
                    let sharedDatas = sharedDatas as! [PMSharedData]
                    if (self.internetReachability.currentReachabilityStatus() != NotReachable) {
                        PMSharedData.pinAllInBackground(sharedDatas)
                    }
                    var supportContactName: String!, supportContactEmail: String!
                    for currentSharedData in sharedDatas {
                        if (currentSharedData.sharedDataKey == kPMSharedDataSupportContactNameKeyKey) {
                            supportContactName = currentSharedData.sharedDataValue
                        }
                        if (currentSharedData.sharedDataKey == kPMSharedDataSupportContactEmailKeyKey) {
                            supportContactEmail = currentSharedData.sharedDataValue
                        }
                    }
                    let forgotPasswordAlertController = UIAlertController(title: "Need help with password?", message: "Please contact the Department of Psychology or \(supportContactName!) at \(supportContactEmail!).", preferredStyle: .Alert)
                    forgotPasswordAlertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                    forgotPasswordAlertController.addAction(UIAlertAction(title: "Send Email", style: .Default, handler: { (action: UIAlertAction) -> Void in
                        let mailComposeViewController = MFMailComposeViewController()
                        mailComposeViewController.mailComposeDelegate = self
                        mailComposeViewController.setToRecipients([supportContactEmail])
                        mailComposeViewController.setSubject("PathToMath - I Forgot My Password")
                        mailComposeViewController.setMessageBody("Username: \(username)", isHTML: false)
                        if (MFMailComposeViewController.canSendMail()) {
                            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
                        } else {
                            let cannotSendEmailAlertBannerView = PMAlertBannerView(style: .Error)
                            cannotSendEmailAlertBannerView.titleLabel.text = "Could not send email"
                            cannotSendEmailAlertBannerView.detailTextLabel.text = "Please check your email configurations on this device."
                            self.showAlertBannerView(cannotSendEmailAlertBannerView, duration: 5.0, animated: true)
                        }
                    }))
                    self.presentViewController(forgotPasswordAlertController, animated: true, completion: nil)
                }
            })
        }
    }
    
    func didTapGuestButtonInLoginView(loginView: PMLoginView) {
        
    }
    


    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: StartGameViewDelegate
    
    func didTapStartButtonInStartGameView(startGameView: PMStartGameView) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.showLoadingViewAnimated(true)
        }
        self.loadGameProgressInBackground { (success: Bool, gameProgress: PMGameProgress?) -> Void in
            if (success == true) {
                self.loadProblemsInBackgroundWithGameProgress(gameProgress!, completion: { (success: Bool, problems: [PMProblem]?) -> Void in
                    if (success == true) {
                        self.presentGameViewControllerWithGameProgress(gameProgress!, problems: problems!)
                    } else {
                        let errorMessageAlertController = UIAlertController(title: "Failed to load problems", message: "Sorry about this but we need to load the problems before the game. Please retry or contact support.", preferredStyle: .Alert)
                        errorMessageAlertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                        errorMessageAlertController.addAction(UIAlertAction(title: "Retry", style: .Default, handler: { (retryAction) -> Void in
                            self.didTapStartButtonInStartGameView(self.startGameView)
                        }))
                        self.presentViewController(errorMessageAlertController, animated: true, completion: nil)
                    }
                })
            } else {
                let errorMessageAlertController = UIAlertController(title: "Failed to load game progress", message: "Sorry about this but we need to know your progress before the game. Please retry or contact support.", preferredStyle: .Alert)
                errorMessageAlertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                errorMessageAlertController.addAction(UIAlertAction(title: "Retry", style: .Default, handler: { (retryAction) -> Void in
                    self.didTapStartButtonInStartGameView(self.startGameView)
                }))
                self.presentViewController(errorMessageAlertController, animated: true, completion: nil)
            }
            self.hideLoadingViewAnimated(true)
        }
    }
    
    func didTapLogoutButtonInStartGameView(startGameView: PMStartGameView) {
        let logoutAlertController = UIAlertController(title: "Logging Out", message: "Are you sure you would like to log out?", preferredStyle: .Alert)
        logoutAlertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        logoutAlertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (retryAction) -> Void in
            self.logoutInBackground()
        }))
        self.presentViewController(logoutAlertController, animated: true, completion: nil)
    }
    
}
