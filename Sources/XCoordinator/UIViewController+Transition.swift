//
//  UIViewController+Transition.swift
//  XCoordinator
//
//  Created by Paul Kraft on 28.07.18.
//  Copyright © 2018 QuickBird Studios. All rights reserved.
//

import UIKit

extension UIViewController {

    private var topPresentedViewController: UIViewController {
        presentedViewController?.topPresentedViewController ?? self
    }

    func show(_ viewController: UIViewController,
              with options: TransitionOptions,
              completion: PresentationHandler?) {

        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)

        autoreleasepool {
            show(viewController, sender: nil)
        }

        CATransaction.commit()
    }

    func showDetail(_ viewController: UIViewController,
                    with options: TransitionOptions,
                    completion: PresentationHandler?) {

        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)

        autoreleasepool {
            showDetailViewController(viewController, sender: nil)
        }

        CATransaction.commit()
    }

    func present(onRoot: Bool,
                 _ viewController: UIViewController,
                 with options: TransitionOptions,
                 animation: Animation?,
                 completion: PresentationHandler?) {

        if let animation = animation {
            viewController.transitioningDelegate = animation
        }
        let presentingViewController = onRoot
            ? self
            : topPresentedViewController
        presentingViewController.present(viewController, animated: options.animated, completion: completion)
    }

    func dismiss(toRoot: Bool,
                 with options: TransitionOptions,
                 animation: Animation?,
                 completion: PresentationHandler?) {
        let presentedViewController = topPresentedViewController
        if let animation = animation {
            presentedViewController.transitioningDelegate = animation
        }
        let dismissalViewController = toRoot ? self : presentedViewController
        dismissalViewController.dismiss(animated: options.animated, completion: completion)
    }

}

extension Presentable where Self: UIViewController {

    @available(iOS, introduced: 9.0, deprecated: 13.0, message: "Use `UIContextMenuInteraction` instead.")
    func registerPeek<TransitionType: TransitionProtocol>(
        from sourceView: UIView,
        transitionGenerator: @escaping () -> TransitionType,
        completion: PresentationHandler?) where TransitionType.RootViewController == Self {
        let delegate = CoordinatorPreviewingDelegateObject(
            transition: transitionGenerator,
            rootViewController: self,
            completion: completion
        )

        if let context = sourceView.removePreviewingContext(for: TransitionType.self) {
            unregisterForPreviewing(withContext: context)
        }

        sourceView.strongReferences.append(delegate)
        delegate.context = registerForPreviewing(with: delegate, sourceView: sourceView)
    }
}
