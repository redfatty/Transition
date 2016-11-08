//
//  PrivateTransitionContext.swift
//  CustomContainerVCTransition
//
//  Created by seedante on 15/12/26.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

let SDEContainerTransitionEndNotification = "Notification.ContainerTransitionEnd.seedante"
let SDEInteractionEndNotification = "Notification.InteractionEnd.seedante"

class ContainerTransitionContext: NSObject, UIViewControllerContextTransitioning {
    //MARK: Addtive Property
    private var animationController: UIViewControllerAnimatedTransitioning?
    //MARK: Private Property for Protocol Need
    unowned private var privateFromViewController: UIViewController
    unowned private var privateToViewController: UIViewController
    unowned private var privateContainerViewController: SDEContainerViewController
    unowned private var privateContainerView: UIView
    //MARK: Property for Transition State
    private var interactive = false
    private var isCancelled = false
    private var fromIndex: Int = 0
    private var toIndex: Int = 0
    private var transitionDuration: CFTimeInterval = 0
    private var transitionPercent: CGFloat = 0
    
    //MARK: Public Custom Method
    init(containerViewController: SDEContainerViewController, containerView: UIView, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController){
        privateContainerViewController = containerViewController
        privateContainerView = containerView
        privateFromViewController = fromVC
        privateToViewController = toVC
        fromIndex = containerViewController.viewControllers!.indexOf(fromVC)!
        toIndex = containerViewController.viewControllers!.indexOf(toVC)!
        super.init()
        //每次转场开始前都会生成这个对象，调整 toView 的尺寸适用屏幕
        privateToViewController.view.frame = privateContainerView.bounds
    }
    
    func startInteractiveTranstionWith(delegate: ContainerViewControllerDelegate){
        animationController = delegate.containerController(privateContainerViewController, animationControllerForTransitionFromViewController: privateFromViewController, toViewController: privateToViewController)
        transitionDuration = animationController!.transitionDuration(self)
        if privateContainerViewController.interactive == true{
            if let interactionController = delegate.containerController?(privateContainerViewController, interactionControllerForAnimation: animationController!){
                interactionController.startInteractiveTransition(self)
            }else{
                fatalError("Need for interaction controller for interactive transition.")
            }
        }else{
            fatalError("ContainerTransitionContext's Property 'interactive' must be true before starting interactive transiton")
        }
    }
    
    func startNonInteractiveTransitionWith(delegate: ContainerViewControllerDelegate){
        animationController = delegate.containerController(privateContainerViewController, animationControllerForTransitionFromViewController: privateFromViewController, toViewController: privateToViewController)
        transitionDuration = animationController!.transitionDuration(self)
        activateNonInteractiveTransition()
    }
    
    //InteractionController's startInteractiveTransition: will call this method
    func activateInteractiveTransition(){
        interactive = true
        isCancelled = false
        privateContainerViewController.addChildViewController(privateToViewController)
        privateContainerView.layer.speed = 0
        animationController?.animateTransition(self)
    }
    
    //MARK: Private Helper Method
    private func activateNonInteractiveTransition(){
        interactive = false
        isCancelled = false
        privateContainerViewController.addChildViewController(privateToViewController)
        animationController?.animateTransition(self)
    }
    
    private func transitionEnd(){
        if animationController != nil && animationController!.respondsToSelector(#selector(UIViewControllerAnimatedTransitioning.animationEnded(_:))) == true{
            animationController!.animationEnded!(!isCancelled)
        }
        //If transition is cancelled, recovery data.
        if isCancelled{
            privateContainerViewController.restoreSelectedIndex()
            isCancelled = false
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(SDEContainerTransitionEndNotification, object: self)
    }
    
    //修复内嵌在其他容器 VC 交互返回的转场中 containerView 消失并且的转场结束后自动恢复的 Bug。
    @objc private func fixBeginTimeBug(){
        privateContainerView.layer.beginTime = 0.0
    }

    
    @objc private func reverseCurrentAnimation(displayLink: CADisplayLink){
        let timeOffset = privateContainerView.layer.timeOffset - displayLink.duration
        if timeOffset > 0{
            privateContainerView.layer.timeOffset = timeOffset
            transitionPercent = CGFloat(timeOffset / transitionDuration)
            privateContainerViewController.graduallyChangeTabButtonAppearWith(fromIndex, toIndex: toIndex, percent: transitionPercent)
        }else{
            displayLink.invalidate()
            privateContainerView.layer.timeOffset = 0
            privateContainerView.layer.speed = 1
            privateContainerViewController.graduallyChangeTabButtonAppearWith(fromIndex, toIndex: toIndex, percent: 0)
            
            //修复闪屏Bug: speed 恢复为1后，动画会立即跳转到它的最终状态，而 fromView 的最终状态是移动到了屏幕之外，因此在这里添加一个假的掩人耳目。
            //为何不等 completion block 中恢复 fromView 的状态后再恢复 containerView.layer.speed，事实上那样做无效，原因未知。
            let fakeFromView = privateFromViewController.view.snapshotViewAfterScreenUpdates(false)
            privateContainerView.addSubview(fakeFromView)
            performSelector(#selector(ContainerTransitionContext.removeFakeFromView(_:)), withObject: fakeFromView, afterDelay: 1/60)
        }
    }
    
    @objc private func removeFakeFromView(fakeView: UIView){
        fakeView.removeFromSuperview()
    }
    
    @objc private func finishChangeButtonAppear(displayLink: CADisplayLink){
        let percentFrame = 1 / (transitionDuration * 60)
        transitionPercent += CGFloat(percentFrame)
        if transitionPercent < 1.0{
            privateContainerViewController.graduallyChangeTabButtonAppearWith(fromIndex, toIndex: toIndex, percent: transitionPercent)
        }else{
            privateContainerViewController.graduallyChangeTabButtonAppearWith(fromIndex, toIndex: toIndex, percent: 1)
            displayLink.invalidate()
        }
    }
    
    //MARK: Protocol Method - Reporting the Transition Progress
    func completeTransition(didComplete: Bool) {
        if didComplete{
            privateToViewController.didMoveToParentViewController(privateContainerViewController)
            
            privateFromViewController.willMoveToParentViewController(nil)
            privateFromViewController.view.removeFromSuperview()
            privateFromViewController.removeFromParentViewController()
        }else{
            privateToViewController.didMoveToParentViewController(privateContainerViewController)
            
            privateToViewController.willMoveToParentViewController(nil)
            privateToViewController.view.removeFromSuperview()
            privateToViewController.removeFromParentViewController()
        }
        
        transitionEnd()
    }
    
    func updateInteractiveTransition(percentComplete: CGFloat) {
        if animationController != nil && interactive == true{
            transitionPercent = percentComplete
            privateContainerView.layer.timeOffset = CFTimeInterval(percentComplete) * transitionDuration
            privateContainerViewController.graduallyChangeTabButtonAppearWith(fromIndex, toIndex: toIndex, percent: percentComplete)
        }
    }
    
    func finishInteractiveTransition() {
        interactive = false
        let pausedTime = privateContainerView.layer.timeOffset
        privateContainerView.layer.speed = 1.0
        privateContainerView.layer.timeOffset = 0.0
        privateContainerView.layer.beginTime = 0.0
        let timeSincePause = privateContainerView.layer.convertTime(CACurrentMediaTime(), fromLayer: nil) - pausedTime
        privateContainerView.layer.beginTime = timeSincePause
        
        let displayLink = CADisplayLink(target: self, selector: #selector(ContainerTransitionContext.finishChangeButtonAppear(_:)))
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        
        //当 SDETabBarViewController 作为一个子 VC 内嵌在其他容器 VC 内，比如 NavigationController 里时，在 SDETabBarViewController 内完成一次交互转场后
        //在外层的 NavigationController push 其他 VC 然后 pop 返回时，且仅限于交互控制，会出现 containerView 不见的情况，pop 完成后就恢复了。
        //根源在于此时 beginTime 被修改了，在转场结束后恢复为 0 就可以了。解决灵感来自于如果没有一次完成了交互转场而全部是中途取消的话就不会出现这个 Bug。
        //感谢简书用户@dasehng__ 反馈这个 Bug。
        let remainingTime = CFTimeInterval(1 - transitionPercent) * transitionDuration
        performSelector(#selector(ContainerTransitionContext.fixBeginTimeBug), withObject: nil, afterDelay: remainingTime)

    }
    
    func cancelInteractiveTransition() {
        interactive = false
        isCancelled = true
        let displayLink = CADisplayLink(target: self, selector: #selector(ContainerTransitionContext.reverseCurrentAnimation(_:)))
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        NSNotificationCenter.defaultCenter().postNotificationName(SDEInteractionEndNotification, object: self)
    }
    
    func transitionWasCancelled() -> Bool {
        return isCancelled
    }
    //MARK: Protocol Method - Getting the Transition Behaviors
    func isAnimated() -> Bool {
        if animationController != nil{
            return true
        }
        return false
    }
    
    func isInteractive() -> Bool {
        return interactive
    }
    
    func presentationStyle() -> UIModalPresentationStyle {
        return .Custom
    }
    
    //MARK: Protocol Method - Accessing the Transition Objects
    @objc func containerView() -> UIView? {
        return privateContainerView
    }
    
    @objc func viewControllerForKey(key: String) -> UIViewController?{
        switch key{
        case UITransitionContextFromViewControllerKey:
            return privateFromViewController
        case UITransitionContextToViewControllerKey:
            return privateToViewController
        default: return nil
        }
    }
    
    @objc @available(iOS 8.0, *)
    func viewForKey(key: String) -> UIView? {
        switch key{
        case UITransitionContextFromViewKey:
            return privateFromViewController.view
        case UITransitionContextToViewKey:
            return privateToViewController.view
        default: return nil
        }
    }
    //MARK: Protocol Method - Getting the Transition Frame Rectangles
    func initialFrameForViewController(vc: UIViewController) -> CGRect {
        return CGRectZero
    }
    
    func finalFrameForViewController(vc: UIViewController) -> CGRect {
        return vc.view.frame
    }
    
    //MARK: Protocol Method - Getting the Rotation Factor
    @available(iOS 8.0, *)
    func targetTransform() -> CGAffineTransform {
        return CGAffineTransformIdentity
    }
}
