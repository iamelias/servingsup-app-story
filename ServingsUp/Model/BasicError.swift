//
//  BasicError.swift
//  ServingsUp
//
//  Created by Elias Hall on 3/9/22.
//  Copyright © 2022 Elias Hall. All rights reserved.
//

import Foundation

struct BasicError {
    let errorType: FormatError
    let title: String
    let message: String
    
    public init(errorType: FormatError, title: String, message: String) {
        self.errorType = errorType
        self.title = title
        self.message = message
    }
}
