//
//  ViewController.swift
//  Twitter Anlyzr
//
//  Created by Nathan Festoso on 2019-02-18.
//  Copyright © 2019 Binary Machine Inc. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController, UITextFieldDelegate {
    
    // Number of tweets to be analyzed
    private let tweetCount = 100
    // CreateML Emotion analyzer
    private let sentimentClassifier = TweetSentimentClassifier()
    // Twitter API keys
    private let swifter = Swifter(
        consumerKey: "zrEbjnYoKeSRFsqxFzGQ1p3xb",
        consumerSecret: "eR75qayqIWj6UgEhlGheOVGPWxof4voyl76iygrk0vrJ9fAzyk"
    )
    
    @IBOutlet weak var emotionLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    
    //MARK: - App Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
    }
    
    
    //MARK: - UI Methods
    
    @IBAction func analyzeButton(_ sender: Any) {
        if let search = textField.text {
            fetchTweets(using: search)
        }
    }
    
    func updateUI(with score: Int) {
        if score > 20 {
            self.emotionLabel.text = "😍"
        } else if score > 10 {
            self.emotionLabel.text = "😁"
        } else if score > 2 {
            self.emotionLabel.text = "🙂"
        } else if score > -2 {
            self.emotionLabel.text = "😐"
        } else if score > -10 {
            self.emotionLabel.text = "😕"
        } else if score > -20 {
            self.emotionLabel.text = "😡"
        } else {
            self.emotionLabel.text = "🤮"
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //MARK: - AI Analysis Methods
    
    func fetchTweets(using search: String) {
        swifter.searchTweet(using: search, lang: "en", count: tweetCount, tweetMode: .extended, success: { (results, metadata) in
            
            var tweets = [TweetSentimentClassifierInput]()
            
            for i in 0 ..< self.tweetCount {
                if let tweet = results[i]["full_text"].string {
                    let tweenInput = TweetSentimentClassifierInput(text: tweet)
                    tweets.append(tweenInput)
                }
            }
            self.makePrediction(with: tweets)
        }) { (error) in
            print("Error making request to Twitter API: \(error)")
        }
    }
    
    
    func makePrediction(with tweets: [TweetSentimentClassifierInput]) {
        do {
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            var score = 0
            
            for pred in predictions {
                let emotion = pred.label
                
                if emotion == "Pos" { score += 1 }
                else if emotion == "Neg" { score -= 1 }
            }
            updateUI(with: score)
        } catch {
            print(error)
        }
    }
    
    
}
