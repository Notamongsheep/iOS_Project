//
//  protocols.swift
//  iOS Project
//
//  Created by Christine Berger on 12/8/17.
//  Copyright © 2017 Christine Berger. All rights reserved.
//

import UIKit    //UI element controls

/*=================================================================*
 * PROTOCOL EndExerciseDelegate: class
 * A protocol that is class-bound in order to control what happens
 * from the view who is a delegate over the childview with this delegate type.
 * Used for handing over control from EndExerciseViewController's view
 * to its parent controllers.
 *==================================================================*/
protocol EndExerciseDelegate: class {
    func restartButtonPressed()
}