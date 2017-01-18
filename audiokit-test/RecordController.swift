//
//  RecordController.swift
//  audiokit-test
//
//  Created by Juan-Carlos Foust on 1/17/17.
//  Copyright © 2017 Juan-Carlos Foust. All rights reserved.
//

import Foundation
import AudioKit

class RecordController: UIViewController {
    
    static var didStartAudioKit: Bool = false

    var mic: AKMicrophone?
    var micMixer: AKMixer?
    var recorder: AKNodeRecorder?
    var player: AKAudioPlayer?
    var micBooster: AKBooster?
   
    var onFinish: ((URL) -> Void)?

    let recordButton = UIButton()
    
    var inputPlot: AKNodeOutputPlot?
    
    // MARK: UIViewController
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        _ = try? AKSettings.setSession(category: .playAndRecord, with: .defaultToSpeaker)
        
        mic = AKMicrophone()
        micMixer = AKMixer(mic!)
        micBooster = AKBooster(micMixer!)
        micBooster!.gain = 0
        recorder = try? AKNodeRecorder(node: micMixer!)
        let mainMixer = AKMixer(micBooster!)
        
        if !RecordController.didStartAudioKit {
            AudioKit.output = mainMixer
            AudioKit.start()
            RecordController.didStartAudioKit = true
        } else {
            AudioKit.stop()
            AudioKit.output = mainMixer
            AudioKit.start()
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.setTitle("start recording", for: .normal)
        recordButton.setTitleColor(UIColor.black, for: .normal)
        recordButton.addTarget(self, action: #selector(ViewController.didPressRecordButton), for: .touchUpInside)
        view.addSubview(recordButton)
        recordButton.pinEdge(.bottom, toEdge: .bottom, ofItem: view, inset: -50)
        recordButton.pinEdges([.left, .right], toSameEdgesOf: view)
        
        inputPlot = AKNodeOutputPlot(mic!, frame: CGRect(x: 0, y: 0, width: view.width, height: 100)) // inputPlot.node = mic
        view.addSubview(inputPlot!)
        
        inputPlot?.alignHorizontally(.center, vertically: .top)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        didPressRecordButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
    }
}

extension RecordController {
    
    func didPressRecordButton() {

        if recorder?.isRecording == true {

            micBooster!.gain = 0
            
            let recordedDuration = recorder!.audioFile!.duration
            
            if recordedDuration > 0.0 {
                recorder?.stop()
                
                var fileUrl = recorder!.audioFile!.url
                let urlComponents = NSURLComponents(url: fileUrl, resolvingAgainstBaseURL: true)!
                urlComponents.scheme = "file"
                fileUrl = urlComponents.url!

                
                let cacheUrl = URL.applicationCachesDirectory().appendingPathComponent("\(UUID().uuidString).caf")
                _ = try? FileManager.default.moveItem(at: fileUrl, to: cacheUrl)
                print(cacheUrl)
                
                onFinish?(cacheUrl)
            }
        } else {
            
            recordButton.setTitle("stop recording", for: .normal)
            
            do {
                try recorder?.record()
            } catch {
                print("failed to begin recording: \(error)")
            }
        }
    }
}
