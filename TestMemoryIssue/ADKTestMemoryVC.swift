//
//  ADKTestMemoryVC.swift
//  SearchOfferCellModule
//

import Foundation
import AsyncDisplayKit

struct Page {
    static let size = 20
}

class ADKTestMemoryVC: ASViewController<ASCollectionNode>, ASCollectionDelegate, ASCollectionDataSource {

    static func test() -> ADKTestMemoryVC {
        let node = ADKTestMemoryVC(node: ASCollectionNode(collectionViewLayout: UICollectionViewFlowLayout()))
        return node
    }
    private var items: [Int] = []

    private func generateNextPage() -> [Int] {
        return stride(from: items.count, to: items.count + Page.size, by: 1).compactMap { $0 }
    }

    public func configure(collectionNode: ASCollectionNode) {

        collectionNode.dataSource = self
        collectionNode.delegate = self
        collectionNode.backgroundColor = .blue

        collectionNode.leadingScreensForBatching = 1

        let params = ASRangeTuningParametersZero

        collectionNode.setTuningParameters(params, for: .full, rangeType: .display)
        collectionNode.setTuningParameters(params, for: .full, rangeType: .preload)

        collectionNode.setTuningParameters(params, for: .lowMemory, rangeType: .display)
        collectionNode.setTuningParameters(params, for: .lowMemory, rangeType: .preload)

        collectionNode.setTuningParameters(params, for: .minimum, rangeType: .display)
        collectionNode.setTuningParameters(params, for: .minimum, rangeType: .preload)

        collectionNode.setTuningParameters(params, for: .visibleOnly, rangeType: .display)
        collectionNode.setTuningParameters(params, for: .visibleOnly, rangeType: .preload)

        self.items.append(contentsOf: self.generateNextPage())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure(collectionNode: self.node)
    }

    public func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }

    public func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }

    public func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> () -> ASCellNode {
        return {
            return OfferCellWidget()
        }
    }

    public func collectionView(_ collectionView: ASCollectionView, constrainedSizeForNodeAt indexPath: IndexPath) -> ASSizeRange {
        let width = collectionView.bounds.width
        return ASSizeRangeMake(
            CGSize(width: width, height: 0),
            CGSize(width: width, height: .greatestFiniteMagnitude))
    }

    public func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        return true
    }

    public func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        context.completeBatchFetching(true)
        DispatchQueue.main.async {
            let newItems = self.generateNextPage()
            self.items.append(contentsOf: newItems)
            collectionNode.insertItems(at: newItems.map { IndexPath(row: $0, section: 0) })
        }
    }
}
