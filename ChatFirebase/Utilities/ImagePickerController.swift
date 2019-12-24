//
//  ImagePickerController.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/24/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import UIKit
import YPImagePicker
import RxSwift
import RxCocoa

class ImagePickerController {
    
    private var picker: YPImagePicker!
    
    private(set) var selectedImage = PublishRelay<UIImage>()
    let bag = DisposeBag()
    
    init() {
        var config = YPImagePickerConfiguration()
        // General
        config.isScrollToChangeModesEnabled = true
        config.onlySquareImagesFromCamera = true
        config.usesFrontCamera = true
        config.showsPhotoFilters = false
        config.showsVideoTrimmer = false
        config.shouldSaveNewPicturesToAlbum = false
        config.albumName = "ChatFirebase"
        config.startOnScreen = YPPickerScreen.library
        config.screens = [.library, .photo]
        config.showsCrop = .rectangle(ratio: 1.2)
        config.targetImageSize = YPImageSize.original
        config.overlayView = UIView()
        config.hidesStatusBar = true
        config.hidesBottomBar = false
        config.preferredStatusBarStyle = UIStatusBarStyle.default
        config.maxCameraZoomFactor = 1.0
        
        // Library
        config.library.options = nil
        config.library.onlySquare = false
        config.library.isSquareByDefault = true
        config.library.minWidthForItem = nil
        config.library.mediaType = YPlibraryMediaType.photo
        config.library.defaultMultipleSelection = false
        config.library.maxNumberOfItems = 1
        config.library.minNumberOfItems = 1
        config.library.numberOfItemsInRow = 4
        config.library.spacingBetweenItems = 1.0
        config.library.skipSelectionsGallery = false
        config.library.preselectedItems = nil
        
        // Gallery
        config.gallery.hidesRemoveButton = false
        picker = YPImagePicker(configuration: config)
        
        picker.didFinishPicking { [unowned picker, weak self] (items, cancelled) in
            if let photo = items.singlePhoto {
                self?.selectedImage.accept(photo.image)
            }
            picker?.dismiss(animated: true, completion: nil)
        }
    }
    
    func showPicker(inController controller: UIViewController) {
        controller.present(picker, animated: true, completion: nil)
    }
}
