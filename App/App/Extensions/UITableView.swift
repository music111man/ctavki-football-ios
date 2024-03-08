//
//  UITableView.swift
//  App
//
//  Created by Denis Shkultetskyy on 08.03.2024.
//

import UIKit

extension UITableView {
    func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }

    func scrollToTop(animated: Bool = true) {
        let indexPath = IndexPath(row: 0, section: 0)
        if self.hasRowAtIndexPath(indexPath: indexPath) {
          self.scrollToRow(at: indexPath, at: .top, animated: animated)
        }
    }
}
