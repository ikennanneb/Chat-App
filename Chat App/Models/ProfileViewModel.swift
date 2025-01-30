//
//  ProfileViewModel.swift
//  Chat App
//
//  Created by Ikenna on 9/28/23.
//

import Foundation

enum ProfileViewModelType
{
    case info, logout
}

struct ProfileViewModel
{
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
}
