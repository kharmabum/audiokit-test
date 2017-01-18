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
    
    static var mic: AKMicrophone?
    static var micMixer: AKMixer?
    static var recorder: AKNodeRecorder?
    static var micBooster: AKBooster?
    static var mainMixer: AKMixer?

    static func configure() {
        mic = AKMicrophone()
        micMixer = AKMixer(mic!)
        recorder = try? AKNodeRecorder(node: micMixer!)
        micBooster = AKBooster(micMixer!)
        micBooster!.gain = 0
        mainMixer = AKMixer(micBooster!)
        AudioKit.output = mainMixer
        AudioKit.start()
    }
   
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
        
        RecordController.mic?.start()
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
        
        inputPlot = AKNodeOutputPlot(RecordController.mic!, frame: CGRect(x: 0, y: 0, width: view.width, height: 100)) // inputPlot.node = mic
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

        if RecordController.recorder?.isRecording == true {

            RecordController.micBooster!.gain = 0
            
            let recordedDuration = RecordController.recorder!.audioFile!.duration
            
            if recordedDuration > 0.0 {
                RecordController.recorder?.stop()
                RecordController.mic?.stop()
                
                var fileUrl = RecordController.recorder!.audioFile!.url
                let urlComponents = NSURLComponents(url: fileUrl, resolvingAgainstBaseURL: true)!
                urlComponents.scheme = "file"
                fileUrl = urlComponents.url!

                
                let cacheUrl = URL.applicationCachesDirectory().appendingPathComponent("\(UUID().uuidString).caf")
                _ = try? FileManager.default.copyItem(at: fileUrl, to: cacheUrl)
                print(cacheUrl)
                
                onFinish?(cacheUrl)
                _ = try? RecordController.recorder?.reset()
            }
        } else {
            
            recordButton.setTitle("stop recording", for: .normal)
            
            do {
                try RecordController.recorder?.record()
            } catch {
                print("failed to begin recording: \(error)")
            }
        }
    }
}
