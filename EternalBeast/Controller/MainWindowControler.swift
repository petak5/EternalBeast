//
//  MainWindowControler.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 02/05/2021.
//

import Cocoa

class MainWindowControler: NSWindowController {

    @IBOutlet var toolbar: NSToolbar!
    
    var mainViewController: MainViewController!
    
    override func windowDidLoad() {
        // Delay this because it was not working sometimes
        // I do not know why
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                // Insert toggle sidebar button to toolbar
                self.toolbar.insertItem(withItemIdentifier: NSToolbarItem.Identifier.toggleSidebar, at: 0)
            }
        }
        
        mainViewController = self.contentViewController as? MainViewController
    }
    
    @IBAction func add(_ sender: NSToolbarItem) {
        let dialog = NSOpenPanel();
            
        dialog.title                   = "Choose a directory";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseFiles          = false;
        dialog.canChooseDirectories    = true;
        dialog.allowsMultipleSelection = false;

        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url
            
            if let _result = result {
                let path = _result.path
                print(path)
                
                mainViewController.openFolder(withPath: path)
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }

}
