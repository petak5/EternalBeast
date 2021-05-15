//
//  LibraryArtistsViewController.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 02/05/2021.
//

import Cocoa

class LibraryArtistsViewController: NSSplitViewController {
    
    private var items = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func showItems(title: String, items: [String]) {
        for i in items {
            self.items.append(i)
        }
    }
    
}
