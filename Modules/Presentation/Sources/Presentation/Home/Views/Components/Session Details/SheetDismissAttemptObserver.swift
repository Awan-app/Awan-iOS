import SwiftUI

#if canImport(UIKit)
import UIKit

struct SheetDismissAttemptObserver: UIViewControllerRepresentable {
    let isDismissalDisabled: Bool
    let onAttempt: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(
            isDismissalDisabled: isDismissalDisabled,
            onAttempt: onAttempt
        )
    }

    func makeUIViewController(context: Context) -> UIViewController {
        ObserverViewController(coordinator: context.coordinator)
    }

    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: Context
    ) {
        context.coordinator.isDismissalDisabled = isDismissalDisabled
        context.coordinator.onAttempt = onAttempt
        uiViewController.presentationController?.delegate = context.coordinator
        uiViewController.parent?.presentationController?.delegate = context.coordinator
    }

    final class Coordinator: NSObject, UIAdaptivePresentationControllerDelegate {
        var isDismissalDisabled: Bool
        var onAttempt: () -> Void

        init(
            isDismissalDisabled: Bool,
            onAttempt: @escaping () -> Void
        ) {
            self.isDismissalDisabled = isDismissalDisabled
            self.onAttempt = onAttempt
        }

        func presentationControllerShouldDismiss(
            _ presentationController: UIPresentationController
        ) -> Bool {
            !isDismissalDisabled
        }

        func presentationControllerDidAttemptToDismiss(
            _ presentationController: UIPresentationController
        ) {
            onAttempt()
        }
    }
}

private final class ObserverViewController: UIViewController {
    private let coordinator: SheetDismissAttemptObserver.Coordinator

    init(coordinator: SheetDismissAttemptObserver.Coordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        parent?.presentationController?.delegate = coordinator
    }
}
#else
struct SheetDismissAttemptObserver: View {
    let isDismissalDisabled: Bool
    let onAttempt: () -> Void

    var body: some View {
        Color.clear
    }
}
#endif
