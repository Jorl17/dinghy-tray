//
//  AskForPasswordHandler.swift
//  dinghy-tray
//
//  Created by João Ricardo Lourenço on 24/10/16.
//  Copyright © 2016 João Ricardo Lourenço. All rights reserved.
//

import Foundation
import Cocoa

class AskForPasswordViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
    @IBAction func okayPressed(sender: NSButton) {
        let password = sender.window?.contentView?.viewWithTag(0) as? NSSecureTextField;

        KeychainSwift().set((password?.stringValue)!, forKey: "dinghy-tray-sudo-password");
        //sender.window?.orderOut(nil);
        sender.window?.contentViewController?.dismiss(nil)
    }
    
    @IBAction func cancelPressed(sender: NSButton) {
        KeychainSwift().set("no_password", forKey: "dinghy-tray-sudo-password");
        sender.window?.contentViewController?.dismiss(nil)
    }
    
}
