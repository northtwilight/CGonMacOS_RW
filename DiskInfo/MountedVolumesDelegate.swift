/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Cocoa

typealias SelectionBlock = (_ volume: VolumeInfo) -> Void

class MountedVolumesDelegate: NSObject {

  var outlineView: NSOutlineView
  var volumeSelectionBlock: SelectionBlock?

  fileprivate struct Constants {
    static let headerCellID = "HeaderCell"
    static let volumeCellID = "VolumeCell"
  }

  init(outlineView: NSOutlineView, selectionBlock: @escaping SelectionBlock) {
    self.outlineView = outlineView
    self.volumeSelectionBlock = selectionBlock
    super.init()
    self.outlineView.delegate = self
  }
}

extension MountedVolumesDelegate: NSOutlineViewDelegate {

  func outlineViewSelectionDidChange(_ notification: Notification) {
    guard let outlineView = notification.object as? NSOutlineView else {
      return
    }
    let selectedRow = outlineView.selectedRow
    guard let item = outlineView.item(atRow: selectedRow) as? Section.Item , selectedRow >= 0 else {
      return
    }
    volumeSelectionBlock?(item.volume)
  }

  func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
    var cell: NSTableCellView?

    if let section = item as? Section {
      cell = outlineView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(Constants.headerCellID), owner: self) as? NSTableCellView
      cell?.textField?.stringValue = section.name
    } else if let item = item as? Section.Item {
      cell = outlineView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(Constants.volumeCellID), owner: self) as? NSTableCellView
      cell?.textField?.stringValue = item.volume.name
      cell?.imageView?.image = item.volume.image
    }
    return cell
  }

  func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
    return item is Section
  }

  func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
    return !(item is section)
  }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSUserInterfaceItemIdentifier(_ input: String) -> NSUserInterfaceItemIdentifier {
	return NSUserInterfaceItemIdentifier(rawValue: input)
}
