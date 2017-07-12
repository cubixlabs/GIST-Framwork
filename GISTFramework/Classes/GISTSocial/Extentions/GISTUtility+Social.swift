//
//  GISTUtility.swift
//  GISTFramework
//
//  Created by Shoaib Abdul on 07/09/2016.
//  Copyright © 2016 Social Cubix. All rights reserved.
//

import UIKit
import PhoneNumberKit

/// Extension for Utility
public extension GISTUtility {
    
    public class func validate(fields:[ValidatedTextField]) -> Bool {
        var isValid:Bool = true;
        
        for field in fields {
            if (field.isValid == false && isValid == true) {
                isValid = false; // The reason on not breaking loop here is that each field should call its isValid propert to update view
            }
        }
        
        return isValid;
        
    } //F.E.
    
    public class func validate(array:NSMutableArray, ignore iParams:[String]? = nil) -> Bool {
        var isValid:Bool = true;
        
        let ignoreParams:[String] = iParams ?? [];
        
        for i in 0 ..< array.count {
            if let dict:NSMutableDictionary = array[i] as? NSMutableDictionary {
                let isFieldValid:Bool;
                
                if let dataArr:NSMutableArray = dict["data"] as? NSMutableArray {
                    isFieldValid = self.validate(array: dataArr, ignore: iParams);
                } else if let pKey:String = dict["paramKey"] as? String, ignoreParams.contains(pKey) == false {
                    
                    dict["validated"] = true;
                    
                    var isValid:Bool? = dict["isValid"] as? Bool
                    
                    if (isValid == nil) {
                        isValid = self.validate(dictionary: dict);
                    }
                    
                    isFieldValid = isValid!;
                    
                } else {
                    isFieldValid = true;
                }
                
                if (isFieldValid == false && isValid == true) {
                    isValid = false; // The reason for not breaking loop here is that each field should call its isValid propert to update view
                }
            }
        }
        
        return isValid;
        
    } //F.E.
    
    public class func validate(dictionary:NSMutableDictionary) -> Bool {
        
        guard let text:String = dictionary["text"] as? String else {
            return true;
        }
        
        //First set the validations
        let validateEmpty:Bool = dictionary["validateEmpty"] as? Bool ?? false;
        let validateEmail:Bool = dictionary["validateEmail"] as? Bool ?? false;
        let validatePhone:Bool = dictionary["validatePhone"] as? Bool ?? false;
        let validateEmailOrPhone:Bool = dictionary["validateEmailOrPhone"] as? Bool ?? false;
        let validateEmailPhoneOrUserName:Bool = dictionary["validateEmailPhoneOrUserName"] as? Bool ?? false;
        
        let validateURL:Bool = dictionary["validateURL"] as? Bool ?? false;
        let validateNumeric:Bool = dictionary["validateNumeric"] as? Bool ?? false;
        let validateAlphabetic:Bool = dictionary["validateAlphabetic"] as? Bool ?? false;
        let validateRegex:String = dictionary["validateRegex"] as? String ?? "";
        
        //Set the character Limit
        let minChar:Int = dictionary["minChar"] as? Int ?? 0;
        let maxChar:Int = dictionary["maxChar"] as? Int ?? 0;
        
        let defRegion:String? = dictionary["defaultRegion"] as? String;
        
        let isEmail:Bool = self.isEmpty(text);
        
        var phoneNumber:PhoneNumber?;
        
        if (validatePhone || validateEmailOrPhone || validateEmailPhoneOrUserName) {
            phoneNumber = self.validatePhoneNumber(text, withRegion: defRegion ?? PhoneNumberKit.defaultRegionCode());
        }
        
        let isValidPhone:Bool =  phoneNumber != nil;
        
        let isValid:Bool =
                (!validateEmpty || !isEmail) &&
                (!validateEmail || self.isValidEmail(text)) &&
                (!validatePhone || isValidPhone) &&
                (!validateEmailOrPhone || (self.isValidEmail(text) || isValidPhone)) &&
                (!validateEmailPhoneOrUserName || (self.isValidEmail(text) || isValidPhone || !isEmail)) &&
                (!validateURL || self.isValidUrl(text)) &&
                (!validateNumeric || self.isNumeric(text)) &&
                (!validateAlphabetic || self.isAlphabetic(text)) &&
                ((minChar == 0) || self.isValidForMinChar(text, noOfChar: minChar)) &&
                ((maxChar == 0) || self.isValidForMaxChar(text, noOfChar: maxChar)) &&
                ((validateRegex == "") || self.isValidForRegex(text, regex: validateRegex));
        
        let validText:String?;
        
        if isValid {
            if let pNumber:PhoneNumber = phoneNumber {
                validText = "+\(pNumber.countryCode)-\(pNumber.nationalNumber)";
            } else {
                validText = text;
            }
        } else {
            validText = nil;
        }
        
        dictionary["isValid"] = isValid;
        dictionary["validText"] = validText;
        
        return isValid;
    } //F.E.
    
    
    public class func formate(fields:[ValidatedTextField], additional aParams:[String:Any]? = nil, ignore iParams:[String]? = nil) -> [String:Any] {
        var rParams:[String:Any] = [:];
        
        for field in fields {
            if let pKey:String = field.paramKey, let text:String = field.validText {
                rParams[pKey] = text;
            }
        }

        //Additional Params
        if let params:[String:Any] = aParams {
            for (pKey, pValue) in params {
                rParams[pKey] = pValue;
            }
        }
        
        //Ingnore Params
        if let params:[String] = iParams {
            for pKey in params {
                rParams.removeValue(forKey: pKey);
            }
        }
        
        return rParams;
    } //F.E.
    
    public class func formate(array:NSMutableArray, additional aParams:[String:Any]? = nil, ignore iParams:[String]? = nil) -> [String:Any] {
        var rParams:[String:Any] = [:];
        
        for i in 0 ..< array.count {
            if let dict:NSMutableDictionary = array[i] as? NSMutableDictionary {
                if let dataArr:NSMutableArray = dict["data"] as? NSMutableArray {
                    
                    for j in 0 ..< dataArr.count {
                        if let sDict:NSMutableDictionary = dataArr[j] as? NSMutableDictionary {
                            if let pKey:String = sDict["paramKey"] as? String {
                                if let text:String = sDict["rawText"] as? String {
                                    rParams[pKey] = text;
                                } else if let text:String = sDict["validText"] as? String {
                                    rParams[pKey] = text;
                                }
                            }
                        }
                    }
                    
                    
                } else if let pKey:String = dict["paramKey"] as? String {
                    if let text:String = dict["rawText"] as? String {
                        rParams[pKey] = text;
                    } else if let text:String = dict["validText"] as? String {
                        rParams[pKey] = text;
                    }
                }
            }
        }
        
        //Additional Params
        if let params:[String:Any] = aParams {
            for (pKey, pValue) in params {
                rParams[pKey] = pValue;
            }
        }
        
        //Ingnore Params
        if let params:[String] = iParams {
            for pKey in params {
                rParams.removeValue(forKey: pKey);
            }
        }
        
        return rParams;
    } //F.E.
    
    public class func formate(user:GISTUser, additional aParams:[String:Any]? = nil, ignore iParams:[String]? = nil) -> [String:Any] {
        var rParams:[String:Any] = user.toDictionary() as? [String:Any] ?? [:];
        
        //Additional Params
        if let params:[String:Any] = aParams {
            for (pKey, pValue) in params {
                rParams[pKey] = pValue;
            }
        }
        
        //Ingnore Params
        if let params:[String] = iParams {
            for pKey in params {
                rParams.removeValue(forKey: pKey);
            }
        }
        
        return rParams;
    } //F.E.
    
    
    public class func mapData(to array:NSMutableArray, from data:NSDictionary, forkey key:String){
        for i in 0 ..< array.count {
            if let dict:NSMutableDictionary = array[i] as? NSMutableDictionary {
                if let paramKey:String = dict["paramKey"] as? String, let value:Any = data[paramKey] {
                    dict[key] = value;
                }
                
                if let dataArr:NSMutableArray = dict["data"] as? NSMutableArray {
                    self.mapData(to: dataArr, from: data, forkey: key);
                }
            }
        }
    } //F.E.
    
    public class func getData(from array:NSMutableArray, forkey key:String) -> NSMutableDictionary? {
        for i in 0 ..< array.count {
            if let dict:NSMutableDictionary = array[i] as? NSMutableDictionary {
                if let paramKey:String = dict["paramKey"] as? String, paramKey == key {
                    return dict;
                }
            }
        }
        
        return nil;
    } //F.E.

} //CLS END
