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
    var micBooster: AKBooster?
    var tracker: AKFrequencyTracker?
    var silence: AKBooster?
    var recorder: AKNodeRecorder?
   
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

        tracker = AKFrequencyTracker(mic!)
        silence = AKBooster(tracker!)
        silence!.gain = 0

        AudioKit.output = micBooster

        if !RecordController.didStartAudioKit {
            AudioKit.start()
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        inputPlot = AKNodeOutputPlot(mic!, frame: CGRect.zero)
        inputPlot?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputPlot!)

        inputPlot?.pinEdge(.top, toEdge: .top, ofItem: view, inset: 50)
        inputPlot?.pinEdges([.left, .right], toSameEdgesOf: view)
        
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.setTitle("start recording", for: .normal)
        recordButton.setTitleColor(UIColor.black, for: .normal)
        recordButton.addTarget(self, action: #selector(ViewController.didPressRecordButton), for: .touchUpInside)
        view.addSubview(recordButton)
        
        recordButton.pinEdge(.bottom, toEdge: .bottom, ofItem: view, inset: -50)
        recordButton.pinEdges([.left, .right], toSameEdgesOf: view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
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
            
            recorder?.stop()
            
            recorder?.audioFile?.exportAsynchronously(name: "foo.m4a", baseDir: .documents, exportFormat: .m4a, callback: { (processedFile, error) in
                
                debugPrint(processedFile as Any)
                debugPrint(error as Any)
                
                guard let url = processedFile?.url else { return }
                
                self.onFinish?(url)
            })
            
        } else {
            
            recordButton.setTitle("stop recording", for: .normal)
            
            _ = try? recorder?.record()
        }
    }
}
