//
//  AuthController.swift
//  OFFFolksonomy
//
//  Created by Arnaud Leene on 26/10/2022.
//

import Foundation

/// Class to store the tokens received after an authentication
/// These can be used for the get API's where the owner is a part of the query
class AuthController: ObservableObject {
    @Published var access_token = ""
    @Published var token_type = ""
    @Published var owner = ""
}
