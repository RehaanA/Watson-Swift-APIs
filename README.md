# Watson-Swift-APIs
During my internship at IBM, one of my tasks was to create technical blog posts to help developers get started with IBM Watson iOS APIs. This project attempts to implement several of those APIs and in another repo, I highlight my entire article.

# Article:

# Get Kickstarted with IBM Watson's Swift APIs 

Have you always wanted to learn more about how to integrate some of Watson's awesome API's in your iOS app? Well, if you have, this is the right blog for you! After reading this blog, here is what you should be able to do:

* **Set up a basic application using Swift**

* **Incorporate the Speech to Text and Tone Analyzer APIs**

* **Get familiarized with the command line**

Additionally, here is what you need to have installed before getting started:

* **Homebrew**

* **Carthage**

* **The latest version of Xcode**

* **Swift 4.0+**

Finally, here are some prerequisite skills that you should have before getting started:

* **Proficient with the Swift programming language**

* **Familar with the Xcode IDE**

The app that we are going to create is a simple one that accepts speech as an input from the user, which is then analyzed for tone, and then a cool face with the emotion returned will be displayed on the screen.

**Estimated Time:** This how-to article should take from anywhere between 1 and 2 hours to complete with a functioning app at the end. 

## Setup

In order to get started, go ahead and create a new single view application in Xcode. You should be able to see the same screen as depicted in the screenshot below. 

![](https://github.com/RehaanA/Technical-Content-Creation-Blog-Post/blob/master/Blog%20Project%20Screenshots/Initial%20Project%20Setup.png)

Once your application is set up, we need to install and embed the frameworks that we want to use: Tone Analyzer and Speech to Text. First, within the Xcode project itself, navigate to preferences. Under the locations tab, set the option "Command Line Tools" to the latest version of Xcode that you have installed. This will ensure we have no problems installing the relevant frameworks. Please look at the screenshot below for reference.  

![](https://github.com/RehaanA/Technical-Content-Creation-Blog-Post/blob/master/Blog%20Project%20Screenshots/Xcode%20CLT.png)

Now, we are ready to install all of the necessary frameworks. First, go ahead and install Homebrew using the following link for instructions: http://brew.sh/. Then, install Carthage by entering these two commands in terminal:
```
brew update
brew install carthage
```
Then, navigate to the root directory of your project (where your .xcodeproj is located) and create an empty Cartfile there:
```
touch Cartfile
```

To use the Watson Developer Cloud Swift SDK in your application, specify it in your Cartfile:
```
github "watson-developer-cloud/swift-sdk"
```

Finally, run the following command to build the dependencies and frameworks:
```
carthage update --platform iOS
```

In addition to installing the dependencies via terminal, we also need to create a service instance on the IBM Cloud dashboard. Here are the following steps to do that:

1. Log in to IBM Cloud at https://bluemix.net
2. Create a service instance:
   * From the dashboard, select "Use Services or APIs"
   * Select the service you want to use
   * Click "Create"
3. Copy your service credentials:
   * Click "Service Credentials" on the left side of the page 
   * Copy service's username and password 

Finally, we have to import the frameworks into the Xcode project itself. First, open up a new finder window and navigate to the directory of your project. Next, go into the Carthage folder, then the iOS folder, and you should see all of the Watson frameworks. Then, in the Xcode project, open up the "Build Phases" tab and you should be able to see the "Link Binary with Libraries" drop down. Drag and drop the Starscream, Tone Analyzer, and Speech to Text frameworks from the finder window into the dropdown. In addition, do the same for the "Embedded Binaries" drop down under the "General" tab. Follow the screenshots below if you are having some trouble with this:

![](https://github.com/RehaanA/Technical-Content-Creation-Blog-Post/blob/master/Blog%20Project%20Screenshots/Installation/Screen%20Shot%202018-06-18%20at%209.55.20%20AM.png)

![](https://github.com/RehaanA/Technical-Content-Creation-Blog-Post/blob/master/Blog%20Project%20Screenshots/Installation/Screen%20Shot%202018-06-18%20at%209.55.24%20AM.png)

![](https://github.com/RehaanA/Technical-Content-Creation-Blog-Post/blob/master/Blog%20Project%20Screenshots/Installation/Screen%20Shot%202018-06-18%20at%209.55.26%20AM.png)

![](https://github.com/RehaanA/Technical-Content-Creation-Blog-Post/blob/master/Blog%20Project%20Screenshots/Installation/Screen%20Shot%202018-06-18%20at%209.55.32%20AM.png)

![](https://github.com/RehaanA/Technical-Content-Creation-Blog-Post/blob/master/Blog%20Project%20Screenshots/Installation/Screen%20Shot%202018-06-18%20at%209.56.03%20AM.png)

![](https://github.com/RehaanA/Technical-Content-Creation-Blog-Post/blob/master/Blog%20Project%20Screenshots/Installation/Screen%20Shot%202018-06-20%20at%209.40.07%20AM.png)

## Implementation

To get started, let's first start by creating a simple navigation bar. In the ViewController.swift file, we are going to add a method called setupNavBar. The implementation is as follows:
``` swift
func setupNavBar( ) {
    self.title = "Watson Core Services"        
    self.navigationController?.navigationBar.barStyle = .black        
    self.navigationController?.navigationBar.barTintColor = UIColor(red: 44/255, green: 44/255, blue: 84/255, alpha: 1.0)        
    self.navigationController?.navigationBar.tintColor = UIColor.white        
    self.view.backgroundColor = UIColor.white                
  
    self.micBarButtonItem = UIBarButtonItem(image:  #imageLiteral(resourceName: "mic"), style: .plain, target: self, action:           #selector(self.barButtonTapped(sender:)))       
    self.navigationItem.rightBarButtonItem = self.micBarButtonItem
}

func barButtonTapped(sender: UIBarButtonItem) {

}
```
In addition, within the ```didFinishLaunchingWithOptions``` in the AppDelegate file, implement the following two lines of code to ensure the navigation bar will show up and that the root view controller is set:
```swift
let navigationController = UINavigationController(rootViewController: ViewController())
window?.rootViewController = navigationController
```

I chose to title this page "Watson Core Services," but you can pick any title that you want! In addition, make sure to declare a variable at the top of the ViewController file called ```micBarButtonItem``` of type ```UIBarButtonItem``` and don't forget to call this function in the ```viewDidLoad``` method! Go ahead and build and run the application. You should see something like this:

![](https://github.com/RehaanA/Technical-Content-Creation-Blog-Post/blob/master/Blog%20Project%20Screenshots/Screen%20Shot%202018-06-20%20at%209.23.47%20AM.png)

Next, we need to make references to the service instances that we created earlier on bluemix. To do that, let's create a method called ```initApiReferences``` and call it in the ```viewDidLoad``` method. Also, don't forget to import ```Starscream```, ```SpeechToTextV1```, and ```ToneAnalyzerV3``` at the top of the file. Below is the implementation:
```swift
func initApiReferences( ) {
    self.speechToText = SpeechToText(username: "USERNAME", password: "PASSWORD")        
    self.toneAnalyzer = ToneAnalyzer(username: "USERNAME", password: "PASSWORD", version: "YYYY-MM-DD")
}
```
Refer to your bluemix dashboard to obtain the username and passwords for each service instance you created and then fill in the blanks in the method above.

Next, let's complete the implementation of the method barButtonTapped that we created earlier. Essentially, when this button is tapped, we want the image to change to indicate that the device is recording and then actually begin recording what the user begins talking. Below is the implementation that we will use:
```swift
func barButtonTapped(sender: UIBarButtonItem) {
    self.stopBarButtonItem = UIBarButtonItem(image:  imageLiteral(resourceName: "stop"), style: .plain, target: self, action: #selector(self.stopRecording(sender:)))
    self.navigationItem.rightBarButtonItem = self.stopBarButtonItem

    self.beginRecording()
}

func stopRecording(sender: UIBarButtonItem) {

}

func beginRecording() {

}
```
As you can see, we are using a new bar button item called ```stopBarButtonItem```. Be sure to declare at at the top of this file along with the other variables that we are using. What we need to do next is work on the ```beginRecording``` method. Essentially, what we are going to do is recognize the microphone, log the results, and obtain the best transcript that is returned. In this particular method, we are storing the ```bestTranscript``` in the property that was declared called ```transcriptStr```, of type String. Below is the implementation of this method:
```swift
func beginRecording() {
    var settings = RecognitionSettings(contentType: "audio/wav")
    settings.interimResults = true
    self.speechToText.recognizeMicrophone(settings: settings) { (results) in
         var accumulator = SpeechRecognitionResultsAccumulator()
         accumulator.add(results: results)
         self.transcriptStr = accumulator.bestTranscript
     }
}
```
Now we are ready to implement the ```stopRecording``` method. When the user taps on the stop record button, we need to update the bar button once again, tell the Speech to Text API to stop recognizing the microphone, and then analyze the tone of the transcript using the Tone Analyzer API. Below is the implementation:
```swift
func stopRecording(sender: UIBarButtonItem) {
    self.micBarButtonItem = UIBarButtonItem(image:  imageLiteral(resourceName: "mic"), style: .plain, target: self, action:   #selector(self.barButtonTapped(sender:)))       
    self.navigationItem.rightBarButtonItem = self.micBarButtonItem                
    self.speechToText.stopRecognizeMicrophone()        
    self.analyzeTone(str: self.transcriptStr)
}

func analyzeTone(str: String?) {

}
```
Now for the fun stuff! The Tone Analyzer framework is so intricately crafted with many, many layers. So first, it is important to understand the class hierarchy before we begin with this method. Below is the hierarchy:

**Tone Analysis**
  * **document_tone: Document Analysis**
    * **tones: ToneScore[]**
      * **score: double**
      * **tone_id: string**
      * **tone_name: string**
    * **tone_categories: ToneCategory[]**
      * **tones: ToneScore[]**
      * **category_id: string**
      * **category_name: string**
    * **warning: string**
  * **sentences_tone: Sentence Analysis**
    * **sentence_id: Integer**
    * **text: string**
    * **tones: ToneScore[]**
    * **tone_categories: ToneCategory[]**
    * **input_from: Integer**
    * **input_to: Integer**
 

We are going to start with an instance of Tone Analysis and access the document_tone property where we can get the array of tones and within each index, the corresponding score and name. Essentially, Watson compiles a list of multiple tones that most closely match with the transcript provided. We need to find the tone with the highest score. Below is the implementation: 
```swift
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
```
So let's go through this method step by step by starting with the function header. It is important that we declare str as an optional String, because if the user does not say anything into the microphone, we would be passing nil. Next, we call the function tone and we have access to a ```toneAnalysis``` property within the resulting closure. Using that property, we access the tones array and obtain the highest tone score. Then, we loop through the array and find the corresponding index of that tone so that we can access its name. Finally, we call the ```displayImageWithTone``` method which we will discuss below.
```swift
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
```
This is a very basic method. We are simply displaying an image view and a label in the middle of the screen using auto layout and constraints. This is Apple's way of scaling user interfaces with all of the different screen sizes within the Apple ecosystem. Within this function we are calling one other method, ```imageAndText```, which accepts a String as an input and the correct image and text are returned depending on the toneName in the form of a tuple. Their implementations are below: 
```swift
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
```
  
Phew! We are all done! See, it was super easy!

Here are a couple of screenshots of the final product:

![](https://github.com/RehaanA/Technical-Content-Creation-Blog-Post/blob/master/Blog%20Project%20Screenshots/Screen%20Shot%202018-07-23%20at%2011.42.31%20AM.png)

![](https://github.com/RehaanA/Technical-Content-Creation-Blog-Post/blob/master/Blog%20Project%20Screenshots/Screen%20Shot%202018-07-23%20at%2011.42.37%20AM.png) 

## Takeaways

In conclusion, here are the objectives that you should have met by completing this project:

* Set up a basic Swift application using Xcode
* Download and install frameworks into Xcode while using terminal
* Make use of the Tone Analyzer and Speech to Text frameworks
* Learn more about UIKit
* Have fun!

## Resources

* https://github.com/watson-developer-cloud/swift-sdk
* https://www.ibm.com/watson/developercloud/tone-analyzer/api/v3/curl.html?curl#tone
* https://console.bluemix.net/docs/services/tone-analyzer/developer-overview.html#overviewDevelopers

Additionally, here is the link to all the code in a Github repository: https://github.com/RehaanA/Watson-Swift-APIs
