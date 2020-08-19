//
//  StudentModel.swift
//  Dispatchtrack
//
//  Created by surendra kumar k on 19/08/20.
//  Copyright © 2020 surendra kumar k. All rights reserved.
//



import Foundation

struct StudentsModel: Codable {
    let students: [StudentObj]
}

// MARK: - Student
struct StudentObj : Codable {
    let name: String?
    let id : Int?
}
