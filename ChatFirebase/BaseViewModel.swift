//
//  BaseViewModel.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/20/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import RxSwift
import RxCocoa

protocol BaseViewModel {
    var rx_isLoading: PublishRelay<Bool> { get }
    var rx_error: PublishRelay<String> { get }
}
