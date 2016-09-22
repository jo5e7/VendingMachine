//
//  VendingMachine.swift
//  VendingMachine
//
//  Created by Jose Maestre on 20/09/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import Foundation
import UIKit

//Protocols     

protocol VendingMachineType {
    var selection: [VendingSelection] {get}
    var inventory: [VendingSelection: ItemType] {get set}
    var amountDeposited: Double {get set }
    
    init(inventory: [VendingSelection:ItemType])
    func vend(selection: VendingSelection, quantity: Double) throws
    func deposit(amount : Double)
    func itemForCurrentSelection(selection:VendingSelection) -> ItemType?
}

protocol ItemType {
    var price: Double {get}
    var quantity: Double {get set}
}

//Error Types
enum InvetoryErrors: ErrorType{
    case InvalidResource
    case ConversionError
    case InvalidKey
}

enum VendingMachineError: ErrorType{
    case InvalidSelection
    case OutOfStock
    case InsufficientFunds(required:Double)
}

//Helper classes

class PlistConverter{
    class func dictionaryFromFile(resource: String, ofType :String) throws -> [String:AnyObject]{
        
        guard let path = NSBundle.mainBundle().pathForResource(resource, ofType: ofType)
            else {
                throw InvetoryErrors.InvalidResource
        }
        
        guard let dictionary = NSDictionary(contentsOfFile: path), let castDictionary = dictionary as? [String:AnyObject] else{
            throw InvetoryErrors.ConversionError
        }
        
        return castDictionary
    }
}

class InventoryUnarchiver{
    class func vendingInventoryFromDictionary(dictionary : [String:AnyObject]) throws -> [VendingSelection:ItemType]{
        
        var inventory : [VendingSelection:ItemType] = [:]
        
        for (key, value) in dictionary{
            if let itemDict = value as? [String:Double], let price = itemDict["price"], let quantity = itemDict["quantity"]{
                
                let item = VendingItem(price: price, quantity: quantity)
                
                guard let key = VendingSelection(rawValue: key) else{
                    throw InvetoryErrors.InvalidKey
                }
                
                inventory.updateValue(item, forKey: key)
            }
        }
        return inventory
    }
}

//concrete typea

enum VendingSelection: String{
    case Soda
    case DietSoda
    case Chips
    case Cookie
    case Sandwich
    case Wrap
    case CandyBar
    case PopTart
    case Water
    case FruitJuice
    case SportsDrink
    case Gum
    
    func icon() -> UIImage {
        if let image = UIImage(named: self.rawValue) {
            return image
        }else{
            return UIImage(named: "Default")!
        }
    }
}

struct VendingItem: ItemType{
    let price: Double
    var quantity: Double
    
}

class VendingMachine: VendingMachineType{
    
    let selection: [VendingSelection] = [.Soda, .DietSoda, .Chips, .Cookie, .Sandwich, .Wrap, .CandyBar, .PopTart, .Water, .FruitJuice, .SportsDrink, .Gum]
    var inventory: [VendingSelection : ItemType]
    var amountDeposited: Double = 10
    
    required init(inventory: [VendingSelection : ItemType]) {
        self.inventory = inventory
    }
    
    func vend(selection: VendingSelection, quantity: Double) throws {
        //Add code
        guard var item = inventory[selection] else{
            throw VendingMachineError.InvalidSelection
        }
        
        guard item.quantity > 0 else{
            throw VendingMachineError.OutOfStock
        }
        
        item.quantity -= quantity
        inventory.updateValue(item, forKey: selection)
        
        let totalPrice = item.price * quantity
        if amountDeposited >= totalPrice {
            amountDeposited -= totalPrice
        }else{
            let amountRequired = totalPrice - amountDeposited
            throw VendingMachineError.InsufficientFunds(required: amountRequired)
        }
    }
    
    func itemForCurrentSelection(selection: VendingSelection ) -> ItemType?{
        return inventory[selection]
    }
    
    func deposit(amount: Double) {
        
    }
}









