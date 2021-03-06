//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Bozidar on 07.12.2015..
//  Copyright © 2015. Bozidar. All rights reserved.
//

import Foundation

//This represents Model
//Foundation is core layer of iOS

class CalculatorBrain{
    
    //Enum can have function and computed properties
    //CustomStringConvertible is protocol, enum implements all from protocol
    private enum Op: CustomStringConvertible {
        case Operand(Double)
        case UnaryOperation(String, Double->Double)
        case BinaryOperation(String, (Double, Double) ->Double)
        
        var description: String{
            get{
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }set{
                
            }
        }
    }
    
    private var opStack: Array<Op> = [Op]()
    //Key is symbol and value is operand
    private var knownOps = [String:Op]()
    
    //Initializer is like Constructor in Java
    init(){
        knownOps["×"] = Op.BinaryOperation("×", *)
        knownOps["÷"] = Op.BinaryOperation("×") {$1 / $0}
        knownOps["+"] = Op.BinaryOperation("+", +)
        knownOps["−"] = Op.BinaryOperation("−") {$1 - $0}
        knownOps["√"] = Op.UnaryOperation("√", sqrt)
    }
    
    
    //Property List is an AnyObject which is known to be a collection of objects which are only one of: NSString, NSArray, NSDictionary, NSNumber, NSData, NSDate (in this case this is NSString)
    typealias Propertylist = AnyObject
    var program: Propertylist{ //guaranted to be a PropertyList
        get{
            //Convert all items from opStack to String Array and return this Array
            return opStack.map{ $0.description }
//            var returnValue = Array<String>()  //this is property list...array are bridged to NSArray
//            for op in opStack{
//                returnValue.append(op.description)
//            }
//            return returnValue
        }
        set{
            //get Array<String> of all symbols
            if let opSymbols = newValue as? Array<String>{
                var newOpStack = [Op]()
                //Iterate through all items from Array<String> of symbols
                    for opSymbol in opSymbols{
                        //check if symbol exists (+. /, x, - and square root)
                        if let op = self.knownOps[opSymbol]{
                            newOpStack.append(op)
                            //check if opSymbol is number
                            //this is optional chaining
                        }else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue{
                            newOpStack.append(.Operand(operand)) //store number in newOpStack
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    //Using Touple as return value
    //Big diference between struct and classes: 
    //  1.  classs can have inheritance
    //  2. struct are passed by value and classes are passe by reference
    
    
    private func evaluate(ops: [Op])->(result: Double?, remainingOps: [Op]){
        if(!ops.isEmpty){
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op
            {
            case .Operand(let operand):
                //Operand is result
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                //Recursion
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result{
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result{
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result{
                        return (operation(operand1,operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    func evaluate()->Double?{
        let (result, remainder) = evaluate(opStack)
        print("\(opStack) = \(result) with \(remainder) left over")
        return result
    }

    func pushOperand(operand: Double)->Double?{
        //creating enum
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func performOperation(symbol: String)->Double?{
        //operation is type of Op
        if let operation = knownOps[symbol]{
            opStack.append(operation)
        }
        return evaluate()
    }
}