//
//  RightPanelsPresenter.swift
//  ARPlanets
//
//  Created by TSD040 on 2018-03-24.
//  Copyright © 2018 Pei Sun. All rights reserved.
//

import UIKit

struct PanelItem {
    let viewToPresent: UIView
    let heightPriority: Int
    let width: CGFloat
}

protocol RightPanelsPresenterDelegate: class {
    func rightPanelsPresenter(didPresent view: UIView)
    func rightPanelsPresenter(didDismiss view: UIView)
}

// A class
class RightPanelsPresenter {
    
    private enum PresentationState {
        case isHidden, onTopPanel, onBottomPanel
    }
    
    private var topPanel: Panel?
    private var bottomPanel: Panel?
    
    // The parent view presenting the panel
    weak var presentingView: UIView?
    
    weak var delegate: RightPanelsPresenterDelegate?
    
    init(presentingView: UIView) {
        self.presentingView = presentingView
    }
    
    // TODO on the ToolsMenu
    // If we have AR as main, can present the scene
    // If we have scene as main, can present the AR view
    
    func togglePanel(panelItem: PanelItem) {
        guard let presentingView = presentingView else {
            fatalError("shouldn't happen")
        }
        let viewToPresent = panelItem.viewToPresent
        let heightPriority = panelItem.heightPriority
        let width = panelItem.width
        
        let state = presentationState(for: viewToPresent)
        
        switch state {
        case .isHidden:
            let panel = Panel(width: width)
            panel.constrainToPresenter(viewToPresent: viewToPresent, heightPriority: heightPriority, presentingView: presentingView)
            
            // There are two panels, replace the bottom panel.
            if let topPanel = topPanel, let oldBottomPanel = bottomPanel {
                let shouldAnimateHeight = shouldAnimatePanelHeight(targetPanel: oldBottomPanel, topPanel: topPanel, bottomPanel: oldBottomPanel)
                
                panel.view.constrainBottom(to: presentingView)
                self.bottomPanel = panel
                startAnimation(inPanel: panel, outPanel: oldBottomPanel, oldBottomPanel: oldBottomPanel, shouldAnimateHeight: shouldAnimateHeight, width: width)
                
                // If we have none on top, present the top.
                // If we have nothing on top, something on the bottom, present the top
            } else if topPanel == nil {
                panel.view.constrainTop(to: presentingView)
                topPanel = panel
                startAnimation(inPanel: panel, outPanel: nil, width: width)
                
                // If we have nothing on bottom, something on the top, present the bottom
            } else {
                panel.view.constrainBottom(to: presentingView)
                bottomPanel = panel
                startAnimation(inPanel: panel, outPanel: nil, width: width)
            }
            
        // If a panel is already presented, dismiss it.
        case .onTopPanel:
            let oldTopPanel = topPanel!
            topPanel = nil
            let shouldAnimateHeight = shouldAnimatePanelHeight(targetPanel: oldTopPanel, topPanel: oldTopPanel, bottomPanel: bottomPanel)
            startAnimation(inPanel: nil, outPanel: oldTopPanel, oldBottomPanel: bottomPanel, shouldAnimateHeight: shouldAnimateHeight, width: width)
            
        // If a panel is already presented, dismiss it.
        case .onBottomPanel:
            let oldBottomPanel = bottomPanel!
            bottomPanel = nil
            let shouldAnimateHeight = shouldAnimatePanelHeight(targetPanel: oldBottomPanel, topPanel: topPanel, bottomPanel: oldBottomPanel)
            startAnimation(inPanel: nil, outPanel: oldBottomPanel, oldBottomPanel: oldBottomPanel, shouldAnimateHeight: shouldAnimateHeight, width: width)
        }
    }
    
    private func presentationState(for targetView: UIView) -> PresentationState {
        if topPanel?.view.subviews.first == targetView {
            return .onTopPanel
        } else if bottomPanel?.view.subviews.first == targetView {
            return .onBottomPanel
        } else {
            return .isHidden
        }
    }
    
    private func informDelegates(inPanel: Panel?, outPanel: Panel?) {
        if let inPanel = inPanel, let subview = inPanel.view.subviews.first {
            delegate?.rightPanelsPresenter(didPresent: subview)
        }
        if let outPanel = outPanel, let subview = outPanel.view.subviews.first {
            delegate?.rightPanelsPresenter(didDismiss: subview)
        }
    }
    
    private func startAnimation(inPanel: Panel?, outPanel: Panel?, oldBottomPanel: Panel? = nil, shouldAnimateHeight: Bool = false, width: CGFloat) {
        
        informDelegates(inPanel: inPanel, outPanel: outPanel)
        
        var middleConstraint: NSLayoutConstraint? = nil
        
        if let inPanel = inPanel, let topPanel = topPanel, let bottomPanel = bottomPanel {
            middleConstraint = topPanel.view.constrainBottomToTop(of: bottomPanel.view, offset: -20, isActive: false)
            bottomPanel.middleConstraint = middleConstraint // Store the middleConstraint in the bottomPanel

            let animateConstraints = shouldAnimatePanelHeight(targetPanel: inPanel, topPanel: topPanel, bottomPanel: bottomPanel)
            if !animateConstraints {
                middleConstraint?.isActive = true
            }
        }
        
        presentingView?.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            
            if let inPanel = inPanel {
                let container = inPanel.view
                container.backgroundColor = UIColor.white.withAlphaComponent(0.4)
                inPanel.leftConstraint?.constant = -container.bounds.width
                middleConstraint?.isActive = true
                self?.presentingView?.layoutIfNeeded()
            }
            
            if let outPanel = outPanel {
                outPanel.view.backgroundColor = .clear
                outPanel.leftConstraint?.constant = 0
                
                if let oldBottomPanel = oldBottomPanel, shouldAnimateHeight {
                    oldBottomPanel.middleConstraint?.isActive = false
                }
                
                self?.presentingView?.layoutIfNeeded()
            }
            
            }, completion: { _ in
                outPanel?.view.removeFromSuperview()
                if let outPanelConstraints = outPanel?.view.constraints {
                    for constraint in outPanelConstraints {
                        constraint.isActive = false
                    }
                }
        })
    }
    
    // Returns whether we should animate the panels' heights, so that if we're moving the targetPanel in or out, and the targetPanel has higher priority than the other panel, do an animation.
    // If the target panel to animate in has heigher heighr priority than the other panel,
    // Animate the activation of the middle constraint to expand/shrunk the other panel.
    // Otherwise, activate the middle constraint before the animation, to expand/shrink the current panel before we slide it in.
    private func shouldAnimatePanelHeight(targetPanel: Panel, topPanel: Panel?, bottomPanel: Panel?) -> Bool {
        guard let topPanel = topPanel, let bottomPanel = bottomPanel else { return false }
        if topPanel.view == targetPanel.view {
            return topPanel.heightPriority > bottomPanel.heightPriority
        } else {
            return topPanel.heightPriority < bottomPanel.heightPriority
        }
    }
}

