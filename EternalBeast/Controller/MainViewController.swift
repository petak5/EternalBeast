//
//  ViewController.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 02/05/2021.
//

import Cocoa

class MainViewController: NSSplitViewController {

//    @IBOutlet weak var sidebarView: NSSplitViewItem!
//    @IBOutlet weak var mainContentView: NSSplitViewItem!
    
    @IBOutlet weak var sidebarView: NSSplitViewItem!
    @IBOutlet weak var mainContentView: NSSplitViewItem!
    
    
    var sidebarViewController: SidebarViewController!
    var mainContentViewController: LibraryArtistsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        sidebarViewController = sidebarView.viewController as? SidebarViewController
        mainContentViewController = mainContentView.viewController as? LibraryArtistsViewController
    }
    
    public func openFolder(withPath path: String) {
        let fileManager = FileManager.default
        
        do {
            let items = try fileManager.contentsOfDirectory(atPath: path)
            
            mainContentViewController.showItems(title: path, items: items)
        } catch let error {
            NSResponder().presentError(error)
            print("Failed to retreive contents of directory: '" + path + "'")
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

