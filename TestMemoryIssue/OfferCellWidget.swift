//
//  OfferCellWidget.swift
//  TestMemoryIssue

import Foundation
import AsyncDisplayKit

class ImageCellNode: ASCellNode {
    let image = ASNetworkImageNode()
    override init() {
        super.init()
        self.automaticallyManagesSubnodes = true
        self.image.backgroundColor = .gray
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.image.style.alignSelf = .stretch
        self.image.style.preferredSize = CGSize(width: 0, height: 300)
        return ASInsetLayoutSpec(insets: .zero, child: self.image)
    }

    override func didEnterPreloadState() {
        super.didEnterPreloadState()
        self.image.url = URL(string: "https://upload.wikimedia.org/wikipedia/commons/f/ff/Pizigani_1367_Chart_10MB.jpg")
    }
}

public extension UICollectionViewLayout {
    public static var linear: UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        return layout
    }
}

class OfferCellWidget: ASCellNode, ASCollectionDelegate, ASCollectionDataSource {
    
    private let collectionNode = ASCollectionNode(collectionViewLayout: .linear)

    override init() {
        super.init()
        self.automaticallyManagesSubnodes = true
    }

    public func configure(collectionNode: ASCollectionNode) {
        collectionNode.view.isPagingEnabled = true

        collectionNode.dataSource = self
        collectionNode.delegate = self
        collectionNode.backgroundColor = .red

        let params = ASRangeTuningParametersZero

        collectionNode.setTuningParameters(params, for: .full, rangeType: .display)
        collectionNode.setTuningParameters(params, for: .full, rangeType: .preload)

        collectionNode.setTuningParameters(params, for: .lowMemory, rangeType: .display)
        collectionNode.setTuningParameters(params, for: .lowMemory, rangeType: .preload)

        collectionNode.setTuningParameters(params, for: .minimum, rangeType: .display)
        collectionNode.setTuningParameters(params, for: .minimum, rangeType: .preload)

        collectionNode.setTuningParameters(params, for: .visibleOnly, rangeType: .display)
        collectionNode.setTuningParameters(params, for: .visibleOnly, rangeType: .preload)
    }

    override func didLoad() {
        super.didLoad()
        self.configure(collectionNode: self.collectionNode)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.collectionNode.style.width = ASDimensionMake("100%")
        self.collectionNode.style.height = ASDimension(unit: .points, value: 300)
        return ASInsetLayoutSpec(insets: .zero, child: self.collectionNode)
    }

    public func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    public func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }

    public func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> () -> ASCellNode {
        return { return ImageCellNode() }
    }

    public func collectionView(_ collectionView: ASCollectionView, constrainedSizeForNodeAt indexPath: IndexPath) -> ASSizeRange {
        let width = collectionView.bounds.width
        return ASSizeRangeMake(CGSize(width: width, height: 0), CGSize(width: width, height: 300))
    }
}
