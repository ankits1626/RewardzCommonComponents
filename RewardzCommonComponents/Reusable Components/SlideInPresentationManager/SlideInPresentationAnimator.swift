//
//  SlideInPresentationAnimator.swift
//  MedalCount
//
//  Created by Rewardz on 29/04/19.
//  Copyright © 2019 Ron Kliffer. All rights reserved.
//

import UIKit

public final class SlideInPresentationAnimator: NSObject {
  let direction: SlideInPresentationDirection
  let isPresentation: Bool
  
  public init(direction: SlideInPresentationDirection, isPresentation: Bool) {
    self.direction = direction
    self.isPresentation = isPresentation
    super.init()
  }
}

extension SlideInPresentationAnimator: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.3
  }
  
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let key = isPresentation ? UITransitionContextViewControllerKey.to : UITransitionContextViewControllerKey.from
    let controller = transitionContext.viewController(forKey: key)!
    if isPresentation {
      transitionContext.containerView.addSubview(controller.view)
    }
    let presentedFrame = transitionContext.finalFrame(for: controller)
    var dismissedFrame = presentedFrame
    switch direction {
    case .left:
      dismissedFrame.origin.x = -presentedFrame.width
    case .right:
      dismissedFrame.origin.x = transitionContext.containerView.frame.size.width
    case .top:
      dismissedFrame.origin.y = -presentedFrame.height
    case .bottom:
      dismissedFrame.origin.y = transitionContext.containerView.frame.size.height
    }
    let initialFrame = isPresentation ? dismissedFrame : presentedFrame
    let finalFrame = isPresentation ? presentedFrame : dismissedFrame
    let animationDuration = transitionDuration(using: transitionContext)
    controller.view.frame = initialFrame
    UIView.animate(withDuration: animationDuration, animations: {
      controller.view.frame = finalFrame
    }) { finished in
      transitionContext.completeTransition(finished)
    }
  }
}
