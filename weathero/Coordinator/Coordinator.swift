//
//  Coordinator.swift
//  weathero
//
//  Created by Robert Hamilton on 14/11/2022.
//

import Foundation
import UIKit

/// A protocol to implement to manage flows through the app
public protocol Coordinator: AnyObject {
    // MARK: As Parent Coordinator
    
    /// The view controller backing the coordination
    var coordinatingViewController: UIViewController { get }
    
    /// The child coordinators managed by this coordinator
    var childCoordinators: [Coordinator] { get set }
    
    /// Add a child coordinator to this coordinator. The default implementation will set the child's parent as this instance and add it
    /// to the`childCoordinators` list
    func addChild(_ child: Coordinator)
    
    /// Removes a child coordinator from this coordinator, The default implementation finds the match in the `childCoordinators`
    /// list and removes it.
    func removeChild(_ child: Coordinator?)
    
    // MARK: As Child coordinator
    
    /// The parent coordinator managing this coordinator
    var parentCoordinator: Coordinator? { get set }
    
    /// Whether the coordinator considers itself to be active
    var isActive: Bool { get }
    
    /// Starts the coordinator
    func start()
    
    /// Tells the coordinator to clean itself up, ready for removal. Any view controllers managed by the coordinator should be removed
    /// from any shared contexts, for example a navigation stack. Once the coordinator has finished cleaning up, it should call
    /// `removeChild` with itself on its parent.
     func finish(animated: Bool)
}

public extension Coordinator {
    func addChild(_ child: Coordinator) {
        childCoordinators.append(child)
        child.parentCoordinator = self
    }
    
    func removeChild(_ child: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() where coordinator === child {
            childCoordinators.remove(at: index)
            break
        }
    }
}
