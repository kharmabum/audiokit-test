//
//  ViewController.swift
//  audiokit-test
//
//  Created by Juan-Carlos Foust on 1/17/17.
//  Copyright © 2017 Juan-Carlos Foust. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController {
    
    let urlLabel = UILabel()
    
    let recordButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        urlLabel.translatesAutoresizingMaskIntoConstraints = false
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        
        urlLabel.text = "no information to report"
        urlLabel.textColor = UIColor.black
        urlLabel.numberOfLines = 0
        
        recordButton.setTitle("press to record", for: .normal)
        recordButton.setTitleColor(UIColor.black, for: .normal)
        recordButton.addTarget(self, action: #selector(ViewController.didPressRecordButton), for: .touchUpInside)
        
        view.backgroundColor = UIColor.white
        view.addSubview(urlLabel)
        view.addSubview(recordButton)

        urlLabel.pinEdge(.top, toEdge: .top, ofItem: view, inset: 50)
        urlLabel.pinEdge(.left, toEdge: .left, ofItem: view, inset: 50)
        urlLabel.pinEdge(.right, toEdge: .right, ofItem: view, inset: -20)
        
        recordButton.pinEdge(.bottom, toEdge: .bottom, ofItem: view, inset: -50)
        recordButton.pinEdges([.left, .right], toSameEdgesOf: view)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        _ = try? AKSettings.setSession(category: .ambient)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController {
    
    func didPressRecordButton() {
        
        let recordVC = RecordController()
        recordVC.onFinish = { url in
        
            
            var summary = ""
            summary += "location: \(url)\n\n"
            summary += "bytes: \(url.fileSize)"
            self.urlLabel.text = summary
            self.dismiss(animated: true, completion: nil)
            
            _ = try? RecordController.player?.reloadFile()
            RecordController.player?.play()

        }
        
        RecordController.player?.stop()
        present(recordVC, animated: true)
    }
}


extension URL {
    
    var fileSize: Int {
        return ((try? FileManager.default.attributesOfItem(atPath: self.path))?[FileAttributeKey.size] as? NSNumber)?.intValue ?? 0
    }
    
    static func applicationCachesDirectory() -> URL {
        
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
