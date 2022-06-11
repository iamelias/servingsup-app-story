//
//  Util.swift
//  ServingsUp
//
//  Created by Elias Hall on 3/9/22.
//  Copyright © 2022 Elias Hall. All rights reserved.
//

import Foundation
import UIKit

struct Util {
    
    //Haptic Feedback methods
    static func hapticError() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    static func hapticSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    static func verifyTextHelper(textData: String) -> BasicError? {
        do {
            try Util.emptyStringTest(input: textData)
        }
        catch {
            let error = BasicError(errorType: .blankError, title: "Error: Invalid Input", message: "Please fill in the empty text field")
            return error
        }
        do {
            try Util.excessNameLengthTest(input: textData)
        }
        catch {
            let error = BasicError(errorType: .nameTooLongError, title: "Error: Invalid Input", message: "Please use a maximum of 25 characters.")
            return error
        }
        return nil
    }
    
    static func emptyStringTest(input: String) throws  {
        let result = input.replacingOccurrences(of: " ", with: "")
        if result.isEmpty {
            throw FormatError.blankError
        } else {
        }
    }
    
    static func excessNameLengthTest(input: String) throws {
        if input.count >= 25 {
            throw FormatError.nameTooLongError
        }
        else {}
    }
    
    static func removeTrailingZeros(input:String) -> String {
        var input = input
        while input.last == "0" {
            _ = input.popLast()
        }
        if input.last == "." {
            _ = input.popLast()
        }
        return input
    }
}
