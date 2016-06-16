//
//  BaseUISearchBar.swift
//  eGrocery
//
//  Created by Shoaib on 3/2/15.
//  Copyright (c) 2015 cubixlabs. All rights reserved.
//

import UIKit

extension UISearchBar {
    var textField: UITextField? {
        get {
            return self.valueForKey("_searchField") as? UITextField
        }
    }
}

class BaseUISearchBar: UISearchBar, BaseView {

    @IBInspectable var bgColorStyle:String! = nil;
    
    @IBInspectable var boarder:Int?;
    @IBInspectable var boarderColorStyle:String?;
    
    @IBInspectable var tintColorStyle:String?;
    @IBInspectable var barTintColorStyle:String?;
    
    @IBInspectable var cornerRadius:Int?;
    
    @IBInspectable var fontStyle:String = "Medium";
    @IBInspectable var fontColorStyle:String! = nil;
    
    private var _placeholderKey:String?
    override var placeholder: String? {
        get {
            return super.placeholder;
        }
        
        set {
            if let key:String = newValue where key.hasPrefix("#") == true{
                _placeholderKey = key; // holding key for using later
                //--
                super.placeholder = SyncedText.text(forKey: key);
            } else {
                super.placeholder = newValue;
            }
        }
    } //P.E.
    
    override init(frame: CGRect) {
       
        super.init(frame: frame);
        
        self.updateView();
    }

    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder);
    }
    
    override func awakeFromNib() {
        super.awakeFromNib();
        //--
        self.updateView();
    } //F.E.
    
    func updateView() {
        //DOING NOTHING FOR NOW
        
        if let placeHoldertxt:String = self.placeholder where placeHoldertxt.hasPrefix("#") == true{
            self.placeholder = placeHoldertxt; // Assigning again to set value from synced data
        } else if _placeholderKey != nil {
            self.placeholder = _placeholderKey;
        }
        
        if let tintColorStyle:String = tintColorStyle {
            self.tintColor =  SyncedColors.color(forKey: tintColorStyle);
        }
        
        if let barTintColorStyle:String = barTintColorStyle {
            self.barTintColor =  SyncedColors.color(forKey: barTintColorStyle);
            //??self.backgroundColor =  SyncedColors.color(forKey: bgColor);
        }
        
        
        
        if let txtField:UITextField = self.textField {
            txtField.font = UIView.font(fontStyle);
            
            if (fontColorStyle != nil) {
                txtField.textColor = SyncedColors.color(forKey: fontColorStyle);
            }
            
            if let bgColor:String = bgColorStyle {
                txtField.backgroundColor =  SyncedColors.color(forKey: bgColor);
            }
            
            if let cornerRad:Int = cornerRadius {
                txtField.addRoundedCorners(UIView.convertToRatio(CGFloat(cornerRad)));
            }
            
            if let boder:Int = boarder {
                txtField.addBorder(SyncedColors.color(forKey: boarderColorStyle), width: boder);
            }
        }
        
    } //F.E.

} //F.E.