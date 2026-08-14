import SwiftUI
import UIKit

@MainActor
final class HomeScrollController {
    fileprivate weak var scrollView: UIScrollView?

    @discardableResult
    func scroll(by delta: CGFloat) -> CGFloat {
        guard let scrollView, delta != 0 else { return 0 }

        let minimumOffset = -scrollView.adjustedContentInset.top
        let maximumOffset = max(
            minimumOffset,
            scrollView.contentSize.height
                - scrollView.bounds.height
                + scrollView.adjustedContentInset.bottom
        )
        let currentOffset = scrollView.contentOffset.y
        let targetOffset = min(
            max(currentOffset + delta, minimumOffset),
            maximumOffset
        )
        let consumedDelta = targetOffset - currentOffset

        guard consumedDelta != 0 else { return 0 }
        scrollView.setContentOffset(
            CGPoint(x: scrollView.contentOffset.x, y: targetOffset),
            animated: false
        )
        return consumedDelta
    }
}

struct HomeScrollControllerReader: UIViewRepresentable {
    let controller: HomeScrollController

    func makeUIView(context: Context) -> HomeScrollResolverView {
        HomeScrollResolverView(controller: controller)
    }

    func updateUIView(_ uiView: HomeScrollResolverView, context: Context) {
        uiView.controller = controller
        uiView.resolveScrollView()
    }
}

final class HomeScrollResolverView: UIView {
    var controller: HomeScrollController

    init(controller: HomeScrollController) {
        self.controller = controller
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        backgroundColor = .clear
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unavailable")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        resolveScrollView()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        resolveScrollView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if controller.scrollView == nil {
            resolveScrollView()
        }
    }

    func resolveScrollView() {
        var ancestor = superview
        while let view = ancestor {
            if let scrollView = view as? UIScrollView {
                controller.scrollView = scrollView
                return
            }
            ancestor = view.superview
        }
    }
}
