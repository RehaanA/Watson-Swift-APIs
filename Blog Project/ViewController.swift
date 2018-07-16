//
//  ViewController.swift
//  Blog Project
//
//  Created by Rehaan Advani on 6/14/18.
//  Copyright © 2018 Rehaan Advani. All rights reserved.
//

import UIKit
import Starscream
import SpeechToTextV1
import ToneAnalyzerV3

class ViewController: UIViewController {
    var micBarButtonItem: UIBarButtonItem!
    var stopBarButtonItem: UIBarButtonItem!
    
    var speechToText: SpeechToText!
    var toneAnalyzer: ToneAnalyzer!
    
    var transcriptStr: String?
    let imageView = UIImageView()
    let label = UILabel()
    let initialLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initApiReferences()
        self.setupNavBar()
        self.addInitialLabel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func initApiReferences() {
        self.speechToText = SpeechToText(username: "9f367f2e-1071-4616-82e7-7a8ebe624a1a", password: "SGNLNSE0Bnum")
        self.toneAnalyzer = ToneAnalyzer(username: "4bd68057-9850-4aac-9b41-81371c298e0f", password: "Zdt7ddOLlI4D", version: "2018-06-18")
    }
    
    func setupNavBar() {
        self.title = "Watson Core Services"
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 44/255, green: 44/255, blue: 84/255, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.view.backgroundColor = UIColor.white
        
        self.micBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "mic"), style: .plain, target: self, action: #selector(self.barButtonTapped(sender:)))
        self.navigationItem.rightBarButtonItem = self.micBarButtonItem
    }
    
    @objc func barButtonTapped(sender: UIBarButtonItem) {
        self.stopBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "stop"), style: .plain, target: self, action: #selector(self.stopRecording(sender:)))
        self.navigationItem.rightBarButtonItem = self.stopBarButtonItem

        self.beginRecording()
    }
    
    func addInitialLabel() {
        self.initialLabel.text = "Press the microphone icon to get started!"
        self.initialLabel.textAlignment = .center
        self.initialLabel.numberOfLines = 0
        self.view.addSubview(self.initialLabel)
        
        self.initialLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: self.initialLabel, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0.75, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: self.initialLabel, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: self.initialLabel, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0.0))
    }
    
    func beginRecording() {
        self.initialLabel.alpha = 0
        var settings = RecognitionSettings(contentType: "audio/wav")
        settings.interimResults = true
        self.speechToText.recognizeMicrophone(settings: settings) { (results) in
            var accumulator = SpeechRecognitionResultsAccumulator()
            accumulator.add(results: results)
            self.transcriptStr = accumulator.bestTranscript
        }
    }
    
    @objc func stopRecording(sender: UIBarButtonItem) {
        self.micBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "mic"), style: .plain, target: self, action: #selector(self.barButtonTapped(sender:)))
        self.navigationItem.rightBarButtonItem = self.micBarButtonItem
        
        self.speechToText.stopRecognizeMicrophone()
        self.analyzeTone(str: self.transcriptStr)
    }
    
    func analyzeTone(str: String?) {
        if str != nil {
            self.toneAnalyzer.tone(text: str!) { (toneAnalysis) in
                let tones = toneAnalysis.documentTone.tones!
                if !tones.isEmpty {
                    let maxToneScore = tones.lazy.map{ $0.score }.max()
                    var maxToneScoreIndex = Int()
                    var i = 0
                    for tone in tones {
                        if tone.score == maxToneScore {
                            maxToneScoreIndex = i
                            break
                        }
                        i += 1
                    }
                    self.displayImageWithTone(toneStr: tones[maxToneScoreIndex].toneName)
                }
            }
        }
    }
    
    func imageAndText(tone: String) -> (UIImage, String) {
        switch tone {
        case "Anger":
            return (#imageLiteral(resourceName: "angry"), "Anger: WHY SO ANGRY?")
        case "Fear":
            return (#imageLiteral(resourceName: "angry"), "Fear: DON'T BE SCARED!")
        case "Joy":
            return (#imageLiteral(resourceName: "joy"), "Joy: SPREAD THE JOY!")
        case "Sadness":
            return (#imageLiteral(resourceName: "sadness"), "Sadness: DON'T BE SO BLUE!")
        case "Disgust":
            return (#imageLiteral(resourceName: "disgust"), "Disgust: THAT WAS REVOLTING")
        case "Analytical":
            return (#imageLiteral(resourceName: "analytical"), "Analytical: TRANSFER SOME OF YOUR KNOWLEDGE TO ME!")
        case "Confident":
            return (#imageLiteral(resourceName: "confident"), "Confident: YOUR CONFIDENCE IS CONTAGIOUS!")
        case "Tentative":
            return (#imageLiteral(resourceName: "tentative"), "Tentative: DON'T BE HESITANT!")
        default:
            return (UIImage(), "Unknown emotion")
        }
    }
    
    func displayImageWithTone(toneStr: String) {
        let image = self.imageAndText(tone: toneStr).0
        let str = self.imageAndText(tone: toneStr).1
        DispatchQueue.main.async {
            self.imageView.image = image
            self.imageView.alpha = 1
            self.view.addSubview(self.imageView)
            
            self.imageView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addConstraint(NSLayoutConstraint(item: self.imageView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0))
            self.view.addConstraint(NSLayoutConstraint(item: self.imageView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: -50))
            self.view.addConstraint(NSLayoutConstraint(item: self.imageView, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0.0, constant: 100.0))
            self.view.addConstraint(NSLayoutConstraint(item: self.imageView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0.0, constant: 100.0))
            
            
            self.label.text = str
            self.label.textAlignment = .center
            self.label.numberOfLines = 0
            self.view.addSubview(self.label)
            
            self.label.translatesAutoresizingMaskIntoConstraints = false
            self.view.addConstraint(NSLayoutConstraint(item: self.label, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0.75, constant: 0.0))
            self.view.addConstraint(NSLayoutConstraint(item: self.label, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0))
            self.view.addConstraint(NSLayoutConstraint(item: self.label, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 50))
        }
    }
}
