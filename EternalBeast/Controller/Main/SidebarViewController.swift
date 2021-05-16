//
//  SidebarViewController.swift
//  EternalBeast
//
//  Created by Peter Urgoš on 02/05/2021.
//

import Cocoa

struct SidebarItem {
    var name: String
    var title: String
    var isGroup: Bool
    
    init(name: String, title: String = "") {
        self.name = name
        self.title = title
        self.isGroup = !self.title.isEmpty
    }
}

class SidebarViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!


    private var items: [SidebarItem] = [
        SidebarItem(name: "", title: "Library"),
        SidebarItem(name: "Artists"),
        SidebarItem(name: "", title: "Playlists")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let indexSet = IndexSet()
        tableView.selectRowIndexes(indexSet, byExtendingSelection: false)
    }
    
    public func addItem(item: String) {
        items.append(SidebarItem(name: item))
        
        tableView.reloadData()
    }
}

// MARK: - TableView Extensions

extension SidebarViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return items.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item = items[row]

        var text = ""

        if item.isGroup {
            text = item.title
        } else {
            text = item.name
        }

        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("sidebarItemCell"), owner: self) as! NSTableCellView
        cell.textField!.stringValue = text
        return cell
    }
    
    func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
        return items[row].isGroup
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 24
    }
}
