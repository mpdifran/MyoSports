//
//  MyoMathExtensions.swift
//  MyoSports
//
//  Created by Mark DiFranco on 2015-05-30.
//  Copyright (c) 2015 MDF Projects. All rights reserved.
//

import Foundation

// MARK: - Operator Overloading

func -(left: TLMVector3, right: TLMVector3) -> TLMVector3 {
    return TLMVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}

func +(left: TLMVector3, right: TLMVector3) -> TLMVector3 {
    return TLMVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

func *(left: TLMVector3, right: Float) -> TLMVector3 {
    return TLMVector3Make(left.x * right, left.y * right, left.z * right)
}
