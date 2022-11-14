//
//  NavigationCoordinator.swift
//  weathero
//
//  Created by Robert Hamilton on 14/11/2022.
//

import Foundation
import UIKit
import CocoaLumberjackSwift

/// An implementation of Coordinator based around navigation controllers. The intention is for the entire coordinator tree to share
/// a single navigation controller.
open class NavigationCoordinator: Coordinator {
    
    /// The navigation controller backing the coordination. This instance should be passed to child navigation coordinators in their
    /// initialisers.
    ///
    /// Note: it is advised to use `pushViewController` or `removeViewController` instead of accessing the stack through
    /// the navigation controller directly as those methods will service the `viewControllers` list.
    public let navigationController: UINavigationController
    public var coordinatingViewController: UIViewController { navigationController }
    
    public var childCoordinators: [Coordinator] = []
    public var parentCoordinator: Coordinator?
    public var viewControllers: [UIViewController] = []
    
    /// If any of this instance's view controllers, or any of its childrens' view controllers are the top view controller in the navigation stack,
    /// the navigation coordinator is considered active.
    public var isActive: Bool {
        let topViewController = navigationController.topViewController
        if viewControllers.contains(where: { $0 === topViewController }) {
            return true
        } else {
            return childCoordinators.contains { $0.isActive }
        }
    }
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() { }
    
    /// The default implementation of finish will remove all of this coordinator's children and their view controllers, then  its own view
    /// controllers before asking calling remove on the parent with itself. If any view controllers managed by the coordinator need their
    /// own cleanup, this should be done before super.finish
    public func finish(animated: Bool) {
        guard let parentCoordinator = parentCoordinator else {
            DDLogWarn("Principal coordinator cannot exit")
            return
        }
        
        if coordinatingViewController === parentCoordinator.coordinatingViewController.presentedViewController {
            // Scenario where the coordinator has been presented by the parent
            coordinatingViewController.dismiss(animated: animated) { [self] in
                cleanUp(animated)
            }
        } else {
            // Scenario where the coordinator has been included in the parent's coordination controller
            cleanUp(animated)
        }
    }
    
    private func cleanUp(_ animated: Bool) {
        childCoordinators.forEach { $0.finish(animated: animated) }
        viewControllers.forEach { removeViewController($0, animated: animated) }
        parentCoordinator?.removeChild(self)
    }
    
    /// A wrapper for `navigationController.pushViewController` which adds the given view controller to `viewControllers`.
    public func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewControllers.append(viewController)
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    /// Removes the given view controller from `viewControllers` and the navigation stack. If the view controller is not the top view
    /// controller, `animated` does nothing, otherwise it behaves the same as `navigationController.popViewController`
    public func removeViewController(_ viewController: UIViewController, animated: Bool) {
        if let index = viewControllers.firstIndex(where: { $0 === viewController }) {
            viewControllers.remove(at: index)
        }
        if viewController === navigationController.topViewController {
            navigationController.popViewController(animated: animated)
        } else if let index = navigationController.viewControllers.firstIndex(where: { $0 === viewController }) {
            navigationController.viewControllers.remove(at: index)
        }
    }
}
