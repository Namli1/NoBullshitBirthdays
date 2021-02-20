//
//  SettingsSlideDownManager.swift
//  No Bullshit Birthdays
//
//  Created by Tilman Herz on 19.05.20.
//  Copyright © 2020 Tilman Herz. All rights reserved.
//

import UIKit

class SettingsSlideDownManager: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let animationDuration: Double
    private let animationType: AnimationType
    
    enum AnimationType {
        case present
        case dismiss
    }
    
    init(animationDuration: Double, animationType: AnimationType) {
        self.animationDuration = animationDuration
        self.animationType = animationType
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toVC = transitionContext.viewController(forKey: .to),
            let fromVC = transitionContext.viewController(forKey: .from) else {
                transitionContext.completeTransition(false)
                return
        }
        
        switch animationType {
        case .present:
            transitionContext.containerView.addSubview(toVC.view)
            toVC.view.center = CGPoint(x: toVC.view.center.x, y: toVC.view.center.y - UIScreen.main.bounds.size.height)
            presentAnimation(with: transitionContext, viewToAnimate: toVC.view, view2ToAnimate: fromVC.view)
            
        case .dismiss:
            transitionContext.containerView.addSubview(fromVC.view)
            dismissAnimation(with: transitionContext, viewToAnimate: fromVC.view, view2ToAnimate: toVC.view)
        }
        
    }
    
    func presentAnimation(with transitionContext: UIViewControllerContextTransitioning, viewToAnimate: UIView, view2ToAnimate: UIView) {
        
        viewToAnimate.clipsToBounds = true
        view2ToAnimate.layoutIfNeeded()
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0,
             options: [], animations: {
            
                let moveDown = CGAffineTransform(translationX: 0, y: 540)
            
                viewToAnimate.transform = moveDown
                view2ToAnimate.transform = moveDown
                
            
        }) { _ in
            transitionContext.completeTransition(true)
        }
        
    }
    
    func dismissAnimation(with transitionContext: UIViewControllerContextTransitioning, viewToAnimate: UIView, view2ToAnimate: UIView) {
        
        let duration = transitionDuration(using: transitionContext)

        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.80, initialSpringVelocity: 0.1, options: [.allowUserInteraction], animations: {

            let moveUp = CGAffineTransform(translationX: 0, y: 0)

            viewToAnimate.transform = moveUp
            view2ToAnimate.transform = moveUp
            view2ToAnimate.layer.borderWidth = 0

        }) { _ in
            transitionContext.completeTransition(true)
        }
        
    }
    
}
