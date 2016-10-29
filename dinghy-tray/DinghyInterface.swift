//
//  DinghyInterface.swift
//  dinghy-tray
//
//  Created by João Ricardo Lourenço on 23/10/16.
//  Copyright © 2016 João Ricardo Lourenço. All rights reserved.
//

import Foundation

class DinghyInterface: NSObject {
    func version() -> String {
        let (output, status) = shell("dinghy version");
        
        if status != 0 {
            return "Not Installed";
        }
        else {
            return output!.components(separatedBy: " ")[1].trimmingCharacters(in: .whitespaces);
        }
    }
    
    func running() -> Bool {
        let (VM,_,_,_) = self.status();
        return VM.range(of:"running") != nil;
    }
    
    func restart() -> String {
        let (output, _) = shellWithSudoRights("dinghy restart", password: KeychainSwift().get("dinghy-tray-sudo-password")!);
        return output!;
    }
    
    func start() -> String {
        let (output, _) = shellWithSudoRights("dinghy up", password: KeychainSwift().get("dinghy-tray-sudo-password")!);
        return output!;
    }
    
    func stop() -> String {
        let (output, _) = shellWithSudoRights("dinghy stop", password: KeychainSwift().get("dinghy-tray-sudo-password")!);
        return output!;
    }
    
    func status() -> (String, String, String, String) {
        let (output, _) = shell("dinghy status")
        
        let parts : [String] = output!.components(separatedBy: "\n");
        let VM =    parts[0].trimmingCharacters(in: .whitespaces);
        let NFS =   parts[1].trimmingCharacters(in: .whitespaces);
        let FSV =   parts[2].trimmingCharacters(in: .whitespaces);
        let PROXY = parts[3].trimmingCharacters(in: .whitespaces);
        
        return (VM,NFS,FSV,PROXY);
    }
    
    func ip() -> String {
        let (output, _) = shell("dinghy ip");
        
        return output!;
    }
    
}
