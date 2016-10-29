//
//  Script.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 12/05/15.
//  Copyright (c) 2015 Honza Dvorsky. All rights reserved.
//

import Foundation


extension String {
    
    func stringByAppendingPathComponent(path: String) -> String {
        
        let nsSt = self as NSString
        
        return nsSt.stringByAppendingPathComponent(path)
    }
}

/**
 *   Utility class for running terminal Scripts from your Mac app.
 */
public class Script {
    
    public typealias ScriptResponse = (terminationStatus: Int, standardOutput: String, standardError: String)
    
    /**
     *   Run a script by passing in a name of the script (e.g. if you use just 'git', it will first
     *   resolve by using the 'git' at path `which git`) or the full path (such as '/usr/bin/git').
     *   Optional arguments are passed in as an array of Strings and an optional environment dictionary
     *   as a map from String to String.
     *   Back you get a 'ScriptResponse', which is a tuple around the termination status and outputs (standard and error).
     */
    public class func run(name: String, arguments: [String] = [], environment: [String: String] = [:]) -> ScriptResponse {
        
        //first resolve the name of the script to a path with `which`
        let resolved = self.runResolved(path: "/usr/bin/which", arguments: [name], environment: [:])
        
        //which returns the path + \n, so strip the newline
        var path = resolved.standardOutput.stripTrailingNewline()
        
        //if resolving failed, just abort and propagate the failed run up
        if (resolved.terminationStatus != 0 /*|| (count(path) == 0*/) {
            return resolved
        }
        
        //ok, we have a valid path, run the script
        let result = self.runResolved(path: path, arguments: arguments, environment: environment)
        return result
    }
    
    /**
     *   An alternative to Script.run is Script.runInTemporaryScript, which first dumps the passed in script
     *   string into a temporary file, runs it and then deletes it. More useful for more complex script that involve
     *   piping data between multiple scripts etc. Might be slower than Script.run, however.
     */
    public class func runTemporaryScript(script: String) -> ScriptResponse {
        
        var resp: ScriptResponse!
        self.runInTemporaryScript(script: script, block: { (scriptPath, error) -> () in
            resp = Script.run(name: "/bin/bash", arguments: [scriptPath])
        })
        return resp
    }
    
    private class func runInTemporaryScript(script: String, block: (_ scriptPath: String, _ error: NSError?) -> ()) {
        
        let uuid = NSUUID().uuidString
        let tempPath = NSTemporaryDirectory().stringByAppendingPathComponent(path: uuid)
        var error: NSError?
        
        //write the script to file
        let success = script.writeToFile(tempPath, atomically: true, encoding: NSUTF8StringEncoding)
        
        block(tempPath, error)
        
        //delete the temp script
        FileManager.defaultManager.removeItemAtPath(tempPath, error: nil)
    }
    
    private class func runResolved(path: String, arguments: [String], environment: [String: String]) -> ScriptResponse {
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        let outputFile = outputPipe.fileHandleForReading
        let errorFile = errorPipe.fileHandleForReading
        
        let task = Process()
        task.launchPath = path
        task.arguments = arguments
        
        var env = ProcessInfo.processInfo.environment
        for (var index, keyValue) in environment.enumerated() {
            env[keyValue.0] = keyValue.1
        }
        task.environment = env
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        task.launch()
        task.waitUntilExit()
        
        let terminationStatus = Int(task.terminationStatus)
        let output = self.stringFromFileAndClose(outputFile)
        let error = self.stringFromFileAndClose(errorFile)
        
        return (terminationStatus, output, error)
    }
    
    private class func stringFromFileAndClose(file: FileHandle) -> String {
        
        let data = file.readDataToEndOfFile()
        file.closeFile()
        let output = NSString(data: data, encoding: NSUTF8StringEncoding) as String?
        return output ?? ""
    }
}

public extension String {
    
    public func stripTrailingNewline() -> String {
        
        var stripped = self
        if stripped.hasSuffix("\n") {
            stripped.removeAtIndex(stripped.endIndex.predecessor())
        }
        return stripped
    }
}
