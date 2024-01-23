//
//  HUD.swift
//  Splaaash
//
//  Created by 张龙 on 2021/12/19.
//

import UIKit

class HUD: NSObject {
    private static var prevTask: HUDTask?
    private static var sequenceTasks = [HUDTask]()
    
    static var backgroundColor: UIColor = .clear
    static var contentBackgroundColor: UIColor = .clear
    static var contentTranslucent: Bool = true
    static var contentStyle: HUDStyle = .dark
    static var minWidth: CGFloat = 120
    static var minHeight: CGFloat = 49
    static var maxWidth: CGFloat = 280
    static var maxHeight: CGFloat = 240
    static var duration: TimeInterval = 3
    static var cancelButtonMinWidth: CGFloat = 62
    static var backgroundView: UIView?
    
    static let shared = HUD()
    private override init() {}
    
    @discardableResult
    static func showLoading(in view: UIView? = nil,
                            progress: CGFloat,
                            title: String? = nil,
                            subtitle: String? = nil,
                            direction: HUDDirection = .vertical,
                            priority: HUDPriority = .replace,
                            position: HUDPosition = .center,
                            cancelable: Bool = false,
                            cancelAction: HUDBlock? = nil) -> HUDTask {
        if priority == .replace, let prevTask, prevTask.position == position, let hudview = prevTask.view {
            prevTask.priority = priority
            prevTask.superview = superview(view, for: position) ?? prevTask.superview
            prevTask.backgroundInteractive = false
            if prevTask.duration > 0 {
                HUD.cancelPreviousPerformRequests(withTarget: prevTask.view as Any)
            }
            prevTask.duration = 0
            prevTask.cancelAction = cancelAction
            DispatchQueue.runInMainThreadSync {
                prevTask.willShowBlock?()
                
                animate(true) {
                    hudview.update(superview: prevTask.superview,
                                   progress: progress,
                                   image: nil,
                                   title: title,
                                   subtitle: subtitle,
                                   direction: direction,
                                   position: position,
                                   closeable: false,
                                   cancelable: cancelable,
                                   backgroundInteractive: false,
                                   addToSuperview: true)
                } completion: {
                    prevTask.didShowBlock?()
                }
            }
            return prevTask
        } else {
            let task = HUDTask()
            task.priority = priority
            task.superview = superview(view, for: position) ?? UIWindow.hudkeyWindow
            task.duration = 0
            task.cancelAction = cancelAction
            DispatchQueue.runInMainThreadSync {
                let contentView = HUDView(superview: task.superview,
                                          progress: progress,
                                          image: nil,
                                          title: title,
                                          subtitle: subtitle,
                                          direction: direction,
                                          position: position,
                                          closeable: false,
                                          cancelable: cancelable)
                task.view = contentView
                task.position = position
                task.backgroundInteractive = false
                contentView.task = task
                self.show(task)
            }
            return task
        }
    }
    
    @discardableResult
    static func show(in view: UIView? = nil,
                     status: HUDStatus,
                     title: String? = nil,
                     subtitle: String? = nil,
                     direction: HUDDirection = .vertical,
                     duration: TimeInterval = duration,
                     priority: HUDPriority = .replace,
                     interactive: Bool = false,
                     position: HUDPosition = .center,
                     closeable: Bool = false,
                     closeAction: HUDBlock? = nil,
                     backgroundInteractive: Bool = true) -> HUDTask {
        if priority == .replace, let prevTask, prevTask.position == position, let hudview = prevTask.view {
            prevTask.status = status
            prevTask.priority = priority
            prevTask.superview = superview(view, for: position) ?? prevTask.superview
            prevTask.backgroundInteractive = backgroundInteractive
            prevTask.closeAction = closeAction
            if prevTask.duration > 0 {
                HUD.cancelPreviousPerformRequests(withTarget: prevTask.view as Any)
            }
            prevTask.duration = duration
            DispatchQueue.runInMainThreadSync {
                prevTask.willShowBlock?()
                
                haptic(status)
                
                animate(true) {
                    hudview.update(superview: prevTask.superview,
                                   progress: nil,
                                   image: image(for: status),
                                   title: title,
                                   subtitle: subtitle,
                                   direction: direction,
                                   position: position,
                                   closeable: closeable,
                                   cancelable: false,
                                   backgroundInteractive: backgroundInteractive,
                                   addToSuperview: true)
                } completion: {
                    prevTask.willShowBlock?()
                    
                    if prevTask.duration > 0 {
                        prevTask.view.perform(#selector(HUDView.hide), with: nil, afterDelay: prevTask.duration, inModes: [.common])
                    }
                }
            }
            return prevTask
        } else {
            let task = HUDTask()
            task.status = status
            task.priority = priority
            task.duration = duration
            task.closeAction = closeAction
            DispatchQueue.runInMainThreadSync {
                task.superview = superview(view, for: position) ?? UIWindow.hudkeyWindow
                
                let contentView = HUDView(superview: task.superview,
                                          progress: nil,
                                          image: image(for: status),
                                          title: title,
                                          subtitle: subtitle,
                                          direction: direction,
                                          position: position,
                                          closeable: closeable,
                                          cancelable: false)
                task.view = contentView
                task.position = position
                task.backgroundInteractive = backgroundInteractive
                contentView.task = task
                self.show(task)
            }
            return task
        }
    }
    
    static func show(_ task: HUDTask) {
        if prevTask != nil {
            switch task.priority {
            case .low:
                task.willHideBlock?()
                task.didHideBlock?()
                return
            case .overlay:
                break
            case .replace:
                break
            case .high:
                _hide(prevTask!, autoNext: false)
            case .sequence:
                sequenceTasks.append(task)
                return
            }
        }
        haptic(task.status)
        task.view.show()
        prevTask = task
    }
    
    static func hide(_ task: HUDTask? = nil) {
        DispatchQueue.runInMainThreadSync {
            let t = task ?? prevTask
            if t != nil {
                self._hide(t!)
            }
        }
    }
    
    private static func _hide(_ task: HUDTask, autoNext: Bool = true) {
        if let index = sequenceTasks.firstIndex(of: task) {
            if task == prevTask {
                prevTask?.view.hide {
                    if autoNext {
                        removeTaskAndCheckSequenceTasks(&prevTask)
                    }
                }
            } else {
                sequenceTasks.remove(at: index)
                
                task.willHideBlock?()
                task.didHideBlock?()
                
                if autoNext, let prepareTask = sequenceTasks.first {
                    sequenceTasks.removeFirst()
                    show(prepareTask)
                }
            }
        } else {
            prevTask?.view.hide {
                if autoNext {
                    removeTaskAndCheckSequenceTasks(&prevTask)
                }
            }
        }
    }
    
    static func removeTaskAndCheckSequenceTasks(_ task: inout HUDTask?) {
        if let task, let index = sequenceTasks.firstIndex(of: task) {
            sequenceTasks.remove(at: index)
        }
        
        if task == prevTask {
            prevTask = nil
        }
        task = nil
        
        if let prepareTask = sequenceTasks.first {
            sequenceTasks.removeFirst()
            show(prepareTask)
        }
    }
    
    static func animate(_ animate: Bool, animation: @escaping HUDBlock, completion: HUDBlock?) {
        if animate {
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 0,
                           options: [.beginFromCurrentState, .curveEaseOut],
                           animations: animation) { _ in
                completion?()
            }
        } else {
            animation()
            completion?()
        }
    }
    
    private static func superview(_ view: UIView?, for position: HUDPosition) -> UIView? {
        if view != nil, position == .center {
            return view
        }
        return nil
    }
    
    private static func image(for status: HUDStatus) -> UIImage? {
        switch status {
        case .none:
            return nil
        case .warning:
            return UIImage(named: "HUDIconWarning")
        case .error:
            return UIImage(named: "HUDIconError")
        case .success:
            return UIImage(named: "HUDIconSuccess")
        }
    }
    
    private static func haptic(_ status: HUDStatus) {
        let generator = UINotificationFeedbackGenerator()
        switch status {
        case .none:
            break
        case .warning:
            generator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.warning)
        case .error:
            generator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.error)
        case .success:
            generator.notificationOccurred(UINotificationFeedbackGenerator.FeedbackType.success)
        }
    }
}

typealias HUDBlock = () -> Void

class HUDTask: NSObject {
    static func == (lhs: HUDTask, rhs: HUDTask) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    let uuid = UUID().uuidString
    
    var priority: HUDPriority = .replace
    var duration: TimeInterval = 0
    var superview: UIView!
    var view: HUDView!
    var position: HUDPosition = .center
    var backgroundInteractive: Bool = false
    var status: HUDStatus = .none
    
    var closeAction: HUDBlock? = nil
    var cancelAction: HUDBlock? = nil
    
    var willShowBlock: HUDBlock? = nil
    var didShowBlock: HUDBlock? = nil
    var willHideBlock: HUDBlock? = nil
    var didHideBlock: HUDBlock? = nil
    
    deinit {
        print("HUDTask deinit")
    }
}

public enum HUDPosition: String {
    case top
    case center
    case bottom
    case navigationBarMask
    case tabBarMask
}

public enum HUDStatus {
    case none
    case warning
    case error
    case success
}

enum HUDStyle {
    case dark
    case light
}

enum HUDDirection {
    case vertical
    case horizontal
}

enum HUDPriority {
    case low
    case overlay
    case replace
    case high
    case sequence
}
