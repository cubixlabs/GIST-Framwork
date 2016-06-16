//
//  BaseTableViewCell.swift
//  E-Grocery
//
//  Created by Muneeba on 1/14/15.
//  Copyright (c) 2015 cubixlabs. All rights reserved.
//

import UIKit

public class BaseUITableViewCell: UITableViewCell, BaseView {

    private var _data:AnyObject?
    var data:AnyObject? {
        get {
            return _data;
        }
        
        set {
            _data = newValue;
        }
    } //P.E.
    
    private var _seperatorView:UIView!;
    @IBInspectable var bgColorStyle:String! = nil;
    
    private var seperatorFrame:CGRect {
        get  {
            //??return CGRectMake(15, self.frame.size.height - 0.5, self.frame.size.width - 30, 0.5);
            return CGRectMake(0, (seperatorOnTop ? 0:self.frame.size.height - 0.5), self.frame.size.width, 0.5);
        }
    } //P.E.
    
    /*
    private var accessoryViewFrame:CGRect {
        get  {
            return CGRectMake(self.frame.size.width - 60, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        }
    } //P.E.
    */
    
    @IBInspectable var hasSeperator:Bool {
        get {
            return !_seperatorView.hidden;
        }
        
        set {
            _seperatorView.hidden = !newValue;
        }
    } //P.E.
    
    var seperatorOnTop:Bool = false;
    
    private var _seperatorColorStyle:String = "";
    @IBInspectable var seperatorColorStyle:String {
        get {
            return _seperatorColorStyle;
        }
        
        set {
            if (_seperatorColorStyle != newValue)
            {
                _seperatorColorStyle = newValue;
                //--
                _seperatorView.backgroundColor = SyncedColors.color(forKey: _seperatorColorStyle);
            }
        }
    } //P.E.
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        //--
        self.selectionStyle = UITableViewCellSelectionStyle.None;
        //--
        commonInitializer(nil);
    } //F.E.
    
    init(reuseIdentifier: String?, textColor:UIColor? = nil) {
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: reuseIdentifier);//
        //--
        commonInitializer(textColor);
    }//C.F.
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder);
        //--
        commonInitializer(nil);
    } //F.E.
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        //--
        self.updateView();
    } //F.E.
    
    override public func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated);
        //--
        
    } //F.E.
    
    private func commonInitializer(textColor:UIColor?)
    {
        self.backgroundColor = UIColor.clearColor();//GLOBAL.CLEAR_COLOR;
        self.contentView.backgroundColor  = UIColor.clearColor(); //GLOBAL.CLEAR_COLOR;
        self.textLabel?.textColor = (textColor == nil) ?UIColor.blueColor():textColor;
        //--
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.textLabel?.font = UIView.font("Medium");
        //--
        _seperatorView = UIView(frame: self.seperatorFrame);
        _seperatorView.backgroundColor = UIColor.lightGrayColor();
        _seperatorView.hidden = true;
        //--
        self.addSubview(_seperatorView);
    } //F.E.
    
    public func updateView() {
        if (bgColorStyle != nil) {
            self.backgroundColor = SyncedColors.color(forKey: bgColorStyle);
        }
        
        if (_seperatorColorStyle != "") {
            _seperatorView.backgroundColor = SyncedColors.color(forKey: _seperatorColorStyle);
        }
    } //F.E.
    
    override public func updateSyncedData() {
        super.updateSyncedData();
        //--
        self.contentView.updateSyncedData();
    } //F.E.
    
    override public func layoutSubviews() {
        super.layoutSubviews();
        //--
        if (_seperatorView != nil)
        {_seperatorView.frame = self.seperatorFrame;}
    } //F.E.
    
    func updateData(data:AnyObject?) {
        _data = data;
        //--
        self.updateSyncedData();
    } //F.E.

} //CLS END
