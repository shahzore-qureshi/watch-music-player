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
import Alamofire

class InterfaceController: WKInterfaceController {
    
    var audioSession: AVAudioSession? = nil
    var audioPlayer: AVAudioPlayer? = nil
    var player: WKAudioFilePlayer? = nil
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession?.setCategory(
                AVAudioSession.Category.playback,
                mode: .default,
                policy: .longForm,
                options: []
            )
        } catch {
            fatalError("Unable to set up audio session")
        }
        
        Alamofire
            .request(
                "https://p.scdn.co/mp3-preview/57a406db240923c9291d8e2534ec3572646629fc?cid=a46f5c5745a14fbf826186da8da5ecc3"
            )
            .responseData { response in
                print("Request: \(String(describing: response.request))")   // original url request
                print("Response: \(String(describing: response.response))") // http url response
                print("Data: \(String(describing: response.result.value))") // http url data

                let fileManager = FileManager.default
                let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.shahzorequreshi.music")
                print("Directory: \(String(describing: directory))")
                
                let path = directory?.appendingPathComponent("test.mp3")
                if(path != nil) {
                    let wasFileCreated = fileManager.createFile(
                        atPath: path!.path,
                        contents: response.result.value!,
                        attributes: nil
                    )
                    print("Path: \(String(describing: path!.path))")
                    print("Was File Created? \(String(describing: wasFileCreated))")
                    
                    if(wasFileCreated) {
                        self.playMusic(path: path!)
                    }
                }
            }
    }
    
    func playMusic(path: URL) {
        let audioAsset = WKAudioFileAsset.init(
            url: path,
            title: "Disco",
            albumTitle: "70s hits",
            artist: "Giorgio"
        )
        let playerItem = WKAudioFilePlayerItem.init(asset: audioAsset)
        player = WKAudioFilePlayer.init(playerItem: playerItem)
        player?.addObserver(self, forKeyPath: "status", options: [], context: nil)
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if(player?.status == WKAudioFilePlayerStatus.readyToPlay) {
            print("ready to play")
            self.audioSession?.activate(options: []) { (success, error) in
                guard error == nil else {
                    print("*** An error occurred: \(error!.localizedDescription) ***")
                    // Handle the error here.
                    return
                }
                
                // Play the audio file.
                self.player?.play()
            }
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}
