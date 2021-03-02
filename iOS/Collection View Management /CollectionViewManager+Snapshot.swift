//
//  CollectionViewManger+Snapshot.swift
//  Ours
//
//  Created by Benji Dodgson on 2/12/21.
//  Copyright © 2021 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension CollectionViewManager {

    func reloadAllSections(animate: Bool = true) {
        if self.dataSource.numberOfSections(in: self.collectionView) == 0 {
            self.loadSnapshot()
        } else {
            var new = self.dataSource.snapshot()
            new.reloadSections(SectionType.allCases as! [SectionType])
            self.dataSource.apply(new, animatingDifferences: true)
        }
    }

    func append(items: [AnyHashable], to section: SectionType, animate: Bool = true) {
        guard self.hasLoadedInitialSnapshot else { return }

        if self.dataSource.snapshot().sectionIdentifiers.contains(section) {
            var new = self.dataSource.snapshot(for: section)
            new.append(items)
            self.dataSource.apply(new, to: section, animatingDifferences: animate)
        } else {
            var new = self.dataSource.snapshot()
            new.appendItems(items, toSection: section)
            self.dataSource.apply(new, animatingDifferences: animate)
        }
    }

    func insert(items: [AnyHashable], before item: AnyHashable, animate: Bool = true) {
        var new = self.dataSource.snapshot()
        new.insertItems(items, beforeItem: item)
        self.dataSource.apply(new, animatingDifferences: animate)
    }

    func insert(items: [AnyHashable], after item: AnyHashable, animate: Bool = true) {
        var new = self.dataSource.snapshot()
        new.insertItems(items, afterItem: item)
        self.dataSource.apply(new, animatingDifferences: animate)
    }

    func delete(items: [AnyHashable], section: SectionType? = nil, animate: Bool = true) {
        guard self.hasLoadedInitialSnapshot else { return }

        var new = self.dataSource.snapshot()

        if let section = section {
            new.deleteItems(items, at: section.rawValue)
        } else {
            new.deleteItems(items)
        }

        self.dataSource.apply(new, animatingDifferences: animate)
    }

    func deleteAllItems(animate: Bool = true) {
        var new = self.dataSource.snapshot()
        new.deleteAllItems()
        self.dataSource.apply(new, animatingDifferences: animate)
    }

    func move(item: AnyHashable, beforeItem: AnyHashable, animate: Bool = true) {
        var new = self.dataSource.snapshot()
        new.moveItem(item, beforeItem: beforeItem)
        self.dataSource.apply(new, animatingDifferences: animate)
    }

    func move(item: AnyHashable, afterItem: AnyHashable, animate: Bool = true) {
        var new = self.dataSource.snapshot()
        new.moveItem(item, afterItem: afterItem)
        self.dataSource.apply(new, animatingDifferences: animate)
    }

    func reload(items: [AnyHashable], animate: Bool = true) {
        guard self.dataSource.snapshot().itemIdentifiers.contains(items) else { return }
        var new = self.dataSource.snapshot()
        new.reloadItems(items)
        self.dataSource.apply(new, animatingDifferences: animate)
    }

    func append(sections: [SectionType], animate: Bool = true) {
        guard self.hasLoadedInitialSnapshot else { return }

        var new = self.dataSource.snapshot()
        new.appendSections(sections)
        self.dataSource.apply(new, animatingDifferences: animate)
    }

    func delete(sections: [SectionType], animate: Bool = true) {
        var new = self.dataSource.snapshot()
        new.deleteSections(sections)
        self.dataSource.apply(new, animatingDifferences: animate)
    }

    func reload(sections: [SectionType], animate: Bool = true) {
        var new = self.dataSource.snapshot()
        new.reloadSections(sections)
        self.dataSource.apply(new, animatingDifferences: animate)
    }
}

extension NSDiffableDataSourceSnapshot {

    mutating func deleteItems(_ items: [ItemIdentifierType], at section: Int) {
        self.deleteItems(items)
        let sectionIdentifier = self.sectionIdentifiers[section]

        guard self.numberOfItems(inSection: sectionIdentifier) == 0 else { return }
        self.deleteSections([sectionIdentifier])
    }
}
