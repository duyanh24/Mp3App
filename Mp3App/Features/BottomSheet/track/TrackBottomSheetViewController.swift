//
//  TrackBottomSheetViewController.swift
//  Mp3App
//
//  Created by Apple on 11/11/20.
//  Copyright © 2020 AnhLD. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Reusable
import MaterialComponents.MaterialBottomSheet

class TrackBottomSheetViewController: BaseViewController, StoryboardBased, ViewModelBased {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var singerLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var addToFavouriteButton: UIButton!
    @IBOutlet weak var addToPlaylistButton: UIButton!
    @IBOutlet weak var favouriteLabel: UILabel!
    @IBOutlet weak var favouriteImageView: UIImageView!
    
    var viewModel: TrackBottomSheetViewModel!
    private let disposeBag = DisposeBag()
    private let isTrackInFavorites = BehaviorRelay<Bool>(value: false)
    private var track = Track()
    private var checkLogin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    override func prepareUI() {
        super.prepareUI()
        trackImageView.layer.cornerRadius = 5
        containerView.layer.cornerRadius = 5
    }
    
    private func bindViewModel() {
        let input = TrackBottomSheetViewModel.Input(addTrackToFavouriteButton: addToFavouriteButton.rx.tap.asObservable(),
                                                    isTrackInFavorites: isTrackInFavorites.asObservable(),
                                                    play: playButton.rx.tap.asObservable())
        let output = viewModel.transform(input: input)
        
        output.track
            .subscribe(onNext: { [weak self] track in
                self?.track = track
                self?.titleLabel.text = track.title
                self?.singerLabel.text = track.user?.username
                guard let url = track.artworkURL else {
                    return
                }
                self?.trackImageView.setImage(stringURL: url)
            })
            .disposed(by: disposeBag)
        
        output.addTrackToFavouriteResult.subscribe(onNext: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.showErrorAlert(message: error.localizedDescription, completion: nil)
            case .success:
                self.dismiss(animated: true, completion: {
                    if self.isTrackInFavorites.value {
                        UIApplication.topViewController()?.showErrorAlert(message: Strings.removeTrackToFavouriteSuccess)
                    } else {
                        UIApplication.topViewController()?.showErrorAlert(message: Strings.addTrackToFavouriteSuccess)
                    }
                })
            }
        })
        .disposed(by: disposeBag)

        output.checkLogin.subscribe(onNext: { [weak self] isLoggedIn in
            self?.checkLogin = isLoggedIn
        })
        .disposed(by: disposeBag)
        
        output.checkTrackInFavorites.subscribe(onNext: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let value):
                self.isTrackInFavorites.accept(value)
                value ? (self.favouriteLabel.text = Strings.removeTrackInFavourite) : (self.favouriteLabel.text = Strings.addTrackToFavourite)
                value ? (self.favouriteImageView.image = Asset.feedLikeSelectedIcoNormal.image) : (self.favouriteImageView.image = Asset.icLikeGrey1616Normal.image)
            }
        }).disposed(by: disposeBag)
        
        addToPlaylistButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else {
                return
            }
            if self.checkLogin {
                self.dismiss(animated: false, completion: {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: Strings.ShowPlaylistOption), object: nil, userInfo: [Strings.tracks: self.track])
                })
            } else {
                self.showErrorAlert(message: Strings.notLoggedInMessage, completion: nil)
            }
            
        }).disposed(by: disposeBag)
        
        output.playTrack.subscribe(onNext: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        })
        .disposed(by: disposeBag)
        
        
    }
}
