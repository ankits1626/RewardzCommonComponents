//
//  SlideInPresentationController.swift
//  MedalCount
//
//  Created by Rewardz on 29/04/19.
//  Copyright © 2019 Ron Kliffer. All rights reserved.
//

import UIKit

class SlideInPresentationController: UIPresentationController {
  private var direction: SlideInPresentationDirection
  fileprivate var dimmingView: UIView!
  
  init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, direction: SlideInPresentationDirection) {
    self.direction = direction
    super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    setupDimmingView()
  }
  
  override func presentationTransitionWillBegin() {
    containerView?.insertSubview(dimmingView, at: 0)
    NSLayoutConstraint.activate(
      NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimmingView]|",
                                     options: [], metrics: nil, views: ["dimmingView": dimmingView]))
    NSLayoutConstraint.activate(
      NSLayoutConstraint.constraints(withVisualFormat: "H:|[dimmingView]|",
                                     options: [], metrics: nil, views: ["dimmingView": dimmingView]))
    guard let coordinator = presentedViewController.transitionCoordinator else {
      dimmingView.alpha = 1.0
      return
    }
    coordinator.animate(alongsideTransition: { _ in
      self.dimmingView.alpha = 1.0
    })
  }
  
  override func dismissalTransitionWillBegin() {
    guard let coordinator = presentedViewController.transitionCoordinator else {
      dimmingView.alpha = 0.0
      return
    }
    
    coordinator.animate(alongsideTransition: { _ in
      self.dimmingView.alpha = 0.0
    })
  }
  
  override func containerViewWillLayoutSubviews() {
    presentedView?.frame = frameOfPresentedViewInContainerView
    switch direction {
    case .bottom(_):
        presentedView?.layer.cornerRadius = 12.0
    case .left:
        fallthrough
    case .top:
        fallthrough
    case .right:
        fallthrough
    @unknown default:
        print("no corner radius")
    }
  }
  
  override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
    switch direction {
    case .left:
      fallthrough
      case .right:
      return CGSize(width: parentSize.width*(1.0/1.0), height: parentSize.height)
      
    case .top:
      return CGSize(width: parentSize.width, height: parentSize.height*(2.0/3.0))
    case .bottom(let height):
      if let unwrappedHeight = height{
        return CGSize(width: parentSize.width, height: parentSize.height*(unwrappedHeight/UIScreen.main.bounds.size.height))
      }else{
        return CGSize(width: parentSize.width, height: parentSize.height*(2.0/3.0))
      }
    }
  }
  
  override var frameOfPresentedViewInContainerView: CGRect{
    var frame: CGRect = .zero
    frame.size = size(forChildContentContainer: presentedViewController,
                      withParentContainerSize: containerView!.bounds.size)
    
    //2
    switch direction {
    
    case .left:
      fallthrough
    case .top:
      frame.origin = .zero
    case .right:
      frame.origin.x = containerView!.frame.width*(0.0/1.0)
    case .bottom(let height):
      if let unwrappedHeight = height{
        frame.origin.y = containerView!.frame.height*(1.0 - (unwrappedHeight/UIScreen.main.bounds.size.height))
      }else{
        frame.origin.y = containerView!.frame.height*(1.0/3.0)
      }
    }
    return frame
  }
  
}

private extension SlideInPresentationController {
  func setupDimmingView() {
    dimmingView = UIView()
    dimmingView.translatesAutoresizingMaskIntoConstraints = false
    dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
    dimmingView.alpha = 0.0
    let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
    dimmingView.addGestureRecognizer(recognizer)
  }
  
  @objc func handleTap(recognizer: UITapGestureRecognizer) {
    presentingViewController.dismiss(animated: true)
  }
}
