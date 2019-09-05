//
//  Person.swift
//  NamesToFaces
//
//  Created by José Eduardo Pedron Tessele on 04/09/19.
//  Copyright © 2019 José P Tessele. All rights reserved.
//

import UIKit

class Person: NSObject {
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
