//
//  ViewController.swift
//  SS Twitter App
//
//  Created by Sagar Sandy on 02/12/18.
//  Copyright © 2018 Sagar Sandy. All rights reserved.
//

import UIKit
import TwitterKit

class ViewController: UIViewController {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    
    var sessionUserId : String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    // MARK: Login with twitter button was pressed
    @IBAction func logInWithTwitterButtonPressed(_ sender: UIButton) {
        
        TWTRTwitter.sharedInstance().logIn { (session, error) in
            
            if let session = session {
                
                let client = TWTRAPIClient(userID: session.userID)
                self.sessionUserId = session.userID
                
                self.fetchLoggedInUserTweets(client: client)
                self.fetchLoggedInUserDetails(client: client)
                
                debugPrint(session.userName)
            } else {
                print("something went wrong")
            }
        }
    }
    
    // MARK: Post tweet button was pressed.
    @IBAction func postTweetButtonPressed(_ sender: UIButton) {
        
        // Checking for logged in user session
            if TWTRTwitter.sharedInstance().sessionStore.hasLoggedInUsers() {
                
                // opening composer controller to compose a tweet
                let composer = TWTRComposerViewController.emptyComposer()
                composer.delegate = self
                present(composer, animated: true, completion: nil)
                
            }
            
    }
    
    // MARK: Fetching logged in user data
    func fetchLoggedInUserDetails(client : TWTRAPIClient) {
        
        client.loadUser(withID: sessionUserId!, completion: { (user, error) in
            
            if let user = user {
                self.userNameLabel.text = user.screenName
                self.fullNameLabel.text = user.name
                
                guard let url = URL(string: user.profileImageLargeURL) else { return }
                
                guard let imageData = try? Data(contentsOf: url) else { return }
                
                let image = UIImage(data: imageData)
                
                self.userImageView.image = image
                
                
            } else {
                print("No data")
            }
            
        })
    }
    
    
    // MARK: Fetching logged in user tweets
    func fetchLoggedInUserTweets(client : TWTRAPIClient) {
        
        var error : NSError?
        
        let request = client.urlRequest(withMethod: "GET", urlString: "https://api.twitter.com/1.1/statuses/user_timeline.json", parameters: ["user_id" : sessionUserId!], error: &error)
        
        client.sendTwitterRequest(request) { (response, data, errorResponse) in
            
            
            if let response = response {
                print("the response is\(response)")
            } else {
                print("No response")
            }
            
            if let data = data {
                print(data)
                do {
                    
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print("the json data is \(json)")
                    
                } catch let jsonError as NSError{
                    
                    print("json error is \(jsonError)")
                }
            } else {
                print("data errpr")
            }
            
            
            if let errorReponse = errorResponse {
                print("got error response")
            }
            
        }
    }
    
}


// MARK: Tweet composer delegate methods
extension ViewController : TWTRComposerViewControllerDelegate {
    
    func composerDidSucceed(_ controller: TWTRComposerViewController, with tweet: TWTRTweet) {
        
        print("Tweet composed succeesfully !!")
    }
    
    
    func composerDidFail(_ controller: TWTRComposerViewController, withError error: Error) {
        
        print("Tweet compose failed !!")
    }
    
    func composerDidCancel(_ controller: TWTRComposerViewController) {
        
        print("Tweet compose cancelled !!")
    }
    
}

