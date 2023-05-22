//
//  MFLoader.swift
//  RewardzCommonComponents
//
//  Created by Ankit Sachan on 01/04/21.
//

import UIKit

public class MFLoader {
   
    
    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var loadingTextLabelView: UIView = UIView()
    let loadingTextLabel = UILabel()
    /*
    Show customized activity indicator,
    actually add activity indicator to passing view
    @param uiView - add activity indicator to this view
    */
    
    public init(){}
    
    public func showActivityIndicator(_ uiView: UIView,loaderText: String? = "",backgroundColor : UIColor? = nil) {
        DispatchQueue.main.async {
            self.show(uiView, loaderText: loaderText,backgroundColor: backgroundColor)
        }
    }
    private func show(_ uiView: UIView, loaderText: String? = "", backgroundColor : UIColor? = nil)  {
        uiView.frame = UIScreen.main.bounds
        self.container.frame = uiView.frame
        self.container.center = uiView.center
        self.container.backgroundColor = UIColor.white
        
        if let backColor = backgroundColor {
            self.container.backgroundColor = backColor
        }else{
            self.container.backgroundColor = Rgbconverter.HexToColor("#434343", alpha: 0.7)
        }
        self.loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        self.loadingView.center = uiView.center
        self.loadingView.backgroundColor = UIColorFromHex(0x444444, alpha: 0.7)
        self.loadingView.clipsToBounds = true
        self.loadingView.layer.cornerRadius = 10
        self.activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
        self.activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        self.activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2);
        
        self.loadingTextLabelView.frame = CGRect(x: uiView.center.x - 140, y: uiView.center.y + 10, width: 280, height: 120)
        self.loadingTextLabelView.clipsToBounds = true
        
        loadingTextLabel.textColor = UIColor.white
        loadingTextLabel.textAlignment = .center
        loadingTextLabel.numberOfLines = 0
        loadingTextLabel.text = loaderText
        loadingTextLabel.font = UIFont.boldSystemFont(ofSize: 12)
        self.loadingTextLabel.frame = CGRect(x: self.loadingTextLabelView.frame.origin.x, y: self.loadingTextLabelView.frame.origin.y , width: 280, height: 120)
        loadingTextLabel.sizeToFit()
        loadingTextLabel.center = CGPoint(x: loadingTextLabelView.frame.size.width / 2, y: loadingTextLabelView.frame.size.height / 2);
    
        self.loadingView.addSubview(activityIndicator)
        self.loadingTextLabelView.addSubview(loadingTextLabel)
        self.container.addSubview(loadingView)
        self.container.addSubview(loadingTextLabelView)
        uiView.addSubview(container)
        self.activityIndicator.startAnimating()
    }
    /*
    Hide activity indicator
    Actually remove activity indicator from its super view
    @param uiView - remove activity indicator from this view
    */
    public func hideActivityIndicator(_ uiView: UIView) {
        activityIndicator.stopAnimating()
        container.removeFromSuperview()
    }
    /*
    Define UIColor from hex value
    @param rgbValue - hex color value
    @param alpha - transparency level
    */
    func UIColorFromHex(_ rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
}
extension UIView {
    public func showBlurLoader() {
        let blurLoader = BlurLoader(frame: frame)
        self.addSubview(blurLoader)
    }

    public func removeBluerLoader() {
        if let blurLoader = subviews.first(where: { $0 is BlurLoader }) {
            blurLoader.removeFromSuperview()
        }
    }
}


class BlurLoader: UIView {

    var blurEffectView: UIVisualEffectView?

    override init(frame: CGRect) {
        let blurEffectView = UIVisualEffectView(frame: frame)
        blurEffectView.frame = frame
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.backgroundColor = .clear
        self.blurEffectView = blurEffectView
        super.init(frame: frame)
        addSubview(blurEffectView)
        addLoader()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addLoader() {
        guard let blurEffectView = blurEffectView else { return }
        let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        activityIndicator.backgroundColor = UIColorFromHex(0x444444, alpha: 0.7)
        activityIndicator.curvedBorderedControl(borderColor: .lightGray, borderWidth: 0.5)
        blurEffectView.contentView.addSubview(activityIndicator)
        activityIndicator.center = blurEffectView.contentView.center
        activityIndicator.startAnimating()
    }
    
    func UIColorFromHex(_ rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
}
