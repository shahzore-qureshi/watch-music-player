//
//  InterfaceController.swift
//  MusicPlayer WatchKit Extension
//
//  Created by shahzore.qureshi on 11/8/18.
//  Copyright © 2018 shahzore.qureshi. All rights reserved.
//

import WatchKit
import Foundation
import AVFoundation

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var button: WKInterfaceButton!
    var buttonLabel: String = "Ring!"
    
    var audioSession: AVAudioSession? = nil
    var audioPlayer: AVAudioPlayer? = nil
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession?.setCategory(
                AVAudioSession.Category.playback,
                mode: .default,
                policy: .default,
                options: []
            )
        } catch {
            fatalError("Unable to set up audio session")
        }
        
        do {
            let songPath = Bundle.main.path(forResource: "chicken", ofType: "wav")!
            print("songpath: \(songPath)")
            let songURL = URL(fileURLWithPath: songPath)
            audioPlayer = try AVAudioPlayer(contentsOf: songURL)
        } catch {
            fatalError("Unable to set up player")
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        button.setTitle("Ring!")
    }
    
    @IBAction func onButtonClick() {
        if(buttonLabel == "Ring!") {
            buttonLabel = "Ringing..."
        } else {
            buttonLabel = "Ring!"
        }
        button.setTitle(buttonLabel)
        
        audioSession?.activate(options: []) { (success, error) in
            guard error == nil else {
                print("*** An error occurred: \(error!.localizedDescription) ***")
                // Handle the error here.
                return
            }
            
            // Play the audio file.
            self.audioPlayer?.play()
        }
    }
}
