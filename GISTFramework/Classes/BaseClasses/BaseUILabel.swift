//
//  BaseLabel.swift
//  E-Grocery
//
//  Created by Muneeba on 1/14/15.
//  Copyright (c) 2015 cubixlabs. All rights reserved.
//

import UIKit

public class BaseUILabel: UILabel, BaseView {
    
    @IBInspectable var bgColorStyle:String! = nil;
    
    @IBInspectable var boarder:Int = 0;
    @IBInspectable var boarderColorStyle:String! = nil;
    
    @IBInspectable var cornerRadius:Int = 0;
    
    
    @IBInspectable var rounded:Bool = false;
    
    @IBInspectable var hasDropShadow:Bool = false;
    
    
    @IBInspectable var underlinedText:Bool=false
    
    @IBInspectable var fontStyle:String = "Medium";
    @IBInspectable var fontColorStyle:String! = nil;
     
    @IBInspectable var sizeForIPad:Bool = false;
    
    private var _textKey: String?
    override public var text: String? {
        get {
            return super.text;
        }
        
        set {
            if let key:String = newValue where key.hasPrefix("#") == true {
                _textKey = key; // holding key for using later
                
                super.text = SyncedText.text(forKey: key);
            } else {
                super.text = newValue;
            }
        }
    } //P.E.
    
    override public func awakeFromNib() {
        
        super.awakeFromNib()
        //--
        self.updateView()
    } //F.E.
    
    public func updateView()
    {
        self.updateFont();
        //--
        
        //Updating text with synced data
        if let txt:String = self.text where txt.hasPrefix("#") == true {
            self.text = txt; // Assigning again to set value from synced data
        } else if _textKey != nil {
            self.text = _textKey;
        }
        
        if (fontColorStyle != nil) {
            self.textColor = SyncedColors.color(forKey: fontColorStyle);
        }
        
        if (underlinedText) {
            let attString:NSMutableAttributedString=NSMutableAttributedString(string: (self.text?.capitalizedString)! as String)
            attString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue , range: NSRange(location: 0, length: attString.length))
            self.attributedText = attString
        }
        
        if (boarder > 0) {
            self.addBorder(SyncedColors.color(forKey: boarderColorStyle), width: boarder)
        }
        
        if (bgColorStyle != nil) {
            self.backgroundColor = SyncedColors.color(forKey: bgColorStyle);
        }
        
        if (cornerRadius != 0) {
            self.addRoundedCorners(UIView.convertToRatio(CGFloat(cornerRadius), sizedForIPad: sizeForIPad));
        }
        
        if (hasDropShadow) {
            self.addDropShadow();
        }
    } //F.E.
    
    //Seperate Method so that child class may override it
    func updateFont() {
        self.font = UIFont(name: self.font.fontName, size: UIView.convertFontSizeToRatio(self.font.pointSize, fontStyle: fontStyle, sizedForIPad:self.sizeForIPad));
    } //F.E.
    
    override public func layoutSubviews() {
        super.layoutSubviews();
        //--
        if rounded {
            self.addRoundedCorners();
        }
    } //F.E.
    
} //CLS END
