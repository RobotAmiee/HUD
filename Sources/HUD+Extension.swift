//
//  HUD+Extension.swift
//  Splaaash
//
//  Created by 张龙 on 2021/12/21.
//

import UIKit

extension String {
    func attributedString(with font: UIFont) -> NSAttributedString {
        return NSAttributedString(string: self, attributes: [.font: font])
    }
}

extension NSAttributedString {
    func textSize(with size: CGSize) -> CGSize {
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let boundingRect = boundingRect(with: size, options: options, context: nil)
        return CGSize(width: ceil(boundingRect.width), height: ceil(boundingRect.height))
    }
}

extension DispatchQueue {
    static func runInMainThreadSync(_ function: @escaping ()->Void) {
        if Thread.isMainThread {
            function()
        } else {
            DispatchQueue.main.sync {
                function()
            }
        }
    }
}

extension UIWindow {
    static var hudkeyWindow: UIWindow? {
        if let window = UIApplication.shared.windows.first, window.isKeyWindow {
            return window
        }
        if let window = UIApplication.shared.keyWindow, window.isKeyWindow {
            return window
        }
        if let delegate = UIApplication.shared.delegate, let window = delegate.window as? UIWindow {
            return window
        }
        return nil
    }
    
    static var hudstatusBarHeight: CGFloat {
        if UIDevice.current.orientation.isLandscape {
            return 0
        }
        var height: CGFloat = 0
        let insets: UIEdgeInsets = hudkeyWindow!.safeAreaInsets
        height = insets.top
        if height == 0 {
            if #available(iOS 13.0, *) {
                height = hudkeyWindow!.windowScene?.statusBarManager?.statusBarFrame.size.height ?? 20
            } else {
                height = UIApplication.shared.statusBarFrame.size.height
            }
        }
        if height == 0 {
            height = 20
        }
        return height
    }
    
    static var hudbottomInset: CGFloat {
        if UIDevice.current.orientation.isLandscape {
            return 0
        }
        return _hudsafeAreaInsets.bottom
    }
    
    static var _hudsafeAreaInsets: UIEdgeInsets {
        return hudkeyWindow!.safeAreaInsets
    }
}
