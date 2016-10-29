//
//  AppDelegate.swift
//  dinghy-tray
//
//  Created by João Ricardo Lourenço on 14/10/16.
//  Copyright © 2016 João Ricardo Lourenço. All rights reserved.
//

import Cocoa



@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusBar = NSStatusBar.system()
    var statusBarItem : NSStatusItem = NSStatusItem()
    var menu: NSMenu = NSMenu()
    var dinghy: DinghyInterface = DinghyInterface()
    
    func startDinghy(sender: AnyObject) {
        self.menuAppStatus.title = "Dinghy-tray status: starting dinghy...";
        DispatchQueue.global(qos: .background).async {
            let out = self.dinghy.start();
            
            DispatchQueue.main.async {
                self.menuAppStatus.title = "Dinghy-tray status: OK";
                self.updateInBackground();
                print(out);
            }
        }
    }
    
    func restartDinghy(sender: AnyObject) {
        self.menuAppStatus.title = "Dinghy-tray status: restarting dinghy...";
        DispatchQueue.global(qos: .background).async {
            let out = self.dinghy.restart();
            
            DispatchQueue.main.async {
                self.menuAppStatus.title = "Dinghy-tray status: OK";
                self.updateInBackground();
            }
        }
    }
    
    func stopDinghy(sender: AnyObject) {
        self.menuAppStatus.title = "Dinghy-tray status: stopping dinghy...";
        DispatchQueue.global(qos: .background).async {
            let out = self.dinghy.stop();
            
            DispatchQueue.main.async {
                self.menuAppStatus.title = "Dinghy-tray status: OK";
                self.updateInBackground();
            }
        }
    }
    
    func about(sender: AnyObject) {
        NSLog("Hello world!"); //FIXME
    }
    
    func quit(sender: AnyObject) {
        NSApplication.shared().terminate(self);
    }
    
    func changeSudo(sender: AnyObject) {
        let viewController = NSStoryboard(name: "AskForPassword", bundle: nil).instantiateController(withIdentifier: "ViewController") as! AskForPasswordViewController;
        viewController.presentViewControllerAsModalWindow(viewController);
    }
    
    var menuStatus : NSMenuItem = NSMenuItem(),
        menuVM : NSMenuItem = NSMenuItem(),
        menuNFS : NSMenuItem = NSMenuItem(),
        menuFSV : NSMenuItem = NSMenuItem(),
        menuPROXY : NSMenuItem = NSMenuItem(),
        menuIP : NSMenuItem = NSMenuItem(),
        menuStartStop : NSMenuItem = NSMenuItem(),
        menuAppStatus : NSMenuItem = NSMenuItem(title: "Dinghy-tray status: Starting...", action: nil, keyEquivalent: ""),
        menuRestart : NSMenuItem = NSMenuItem(title: "Restart Dinghy", action: #selector(restartDinghy), keyEquivalent: ""),
        menuAbout : NSMenuItem = NSMenuItem(title: "About dinghy-tray", action: #selector(about), keyEquivalent: ""),
        menuChangeSudoPassword : NSMenuItem = NSMenuItem(title: "Change sudo password", action: #selector(changeSudo), keyEquivalent: ""),
        menuQuit : NSMenuItem = NSMenuItem(title: "Quit dinghy-tray", action: #selector(quit), keyEquivalent: "");
    
    
    func updateStatus() {
        // do some task
        let version = self.dinghy.version();
        let installed = (version != "Not Installed");
        let (VM,NFS,FSV,PROXY) = self.dinghy.status();
        let ip = self.dinghy.ip();
        let running = self.dinghy.running();
        DispatchQueue.main.async {
            if installed {
                
                self.menuStatus.title = "Dinghy " + version + " status";
                self.menuVM.title = "   " + VM;
                self.menuNFS.title = "   " + NFS;
                self.menuFSV.title = "   " + FSV;
                self.menuPROXY.title = "   " + PROXY;
                
                if running {
                    self.menuIP.title="IP: " + ip;
                    self.menuStartStop.title = "Stop Dinghy";
                    self.menuStartStop.action = #selector(self.stopDinghy);
                    self.menuRestart.isEnabled = true;
                } else {
                    self.menuIP.title="IP: N/A";
                    self.menuStartStop.title = "Start Dinghy";
                    self.menuStartStop.action = #selector(self.startDinghy);
                }
                
            } else {
                self.menuStatus.title = "Dinghy is not installed";
            }
        }
    }
    
    func updateInBackground() {
        DispatchQueue.global(qos: .background).async {
            self.updateStatus();
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        updateStatus();
        menuAppStatus.title = "Dinghy-tray status: OK";
        Timer.scheduledTimer(timeInterval: 5*60.0, target: self, selector: #selector(updateInBackground), userInfo: nil, repeats: true);
        
        statusBarItem = statusBar.statusItem(withLength: -1)
        statusBarItem.menu = menu
        statusBarItem.image = NSImage(named: "dinghy")
        statusBarItem.length = NSSquareStatusItemLength
        menu.addItem(menuStatus)
        menu.addItem(menuVM);
        menu.addItem(menuNFS);
        menu.addItem(menuFSV);
        menu.addItem(menuPROXY);
        menu.addItem(NSMenuItem.separator());
        menu.addItem(menuIP);
        menu.addItem(menuStartStop);
        menu.addItem(menuRestart);
        menu.addItem(menuAppStatus);
        menu.addItem(NSMenuItem.separator());
        menu.addItem(menuChangeSudoPassword);
        menu.addItem(NSMenuItem.separator());
        menu.addItem(menuAbout);
        menu.addItem(menuQuit);
        
        let sudoPassword = KeychainSwift().get("dinghy-tray-sudo-password");
        
        if sudoPassword == nil {
            changeSudo(sender: self);
        }
    }
}

