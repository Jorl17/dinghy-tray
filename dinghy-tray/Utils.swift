//
//  Utils.swift
//  dinghy-tray
//
//  Created by João Ricardo Lourenço on 23/10/16.
//  Copyright © 2016 João Ricardo Lourenço. All rights reserved.
//

import Foundation


// Adapted from http://stackoverflow.com/a/39364135
// FIXME: This is quite disgusting but what else can you do when Swift bites you?
func shell(_ cmd: String) -> (String? , Int32) {
    let task = Process()
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", "PATH=/usr/local/bin:$PATH;" + cmd];
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    task.launch()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: String.Encoding.utf8)
    task.waitUntilExit()
    return (output, task.terminationStatus)
}

func shellWithSudoRights(_ cmd: String, password: String) -> (String? , Int32) {
    return shell("echo \"\"\""+password+"\n\"\"\" | sudo -S echo make me a sandwich ; " + cmd)
}
