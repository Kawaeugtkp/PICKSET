//
//  EditProfileViewModel.swift
//  PICKSET
//
//  Created by 川尻辰義 on 2022/09/08.
//

import Foundation

enum EditProfileOptions: Int, CaseIterable {
    case fullname
    case username
    
    var description: String {
        switch self {
        case .username: return "Username"
        case .fullname: return "Name"
        }
    }
}

struct EditProfileViewModel {
    
    private let user: User
    let option: EditProfileOptions
    
    var titleText: String {
        return option.description
    }
    
    var optionValue: String? {
        switch option {
        case .fullname:
            return user.fullname
        case .username:
            return user.username
        }
    }
    
//    var shouldHidePlaceholderLabel: Bool {
//        return user.bio != nil
//    }
    
    init(user: User, option: EditProfileOptions) {
        self.user = user
        self.option = option
    }
}
